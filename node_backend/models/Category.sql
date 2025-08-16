CREATE TABLE Category (
    id INT PRIMARY KEY auto_increment,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);
