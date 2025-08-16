const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const pool = require("../config/db");

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
