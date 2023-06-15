CREATE TABLE IF NOT EXISTS aco
(
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    co BIGINT UNSIGNED NOT NULL,
    ac BIGINT UNSIGNED NOT NULL,
    v BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY(co) REFERENCES co(id), 
    FOREIGN KEY(ac) REFERENCES ac(id), 
    FOREIGN KEY(v) REFERENCES v(id),
    UNIQUE(co, ac) 
);
    