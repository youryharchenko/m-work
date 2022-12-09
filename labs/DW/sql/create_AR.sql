CREATE TABLE IF NOT EXISTS AR
(
    id INTEGER PRIMARY KEY,
    r INTEGER NOT NULL,
    a INTEGER NOT NULL,
    v INTEGER NOT NULL,
    FOREIGN KEY(r) REFERENCES R(id), 
    FOREIGN KEY(a) REFERENCES A(id), 
    FOREIGN KEY(v) REFERENCES V(id),
    UNIQUE(r, a) 
)
    