const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

router.get("/get-counts", async (req, res) => {
	try {
		const [users_count] = await pool.query(
			"SELECT COUNT(*) AS count FROM Users"
		);
		res.status(200).json({
			users_count: users_count[0].count || 0,
			products_count: 0, // Placeholder for products count
			orders_count: 0, // Placeholder for orders count
			total_sales: 0,
		});
	} catch (error) {
		console.error(error);
		res.status(500).json({ message: "Internal Server Error" });
	}
});

router.get("/get-users", async (req, res) => {
	try {
		const [rows] = await pool.query("SELECT * FROM Users");
		res.status(200).json(rows);
	} catch (error) {
		console.error(error);
		res.status(500).json({ message: "Internal Server Error" });
	}
});

module.exports = router;
