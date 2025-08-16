const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

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

module.exports = router;
