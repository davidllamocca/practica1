CREATE TABLE ProductosCredito (
    Id INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Tea DECIMAL(5,4) NOT NULL,
    ComisionPct DECIMAL(5,4) NOT NULL,
    MinMeses INT NOT NULL,
    MaxMeses INT NOT NULL
);

INSERT INTO ProductosCredito (Id, Nombre, Tea, ComisionPct, MinMeses, MaxMeses) VALUES
(1, 'Crédito Clásico',     0.1800, 0.0080,  6, 60),
(2, 'Crédito Premium',     0.1450, 0.0060,  6, 60),
(3, 'Crédito Vehicular',   0.1290, 0.0050, 12, 72),
(4, 'Crédito Educación',   0.1650, 0.0070,  6, 48),
(5, 'Crédito Rápido',      0.2500, 0.0100,  3, 24);
