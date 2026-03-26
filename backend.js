if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const moment = require("moment-timezone");

const app = express();

// ✅ १. CORS सेटिंग
app.use(cors({
    origin: function (origin, callback) {
        if (!origin || 
            origin.includes("vercel.app") || 
            origin.includes("localhost") ||
            origin.includes("http://localhost:3000") ||
            origin.includes("http://localhost:5001")) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With", "Accept"],
    credentials: true,
    optionsSuccessStatus: 200 
}));

app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    res.header("Access-Control-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    if (req.method === 'OPTIONS') return res.sendStatus(200);
    next();
});

app.use(express.json());

// ✅ DATABASE CONNECTION
let db;
function handleDisconnect() {
    db = mysql.createConnection({
        host: process.env.DB_HOST || "mysql-16a68106-bus-reservation-j.aivencloud.com",
        user: process.env.DB_USER || "avnadmin",
        password: process.env.DB_PASSWORD, 
        database: process.env.DB_NAME || "defaultdb", 
        port: process.env.DB_PORT || 23996, 
        timezone: '+00:00',
        typeCast: function (field, next) {
            if (field.type === 'DATE') {
                return field.string(); 
            }
            return next();
        },
        ssl: { rejectUnauthorized: false },
        connectTimeout: 20000 
    });

    db.connect((err) => {
        if (err) {
            console.error("❌ Connection Error:", err.message);
            setTimeout(handleDisconnect, 2000); 
        } else {
            console.log("✅ Database Connected!");
        }
    });

    db.on('error', (err) => {
        if (err.code === 'PROTOCOL_CONNECTION_LOST') handleDisconnect();
        else throw err;
    });
}
handleDisconnect();

// API 1: REGISTER
app.post("/api/register", (req, res) => {
    const { name, email, password, mobile } = req.body;
    db.query("SELECT * FROM users WHERE email = ?", [email], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (results.length > 0) return res.status(400).json({ success: false, message: "Email already exists" });
        const sql = "INSERT INTO users (name, email, password, mobile, role) VALUES (?, ?, ?, ?, 'User')";
        db.query(sql, [name, email, password, mobile], (insertErr) => {
            if (insertErr) return res.status(500).json({ success: false, error: insertErr.message });
            res.json({ success: true, message: "User registered successfully!" });
        });
    });
});

// API 2: LOGIN
app.post("/api/login", (req, res) => {
    const { email, password } = req.body;
    db.query("SELECT * FROM users WHERE email = ? AND password = ?", [email, password], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (results.length > 0) res.json({ success: true, user: results[0] });
        else res.status(401).json({ success: false, message: "Invalid credentials" });
    });
});

// API 3: BUS SEARCH 
app.get("/api/buses", (req, res) => {
    let { from, to, date, busType, maxPrice, operator } = req.query;
    const fromCity = from ? from.toLowerCase().trim() : "";
    const toCity = to ? to.toLowerCase().trim() : "";
    
    let sql = `SELECT DISTINCT b.*, r.source, r.destination, o.operator_name 
               FROM buses b 
               JOIN routes r ON b.route_id = r.route_id 
               JOIN operators o ON b.operator_id = o.operator_id 
               WHERE LOWER(r.source) = ? AND LOWER(r.destination) = ?`;
    
    let params = [fromCity, toCity];

    if (date) {
        sql += " AND b.travel_date = ?";
        params.push(date);
    }

    if (busType) { sql += " AND b.bus_type = ?"; params.push(busType); }
    if (maxPrice) { sql += " AND b.price_per_seat <= ?"; params.push(maxPrice); }
    if (operator) { sql += " AND o.operator_name = ?"; params.push(operator); }
    
    db.query(sql, params, (err, results) => {
        if (err) return res.status(500).send(err);
        res.json(results);
    });
});

// API 4: SEATS
app.get("/api/seats/:busId", (req, res) => {
    const { busId } = req.params;
    db.query(`SELECT * FROM seats WHERE bus_id = ? ORDER BY LENGTH(seat_number) ASC, seat_number ASC`, [busId], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// API 5: VERIFY PAYMENT & SAVE BOOKING (🔥 FINAL VERSION)
app.post("/api/verify-payment", (req, res) => {
    const { bookingDetails } = req.body;
    if (!bookingDetails) return res.status(400).json({ message: "No Data" });

    console.log("🔥 INCOMING DATA FOR PROCESSING:", JSON.stringify(bookingDetails, null, 2));

    const busId = bookingDetails.busId || bookingDetails.bus_id;
    if (!busId) return res.status(400).json({ error: "Bus ID missing" });

    const userDate = bookingDetails.travelDate || bookingDetails.travel_date;
    if (!userDate) return res.status(400).json({ error: "Travel date required" });

    const finalTravelDate = userDate.includes("T") ? userDate.split("T")[0] : userDate;

    const finalUserId = (bookingDetails.userId && bookingDetails.userId !== "undefined" && bookingDetails.userId !== "null") 
        ? bookingDetails.userId 
        : (bookingDetails.user_id ? bookingDetails.user_id : 1); 

    const generatedPnr = "PNR" + Math.floor(100000 + Math.random() * 900000);

    // ✅ FIX 1: Ensure seats is an array for SQL IN clause
    const seatArray = Array.isArray(bookingDetails.seats) 
        ? bookingDetails.seats 
        : (bookingDetails.seats ? String(bookingDetails.seats).split(',') : ["1A"]);
    
    const seatString = seatArray.join(',');

    // ✅ FIX 2: Better Age Parsing Logic
    let rawAge = bookingDetails.passengers?.[0]?.age || bookingDetails.passenger_age || 25;
    if (typeof rawAge === "string") {
        rawAge = rawAge.split(",")[0].trim();
    }
    let finalPassengerAge = parseInt(rawAge);
    if (isNaN(finalPassengerAge)) finalPassengerAge = 25;

    const razorOrder = bookingDetails.razorpayOrderId || "RZP_ORD_" + Date.now();
    const razorPayment = bookingDetails.razorpayPaymentId || "RZP_PAY_" + Date.now();

    const sqlInsert = `INSERT INTO bookings 
    (bus_id, user_id, pnr, passenger_name, passenger_email, passenger_mobile, passenger_age, seat_numbers, total_amount, payment_status, status, razorpay_order_id, razorpay_payment_id, travel_date) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Success', 'Confirmed', ?, ?, ?)`;

    db.query(sqlInsert, [
        busId, finalUserId, generatedPnr,
        bookingDetails.fullName || bookingDetails.passenger_name || "Guest",
        bookingDetails.email || bookingDetails.passenger_email || "test@test.com",
        bookingDetails.mobile || bookingDetails.passenger_mobile || "0000000000",
        finalPassengerAge,
        seatString,
        bookingDetails.totalAmount || bookingDetails.total_amount || bookingDetails.totalFare || 0,
        razorOrder,
        razorPayment,
        finalTravelDate
    ], (err) => {
        if (err) {
            console.log("❌ DB INSERT ERROR:", err.sqlMessage || err.message);
            return res.status(500).json({ success: false, error: err.message });
        }

        // ✅ FIX 3: Nested array [seatArray] is required by mysql2 for 'IN (?)'
        db.query(
            "UPDATE seats SET is_booked = 1 WHERE bus_id = ? AND seat_number IN (?)",
            [busId, seatArray],
            (updErr) => {
                if (updErr) {
                    console.log("⚠️ SEAT UPDATE WARNING:", updErr.message);
                }
                res.json({ success: true, pnr: generatedPnr, travelDate: finalTravelDate });
            }
        );
    });
});

app.get("/api/my-bookings/:userId", (req, res) => {
    let { userId } = req.params;
    if (userId === "undefined" || userId === "null" || !userId) userId = 1;
    
    const sql = `SELECT bk.*, b.bus_name, bk.travel_date as travel_date, r.source, r.destination 
                 FROM bookings bk 
                 JOIN buses b ON bk.bus_id = b.bus_id 
                 JOIN routes r ON b.route_id = r.route_id 
                 WHERE bk.user_id = ? 
                 ORDER BY bk.booking_date DESC`;
                 
    db.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const formattedResults = results.map(row => {
            const cleanDate = row.travel_date && row.travel_date.includes('T') 
                ? row.travel_date.split('T')[0] : row.travel_date;
            return { ...row, travel_date: cleanDate };
        });
        res.json(formattedResults);
    });
});

app.put("/api/cancel-ticket/:pnr", (req, res) => {
    const { pnr } = req.params;
    const sqlSelect = `SELECT bk.bus_id, bk.seat_numbers, bk.total_amount, bk.travel_date, bk.status, b.departure_time FROM bookings bk JOIN buses b ON bk.bus_id = b.bus_id WHERE bk.pnr = ?`;

    db.query(sqlSelect, [pnr], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (!results.length) return res.status(404).json({ success: false, message: "PNR not found" });

        const { bus_id, seat_numbers, total_amount, travel_date, status, departure_time } = results[0];
        if (status === 'Cancelled') return res.status(400).json({ success: false, message: "Already cancelled" });

        const journeyDateTimeStr = `${travel_date} ${departure_time || '09:00:00'}`;
        const journeyTime = moment.tz(journeyDateTimeStr, "YYYY-MM-DD HH:mm:ss", "Asia/Kolkata").valueOf();
        const currentTime = moment().tz("Asia/Kolkata").valueOf();
        const diffInHours = (journeyTime - currentTime) / (1000 * 60 * 60);

        let refundPercent = diffInHours >= 24 ? 0.70 : (diffInHours >= 12 ? 0.50 : 0);
        const refundAmount = (total_amount * refundPercent).toFixed(2);

        db.query("UPDATE bookings SET status = 'Cancelled' WHERE pnr = ?", [pnr], () => {
            const seatsToRelease = seat_numbers.split(',');
            db.query("UPDATE seats SET is_booked = 0 WHERE bus_id = ? AND seat_number IN (?)", [bus_id, seatsToRelease], () => {
                res.json({ success: true, message: `Cancelled! Refund: ₹${refundAmount}`, refundAmount });
            });
        });
    });
});

app.get("/api/health", (req, res) => db.query("SELECT 1", (err) => res.json({ status: err ? "Offline" : "Online" })));
app.get("/", (req, res) => res.send("Backend is Running!"));

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`🚀 Server running on Port ${PORT}`));