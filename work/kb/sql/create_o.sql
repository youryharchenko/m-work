CREATE TABLE IF NOT EXISTS o
(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    v BIGINT UNSIGNED NOT NULL UNIQUE,
    FOREIGN KEY(v) REFERENCES v(id)
)  ENGINE=INNODB;
    