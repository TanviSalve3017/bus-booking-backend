if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const moment = require("moment-timezone");

const app = express();

// ✅ CORS FIX: नेटलिफाय आणि लोकलहोस्ट दोन्हीसाठी परवानगी दिली आहे
app.use(cors({
    origin: "*", 
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true
}));

app.use(express.json());

const db = mysql.createConnection({
  host: process.env.DB_HOST || "mysql-16a68106-bus-reservation-j.aivencloud.com",
  user: process.env.DB_USER || "avnadmin",
  password: process.env.DB_PASSWORD, 
  database: process.env.DB_NAME || "defaultdb", 
  port: process.env.DB_PORT || 23996, 
  timezone: '+05:30',
  ssl: {
    rejectUnauthorized: false 
  },
  connectTimeout: 20000 
});

db.connect((err) => {
    if (err) {
        console.error("❌ Aiven Connection Error:", err.message);
    } else {
        console.log("✅ Database Connected Successfully via Aiven!");
    }
});

// ==========================================
// १. REGISTER API (With role fix)
// ==========================================
app.post("/api/register", (req, res) => {
    const { name, email, password, mobile } = req.body;
    
    db.query("SELECT * FROM users WHERE email = ?", [email], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        
        if (results.length > 0) {
            return res.status(400).json({ success: false, message: "Email already exists" });
        }

        const sql = "INSERT INTO users (name, email, password, mobile, role) VALUES (?, ?, ?, ?, 'User')";
        db.query(sql, [name, email, password, mobile], (insertErr, result) => {
            if (insertErr) {
                console.error("🚨 DB Insert Error:", insertErr.message);
                return res.status(500).json({ success: false, error: insertErr.message });
            }
            res.json({ success: true, message: "User registered successfully!" });
        });
    });
});

// ==========================================
// २. LOGIN API
// ==========================================
app.post("/api/login", (req, res) => {
    const { email, password } = req.body;
    db.query("SELECT * FROM users WHERE email = ? AND password = ?", [email, password], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (results.length > 0) {
            res.json({ success: true, user: results[0] });
        } else {
            res.status(401).json({ success: false, message: "Invalid credentials" });
        }
    });
});

// ==========================================
// ३. BUS SEARCH API
// ==========================================
app.get("/api/buses", (req, res) => {
    let { from, to } = req.query;
    const fromCity = from ? from.toLowerCase().trim() : "";
    const toCity = to ? to.toLowerCase().trim() : "";

    console.log(`🔍 Searching buses for: ${fromCity} to ${toCity}`);

    const sql = `
        SELECT b.*, r.source, r.destination, o.operator_name 
        FROM buses b 
        JOIN routes r ON b.route_id = r.route_id 
        JOIN operators o ON b.operator_id = o.operator_id 
        WHERE LOWER(r.source) = ? AND LOWER(r.destination) = ?`;

    db.query(sql, [fromCity, toCity], (err, results) => {
        if (err) {
            console.error("🚨 Search Error:", err);
            return res.status(500).send(err);
        }
        res.json(results);
    });
});

// ==========================================
// ४. SEATS API
// ==========================================
app.get("/api/seats/:busId", (req, res) => {
    const { busId } = req.params;
    db.query("SELECT * FROM seats WHERE bus_id = ?", [busId], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results);
    });
});

// ==========================================
// ५. VERIFY PAYMENT & SAVE BOOKING
// ==========================================
app.post("/api/verify-payment", (req, res) => {
    const { bookingDetails } = req.body;
    
    if (!bookingDetails) {
        console.log("❌ No booking details received!");
        return res.status(400).json({ message: "No Data" });
    }

    const finalUserId = (bookingDetails.userId && bookingDetails.userId !== "undefined" && bookingDetails.userId !== "null") 
                        ? bookingDetails.userId 
                        : 1; 

    const generatedPnr = "PNR" + Math.floor(100000 + Math.random() * 900000);
    const seatString = Array.isArray(bookingDetails.seats) ? bookingDetails.seats.join(',') : String(bookingDetails.seats);

    const razorOrder = bookingDetails.razorpayOrderId || "RZP_ORD_" + Date.now();
    const razorPayment = bookingDetails.razorpayPaymentId || "RZP_PAY_" + Date.now();

    const sqlInsert = `INSERT INTO bookings 
    (bus_id, user_id, pnr, passenger_name, passenger_email, passenger_mobile, passenger_age, seat_numbers, total_amount, payment_status, status, razorpay_order_id, razorpay_payment_id) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Success', 'Confirmed', ?, ?)`;

    const age = bookingDetails.passenger_age || 25;

    db.query(sqlInsert, [
        bookingDetails.busId || bookingDetails.bus_id, 
        finalUserId, 
        generatedPnr, 
        bookingDetails.fullName || bookingDetails.passenger_name, 
        bookingDetails.email || bookingDetails.passenger_email, 
        bookingDetails.mobile || bookingDetails.passenger_mobile, 
        age,
        seatString, 
        bookingDetails.totalFare || bookingDetails.total_amount,
        razorOrder,
        razorPayment
    ], (err, result) => {
        if (err) {
            console.error("🚨 SQL Insert Error:", err.message);
            return res.status(500).json({ success: false, error: err.message });
        }
        
        const seatArray = Array.isArray(bookingDetails.seats) ? bookingDetails.seats : String(bookingDetails.seats).split(',');
        db.query("UPDATE seats SET is_booked = 1 WHERE bus_id = ? AND seat_number IN (?)", [bookingDetails.busId || bookingDetails.bus_id, seatArray], (updateErr) => {
            if (updateErr) console.error("🚨 Seat Update Error:", updateErr.message);
            res.json({ success: true, pnr: generatedPnr });
        });
    });
});

// ==========================================
// ६. GET MY BOOKINGS 
// ==========================================
app.get("/api/my-bookings/:userId", (req, res) => {
    let { userId } = req.params;
    if (userId === "undefined" || userId === "null") userId = 1;

    const sql = `
        SELECT bk.*, b.bus_name, b.travel_date, r.source, r.destination 
        FROM bookings bk
        JOIN buses b ON bk.bus_id = b.bus_id
        JOIN routes r ON b.route_id = r.route_id
        WHERE bk.user_id = ?
        ORDER BY bk.booking_date DESC`;

    db.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        const formattedResults = results.map(row => ({
            ...row,
            travel_date: moment(row.travel_date).tz("Asia/Kolkata").format("YYYY-MM-DD")
        }));
        res.json(formattedResults);
    });
});

// ==========================================
// ७. CANCEL TICKET 
// ==========================================
app.put("/api/cancel-ticket/:pnr", (req, res) => {
    const { pnr } = req.params;

    const sqlSelect = `
        SELECT bk.bus_id, bk.seat_numbers, bk.total_amount, b.travel_date, bk.status
        FROM bookings bk 
        JOIN buses b ON bk.bus_id = b.bus_id 
        WHERE bk.pnr = ?`;

    db.query(sqlSelect, [pnr], (err, results) => {
        if (err) return res.status(500).json({ success: false, error: err.message });

        if (results && results.length > 0) {
            const { bus_id, seat_numbers, total_amount, travel_date, status } = results[0];
            if (status === 'Cancelled') return res.status(400).json({ success: false, message: "Already cancelled" });

            const todayIST = moment().tz("Asia/Kolkata").startOf('day');
            const journeyDateIST = moment(travel_date).tz("Asia/Kolkata").startOf('day');
            const diffDays = journeyDateIST.diff(todayIST, 'days');

            let refundPercent = (diffDays >= 2) ? 0.70 : (diffDays === 1 ? 0.50 : 0);
            const refundAmount = (total_amount * refundPercent).toFixed(2);
            const seatArray = seat_numbers.split(',');

            db.query("UPDATE bookings SET status = 'Cancelled' WHERE pnr = ?", [pnr], (upErr) => {
                if (upErr) return res.status(500).json({ success: false, error: upErr.message });

                db.query("UPDATE seats SET is_booked = 0 WHERE bus_id = ? AND seat_number IN (?)", [bus_id, seatArray], (seatErr) => {
                    let refundMsg = `Ticket Cancelled Successfully! `;
                    refundMsg += (refundPercent > 0) 
                        ? `Your refund of ₹${refundAmount} (${refundPercent * 100}%) will be credited within 48 hours.`
                        : `As per policy, no refund is applicable for travel day cancellations.`;
                    res.json({ success: true, message: refundMsg, refundAmount: refundAmount });
                });
            });
        } else { 
            res.status(404).json({ success: false, message: "PNR not found" }); 
        }
    });
});

app.get("/", (req, res) => {
    res.send("Backend is Running Perfectly!");
});

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));