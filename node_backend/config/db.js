const mysql = require("mysql2/promise");

// MySQL connection pool (recommended for async/await)
const pool = mysql.createPool({
	host: "localhost",
	user: "root", // your MySQL username
	password: "1920", // your MySQL password
	database: "wristified",
	waitForConnections: true,
	connectionLimit: 10,
	queueLimit: 0,
});

module.exports = pool;
