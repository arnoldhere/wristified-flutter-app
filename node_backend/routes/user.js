const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

// Get all categories
router.get("/get-all-categories", async (req, res) => {
	try {
		const [categories] = await pool.query(
			"SELECT * FROM Category ORDER BY created_at DESC"
		);
		const [category_count] = await pool.query(
			"SELECT COUNT(*) AS count FROM Category"
		);
		res.status(200).json({ categories, count: category_count[0].count });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Internal server error" });
	}
});

module.exports = router;
