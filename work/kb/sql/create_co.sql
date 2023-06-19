CREATE TABLE IF NOT EXISTS co
(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    c BIGINT UNSIGNED NOT NULL,
    o BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY(c) REFERENCES c(id), 
    FOREIGN KEY(o) REFERENCES o(id),
    UNIQUE(c, o) 
)  ENGINE=INNODB;
 