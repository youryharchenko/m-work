CREATE TABLE IF NOT EXISTS rc
(
    id INT PRIMARY KEY,
    r INT NOT NULL,
    cf INT NOT NULL,
    ct INT NOT NULL,
    FOREIGN KEY(r) REFERENCES r(id), 
    FOREIGN KEY(cf) REFERENCES c(id), 
    FOREIGN KEY(ct) REFERENCES c(id),
    UNIQUE(r, cf, ct) 
)
    