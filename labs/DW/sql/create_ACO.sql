CREATE TABLE IF NOT EXISTS ACO
(
    id INTEGER PRIMARY KEY,
    co INTEGER NOT NULL,
    a INTEGER NOT NULL,
    v INTEGER NOT NULL,
    FOREIGN KEY(co) REFERENCES CO(id), 
    FOREIGN KEY(a) REFERENCES A(id), 
    FOREIGN KEY(v) REFERENCES V(id),
    UNIQUE(co, a) 
)
    