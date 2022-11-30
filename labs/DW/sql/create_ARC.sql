CREATE TABLE IF NOT EXISTS ARC
(
    id INTEGER PRIMARY KEY,
    rc INTEGER NOT NULL,
    a INTEGER NOT NULL,
    v INTEGER NOT NULL,
    FOREIGN KEY(rc) REFERENCES RC(id), 
    FOREIGN KEY(a) REFERENCES A(id), 
    FOREIGN KEY(v) REFERENCES V(id),
    UNIQUE(rc, a, v) 
)
    