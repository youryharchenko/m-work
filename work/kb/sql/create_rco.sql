CREATE TABLE IF NOT EXISTS rco
(
    id INT PRIMARY KEY,
    rc INT NOT NULL,
    cof INT NOT NULL,
    cot INT NOT NULL,
    FOREIGN KEY(rc) REFERENCES rc(id), 
    FOREIGN KEY(cof) REFERENCES co(id), 
    FOREIGN KEY(cot) REFERENCES co(id),
    UNIQUE(rc, cof, cot) 
);
  