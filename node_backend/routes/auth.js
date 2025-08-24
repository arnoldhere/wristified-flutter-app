const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/db");
const twilio = require("twilio");

// Twilio credentials (store in .env)
const accountSid = process.env.TWILIO_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhone = process.env.TWILIO_PHONE;
const client = twilio(accountSid, authToken);

// temporary OTP store (use Redis in production optional)
let otpStore = {};

// SIGNUP
router.post("/signup", async (req, res) => {
	try {
		const { fname, lname, email, phone, password } = req.body;

		if (!fname || !lname || !email || !phone || !password) {
			return res.status(400).json({ message: "All fields are required" });
		}

		// Check if user exists
		const [rows] = await pool.query("SELECT * FROM Users WHERE email = ?", [
			email,
		]);
		if (rows.length > 0) {
			return res.status(400).json({ message: "User already exists" });
		}

		// Hash password
		const hashedPassword = await bcrypt.hash(password, 10);

		// Insert user
		await pool.query(
			"INSERT INTO Users (fname, lname, email, phone, password, role) VALUES (?, ?, ?, ?, ?, 'user')",
			[fname, lname, email, phone, hashedPassword]
		);

		console.log("User created");
		res.status(201).json({ message: "User created" });
	} catch (error) {
		console.error(error);
		res.status(500).json({ message: "Internal Server Error" });
	}
});

// LOGIN
router.post("/login", async (req, res) => {
	try {
		const { email, password } = req.body;

		// Find user
		const [rows] = await pool.query("SELECT * FROM Users WHERE email = ?", [
			email,
		]);
		const user = rows[0];

		if (!user) {
			return res
				.status(400)
				.json({ success: false, message: "User not found" });
		}

		// Check password
		const isMatch = await bcrypt.compare(password, user.password);
		if (!isMatch) {
			return res
				.status(400)
				.json({ success: false, message: "Invalid credentials" });
		}

		// Generate JWT
		const token = jwt.sign(
			{ id: user.id, role: user.role },
			process.env.JWT_SECRET,
			{ expiresIn: "1d" }
		);

		console.log("User logged in successfully");
		return res.status(200).json({
			success: true,
			token,
			user: {
				id: user.id,
				email: user.email,
				name: user.fname,
				role: user.role,
			},
		});
	} catch (error) {
		console.error(error);
		return res.status(500).json({ success: false, message: "Server error" });
	}
});

// Generate and send OTP
router.post("/verify-phone", async (req, res) => {
	try {
		const { phone } = req.body;
		if (!phone) {
			return res.status(400).json({ message: "Phone number is required" });
		}

		// Find user
		const [rows] = await pool.query("SELECT * FROM Users WHERE phone = ?", [
			phone,
		]);
		if (rows.length === 0) {
			return res
				.status(404)
				.json({ exists: false, message: "Phone does not exist" });
		}

		const user = rows[0];

		// Check if existing OTP is still valid (within 5 mins)
		if (user.otp && user.otp_created_at) {
			const otpCreatedAt = new Date(user.otp_created_at);
			const now = new Date();
			const diffMinutes = (now - otpCreatedAt) / 1000 / 60;

			if (diffMinutes < 5) {
				return res.status(200).json({
					exists: true,
					message: "Check message, OTP is already sent",
				});
			}
		}

		// Generate new OTP
		const otp = Math.floor(100000 + Math.random() * 900000).toString();

		// Store OTP in DB
		await pool.query(
			"UPDATE Users SET otp = ?, otp_created_at = NOW() WHERE phone = ?",
			[otp, phone]
		);

		// Send SMS
		const formattedPhone = phone.startsWith("+") ? phone : `+91${phone}`;
		console.log(`Generated OTP for ${phone}: ${otp}`);

		await client.messages.create({
			body: `Dear sir/madam,\nYour OTP for reset password: ${otp}. Do not share it with anyone.\n\n- Wristified`,
			from: twilioPhone,
			to: formattedPhone,
		});

		return res.status(200).json({
			exists: true,
			message: "OTP sent to your phone....",
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({ message: "Internal Server Error" });
	}
});

// Verify OTP
router.post("/verify-otp", async (req, res) => {
	try {
		const { phone, otp } = req.body;
		if (!phone || !otp) {
			return res.status(400).json({ message: "Phone and OTP are required" });
		}

		const [rows] = await pool.query(
			"SELECT otp, otp_created_at FROM Users WHERE phone = ?",
			[phone]
		);
		if (rows.length === 0) {
			return res.status(404).json({ message: "User not found" });
		}

		const user = rows[0];
		if (!user.otp || !user.otp_created_at) {
			return res
				.status(400)
				.json({ message: "No OTP found. Please request again." });
		}

		const otpCreatedAt = new Date(user.otp_created_at);
		const now = new Date();
		const diffMinutes = (now - otpCreatedAt) / 1000 / 60;

		if (diffMinutes > 5) {
			return res.status(400).json({ success: false, message: "OTP expired" });
		}

		if (user.otp !== otp) {
			return res.status(400).json({ success: false, message: "Invalid OTP" });
		}

		// Clear OTP after successful verification
		await pool.query(
			"UPDATE Users SET otp = NULL, otp_created_at = NULL WHERE phone = ?",
			[phone]
		);

		return res.json({ success: true, message: "OTP verified" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Internal Server Error" });
	}
});

// Reset Password
router.post("/reset-password", async (req, res) => {
	try {
		const { phone, password } = req.body;
		if (!phone || !password) {
			return res
				.status(400)
				.json({ message: "Phone and new password are required" });
		}

		const hashedPassword = await bcrypt.hash(password, 10);

		await pool.query(
			"UPDATE Users SET password = ?, otp = NULL, otp_created_at = NULL WHERE phone = ?",
			[hashedPassword, phone]
		);

		res.json({ message: "Password updated successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Server error" });
	}
});

module.exports = router;
