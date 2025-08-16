require("dotenv").config();
const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/auth");
const adminRoutes = require("./routes/admin");

// app configuration
const app = express();
app.use(
	cors({
		origin: "*",
		methods: ["GET", "POST", "PUT", "DELETE"],
		allowedHeaders: ["Content-Type"],
	})
);
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// API endpoints
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);

// Start server
app.listen(5000, () => console.log("Server running on http://localhost:5000"));
