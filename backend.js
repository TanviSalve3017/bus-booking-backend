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
            origin === "https://bus-booking-system-gamma-gilt.vercel.app" || // <--- तुझी Vercel लिंक इथे टाकू शकतोसgit add .
            origin.includes("localhost") ||
            origin.includes("http://localhost:3000") ||
            origin.includes("http://localhost:5001")) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Origin", "X-Requested-With", "Content-Type", "Accept", "Authorization"],
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
    db = mysql.createPool({
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
    console.log("Database Pool Created with Female Logic!");
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
        
        if (results.length > 0) {
            const user = results[0];
            if (user.is_blocked === 1 || user.is_blocked === true) {
                return res.status(403).json({ 
                    success: false, 
                    message: "Your account has been blocked. Please contact the admin." 
                });
            }
            res.json({ success: true, user: user });
        } else {
            res.status(401).json({ success: false, message: "Invalid credentials" });
        }
    });
});

// API 3: BUS SEARCH
app.get("/api/buses", (req, res) => {
    let { from, to, date, busType, maxPrice, operator } = req.query;
    let sql = `SELECT DISTINCT b.*, r.source, r.destination, o.operator_name 
               FROM buses b 
               JOIN routes r ON b.route_id = r.route_id 
               JOIN operators o ON b.operator_id = o.operator_id`;
    let params = [];
    let conditions = [];

    if (from && to) {
        conditions.push("LOWER(r.source) = ?");
        params.push(from.toLowerCase().trim());
        conditions.push("LOWER(r.destination) = ?");
        params.push(to.toLowerCase().trim());
    }

    if (date && date !== "" && date !== "undefined" && date !== "null") {
        const cleanDate = date.includes("T") ? date.split("T")[0] : date;
        conditions.push("b.travel_date = ?");
        params.push(cleanDate);
    }

    if (busType) { conditions.push("b.bus_type = ?"); params.push(busType); }
    if (maxPrice) { conditions.push("b.price_per_seat <= ?"); params.push(maxPrice); }
    if (operator) { conditions.push("o.operator_name = ?"); params.push(operator); }
    
    if (conditions.length > 0) {
        sql += " WHERE " + conditions.join(" AND ");
    }

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

// ✅ API 5: VERIFY PAYMENT & SAVE BOOKING
app.post("/api/verify-payment", (req, res) => {
    const { bookingDetails } = req.body;
    if (!bookingDetails) return res.status(400).json({ message: "No Data" });

    const busId = bookingDetails.busId || bookingDetails.bus_id;
    const userDate = bookingDetails.travelDate || bookingDetails.travel_date;
    const finalTravelDate = userDate.includes("T") ? userDate.split("T")[0] : userDate;

    const finalUserId = bookingDetails.userId || bookingDetails.user_id || (req.body.user_id) || 1; 

    const generatedPnr = "PNR" + Math.floor(100000 + Math.random() * 900000);
    const seatArray = Array.isArray(bookingDetails.seats) ? bookingDetails.seats : String(bookingDetails.seats).split(',');
    const seatString = seatArray.join(',');
    const userGender = bookingDetails.gender || 'Male';

    db.query(
        "SELECT seat_number, reserved_for FROM seats WHERE bus_id = ? AND seat_number IN (?)",
        [busId, seatArray],
        (err, seatData) => {
            if (err) return res.status(500).json({ success: false, error: "Database error" });

            const invalidBooking = seatData.some(s => s.reserved_for === 'Female' && userGender.toLowerCase() === 'male');

            if (invalidBooking) {
                return res.status(400).json({ 
                    success: false, 
                    message: "Some of the selected seats are reserved for women only. Please choose another seat." 
                });
            }

            let rawAge = bookingDetails.passengers?.[0]?.age || bookingDetails.passenger_age || 25;
            let finalPassengerAge = parseInt(String(rawAge));
            if (isNaN(finalPassengerAge)) finalPassengerAge = 25;

            const razorOrder = bookingDetails.razorpayOrderId || "RZP_ORD_" + Date.now();
            const razorPayment = bookingDetails.razorpayPaymentId || "RZP_PAY_" + Date.now();

            const sqlInsert = `INSERT INTO bookings 
            (bus_id, user_id, pnr, passenger_name, passenger_email, passenger_mobile, passenger_age, seat_numbers, total_amount, payment_status, status, razorpay_order_id, razorpay_payment_id, travel_date) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Success', 'Confirmed', ?, ?, ?)`;

            db.query(sqlInsert, [
                busId, finalUserId, generatedPnr,
                bookingDetails.fullName || "Guest",
                bookingDetails.email || "test@test.com",
                bookingDetails.mobile || "0000000000",
                finalPassengerAge, seatString,
                bookingDetails.totalAmount || 0,
                razorOrder, razorPayment, finalTravelDate
            ], (insErr) => {
                if (insErr) {
                    console.error("Booking Insert Error:", insErr);
                    return res.status(500).json({ success: false, error: insErr.message });
                }

                db.query(
                    "UPDATE seats SET is_booked = 1 WHERE bus_id = ? AND seat_number IN (?)",
                    [busId, seatArray],
                    (updErr) => {
                        res.json({ success: true, pnr: generatedPnr, travelDate: finalTravelDate });
                    }
                );
            });
        }
    );
});

// API: MY BOOKINGS
app.get("/api/my-bookings/:userId", (req, res) => {
    let { userId } = req.params;
    const sql = `SELECT bk.*, b.bus_name, bk.travel_date, r.source, r.destination 
                 FROM bookings bk 
                 JOIN buses b ON bk.bus_id = b.bus_id 
                 JOIN routes r ON b.route_id = r.route_id 
                 WHERE bk.user_id = ? ORDER BY bk.booking_date DESC`;
                 
    db.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// API: CANCEL TICKET
app.put("/api/cancel-ticket/:pnr", (req, res) => {
    const { pnr } = req.params;
    const sqlSelect = `SELECT bk.bus_id, bk.seat_numbers, bk.total_amount, bk.travel_date, bk.status, b.departure_time FROM bookings bk JOIN buses b ON bk.bus_id = b.bus_id WHERE bk.pnr = ?`;

    db.query(sqlSelect, [pnr], (err, results) => {
        if (err || !results.length) return res.status(404).json({ success: false, message: "PNR not found" });

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

// ✅ ADMIN STATS API
app.get("/api/admin-stats", (req, res) => {
    const q = `
        SELECT 
            (SELECT COUNT(*) FROM buses) as busCount,
            (SELECT COUNT(*) FROM bookings) as bookingCount,
            (SELECT IFNULL(SUM(total_amount), 0) FROM bookings WHERE status = 'Confirmed') as totalRevenue
    `;
    db.query(q, (err, data) => {
        if (err) return res.status(500).json(err);
        res.json(data[0]);
    });
});

// ✅ नवीन API: डॅशबोर्डसाठी लेटेस्ट १० बुकिंग्स
app.get("/api/admin/recent-bookings", (req, res) => {
    const q = "SELECT * FROM bookings ORDER BY booking_date DESC LIMIT 10";
    db.query(q, (err, data) => {
        if (err) {
            console.error("Recent Bookings Error:", err);
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json(data);
    });
});

// ✅ १. सर्व युजर्सची लिस्ट मिळवण्यासाठी (Fixed Column Names based on SQL)
app.get("/api/admin/users", (req, res) => {
    // SQL मध्ये 'user_id' आणि 'mobile' आहे, म्हणून 'as' वापरून मॅप केले आहे
    const q = "SELECT user_id as id, name, email, mobile as phone, role, is_blocked FROM users";
    
    db.query(q, (err, data) => {
        if (err) {
            console.error("Fetch Users Error:", err.message);
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json(data);
    });
});

// ✅ २. युजरला ब्लॉक किंवा अनब्लॉक करण्यासाठी
app.put("/api/admin/users/toggle-block/:id", (req, res) => {
    const userId = req.params.id;
    const { is_blocked } = req.body; 
    
    const q = "UPDATE users SET is_blocked = ? WHERE user_id = ?";
    db.query(q, [is_blocked ? 1 : 0, userId], (err, data) => {
        if (err) {
            console.error("Toggle Block Error:", err);
            return res.status(500).json({ success: false, error: err.message });
        }
        res.json({ success: true, message: "User status updated successfully!" });
    });
});

// ✅ DELETE BUS API
app.delete("/api/buses/:id", (req, res) => {
    const busId = req.params.id;
    db.query("DELETE FROM seats WHERE bus_id = ?", [busId], (err) => {
        if (err) return res.status(500).json({ error: "Seats delete error" });
        db.query("DELETE FROM buses WHERE bus_id = ?", [busId], (err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ success: true, message: "Bus deleted successfully!" });
        });
    });
});

// ✅ ADD NEW BUS (Updated with Female Seat Logic)
app.post("/api/add-bus", (req, res) => {
    const { bus_name, bus_type, price_per_seat, travel_date, source, destination } = req.body;

    const findRouteSql = "SELECT route_id FROM routes WHERE LOWER(source) = LOWER(?) AND LOWER(destination) = LOWER(?) LIMIT 1";
    
    db.query(findRouteSql, [source, destination], (routeErr, routeData) => {
        if (routeErr || routeData.length === 0) {
            return res.status(400).json({ success: false, message: "Root not found!" });
        }

        const route_id = routeData[0].route_id;
        const sql = "INSERT INTO buses (bus_name, bus_type, route_id, operator_id, price_per_seat, travel_date, departure_time) VALUES (?, ?, ?, 1, ?, ?, '09:00:00')";
        
        db.query(sql, [bus_name, bus_type, route_id, price_per_seat, travel_date], (err, result) => {
            if (err) return res.status(500).json({ success: false, error: err.message });

            const busId = result.insertId;
            let seatValues = [];

            if (bus_type.includes("Sleeper")) {
                for (let i = 1; i <= 15; i++) {
                    let reserve = (i <= 2) ? 'Female' : 'General';
                    seatValues.push([busId, `L${i}`, 'Sleeper', 0, reserve]);
                    seatValues.push([busId, `U${i}`, 'Sleeper', 0, reserve]);
                }
            } else {
                const rows = [1, 2, 3, 4, 5, 6, 7], cols = ['A', 'B', 'C', 'D'];
                rows.forEach(r => cols.forEach(c => {
                    let reserve = (r === 1) ? 'Female' : 'General';
                    seatValues.push([busId, `${r}${c}`, 'Seater', 0, reserve]);
                }));
            }

            db.query("INSERT INTO seats (bus_id, seat_number, seat_type, is_booked, reserved_for) VALUES ?", [seatValues], (seatErr) => {
                if (seatErr) return res.status(500).json({ success: false, error: "Seats generation error" });
                res.json({ success: true, message: "Bus & 30 Seats Added!", busId });
            });
        });
    });
});

// API: FIX SEATS
app.get("/api/admin/fix-seats", (req, res) => {
    const query = `INSERT INTO seats (bus_id, seat_number, seat_type, reserved_for) 
                    SELECT b.bus_id, n.seat_no, IF(b.bus_type LIKE '%Sleeper%', 'Sleeper', 'Seater'), 'General'
                    FROM buses b 
                    JOIN (SELECT 'L1' as seat_no UNION SELECT 'L2' UNION SELECT 'L3' UNION SELECT '1A' UNION SELECT '1B') n 
                    LEFT JOIN seats s ON b.bus_id = s.bus_id AND n.seat_no = s.seat_number 
                    WHERE s.seat_id IS NULL`;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "Fixed!", affectedRows: results.affectedRows });
    });
});

app.get("/api/health", (req, res) => db.query("SELECT 1", (err) => res.json({ status: err ? "Offline" : "Online" })));
app.get("/", (req, res) => res.send("Backend with Female Logic is Running!"));

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => console.log(`Server running on Port ${PORT}`));