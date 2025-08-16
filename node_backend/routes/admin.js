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

// Get all categories
router.get("/categories", async (req, res) => {
	try {
		const [rows] = await pool.query(
			"SELECT * FROM Category ORDER BY created_at DESC"
		);
		const [category_count] = await pool.query(
			"SELECT COUNT(*) AS count FROM Category"
		);
		res.status(201).json({ rows, count: category_count[0].count });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Internal server error" });
	}
});

// Add new category
router.post("/category/add", async (req, res) => {
	const { name, description } = req.body;
	try {
		console.log("Adding category:", name, description);
		if (!name || !description) {
			return res
				.status(400)
				.json({ message: "Name and description are required" });
		}
		await pool.query("INSERT INTO Category (name, description) VALUES (?, ?)", [
			name,
			description,
		]);
		console.log("Category added");
		res.status(200).json({ message: "Category added successfully" });
	} catch (err) {
		console.error(err);
		res
			.status(500)
			.json({ message: "Internal server error", error: err.message });
	}
});

// Update category
router.put("/category/update/:id", async (req, res) => {
	const { id } = req.params;
	const { name, description } = req.body;
	try {
		await pool.query("UPDATE Category SET name=?, description=? WHERE id=?", [
			name,
			description,
			id,
		]);
		res.status(200).json({ message: "Category updated successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Internal server error" });
	}
});

// Delete category
router.delete("/category/del/:id", async (req, res) => {
	const { id } = req.params;
	try {
		await pool.query("DELETE FROM Category WHERE id=?", [id]);
		res.json({ message: "Category deleted successfully" });
	} catch (err) {
		console.error(err);
		res.status(500).json({ message: "Internal server error" });
	}
});

module.exports = router;
