CREATE TABLE IF NOT EXISTS c
(
    id INT AUTO_INCREMENT PRIMARY KEY,
    v INT NOT NULL UNIQUE,
    FOREIGN KEY(v) REFERENCES v(id)
)  ENGINE=INNODB;
    