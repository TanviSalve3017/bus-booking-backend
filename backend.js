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
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
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
        timezone: '+05:30', 
        dateStrings: true,  
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
    let { from, to, busType, maxPrice, operator } = req.query;
    const fromCity = from ? from.toLowerCase().trim() : "";
    const toCity = to ? to.toLowerCase().trim() : "";
    let sql = `SELECT DISTINCT b.*, r.source, r.destination, o.operator_name FROM buses b JOIN routes r ON b.route_id = r.route_id JOIN operators o ON b.operator_id = o.operator_id WHERE LOWER(r.source) = ? AND LOWER(r.destination) = ?`;
    let params = [fromCity, toCity];
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

// API 5: VERIFY PAYMENT & SAVE BOOKING (FIXED DATE LOGIC)
app.post("/api/verify-payment", (req, res) => {
    const { bookingDetails } = req.body;
    if (!bookingDetails) return res.status(400).json({ message: "No Data" });

    const busId = bookingDetails.busId || bookingDetails.bus_id;

    db.query("SELECT travel_date FROM buses WHERE bus_id = ?", [busId], (err, busResult) => {
        if (err) return res.status(500).json({ error: err.message });
        if (!busResult.length) return res.status(400).json({ error: "Bus not found" });

        // 🔥 सुधारलेले तारीख लॉजिक: युजरने निवडलेली तारीख (journeyDate) आधी तपासा
        // जर ती नसेल तरच डेटाबेसची डिफॉल्ट तारीख वापरा.
        let finalTravelDate = (bookingDetails.journeyDate || bookingDetails.travel_date || busResult[0].travel_date);
        finalTravelDate = moment(finalTravelDate).format("YYYY-MM-DD");

        const finalUserId = (bookingDetails.userId && bookingDetails.userId !== "undefined" && bookingDetails.userId !== "null") 
                            ? bookingDetails.userId : (bookingDetails.user_id ? bookingDetails.user_id : 1); 

        const generatedPnr = "PNR" + Math.floor(100000 + Math.random() * 900000);
        const seatString = Array.isArray(bookingDetails.seats) ? bookingDetails.seats.join(',') : String(bookingDetails.seats);
        const razorOrder = bookingDetails.razorpayOrderId || "RZP_ORD_" + Date.now();
        const razorPayment = bookingDetails.razorpayPaymentId || "RZP_PAY_" + Date.now();

        const sqlInsert = `INSERT INTO bookings 
(bus_id, user_id, pnr, passenger_name, passenger_email, passenger_mobile, passenger_age, seat_numbers, total_amount, payment_status, status, razorpay_order_id, razorpay_payment_id, travel_date) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Success', 'Confirmed', ?, ?, ?)`;

        db.query(sqlInsert, [
            busId, finalUserId, generatedPnr, 
            bookingDetails.fullName || bookingDetails.passenger_name, 
            bookingDetails.email || bookingDetails.passenger_email, 
            bookingDetails.mobile || bookingDetails.passenger_mobile, 
            bookingDetails.passenger_age || 25, 
            seatString, 
            bookingDetails.totalFare || bookingDetails.total_amount, 
            razorOrder, razorPayment, finalTravelDate 
        ], (err) => {
            if (err) return res.status(500).json({ success: false, error: err.message });
            db.query("UPDATE seats SET is_booked = 1 WHERE bus_id = ? AND seat_number IN (?)", [busId, seatString.split(',')], () => {
                res.json({ success: true, pnr: generatedPnr });
            });
        });
    });
});

// API 6: GET MY BOOKINGS
app.get("/api/my-bookings/:userId", (req, res) => {
    let { userId } = req.params;
    if (userId === "undefined" || userId === "null" || !userId) userId = 1;
    const sql = `SELECT bk.*, b.bus_name, b.travel_date as bus_travel_date, r.source, r.destination FROM bookings bk JOIN buses b ON bk.bus_id = b.bus_id JOIN routes r ON b.route_id = r.route_id WHERE bk.user_id = ? ORDER BY bk.booking_date DESC`;
    db.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const formattedResults = results.map(row => ({
            ...row,
            travel_date: moment(row.travel_date).format("YYYY-MM-DD")
        }));
        res.json(formattedResults);
    });
});

// API 7: CANCEL TICKET
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
            db.query("UPDATE seats SET is_booked = 0 WHERE bus_id = ? AND seat_number IN (?)", [bus_id, seat_numbers.split(',')], () => {
                res.json({ success: true, message: `Cancelled! Refund: ₹${refundAmount}`, refundAmount });
            });
        });
    });
});

app.get("/api/health", (req, res) => db.query("SELECT 1", (err) => res.json({ status: err ? "Offline" : "Online" })));
app.get("/", (req, res) => res.send("Backend is Running!"));

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`🚀 Server running on Port ${PORT}`));