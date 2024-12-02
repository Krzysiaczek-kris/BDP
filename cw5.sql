-- Tworzenie tabeli
CREATE TABLE obiekty
(
    id        SERIAL PRIMARY KEY,
    nazwa     TEXT     NOT NULL,
    geometria GEOMETRY NOT NULL
);

-- Dodawanie obiektów
INSERT INTO obiekty (nazwa, geometria)
VALUES ('obiekt1', ST_GeomFromText('CIRCULARSTRING(0 1, 1 1, 2 0, 3 1, 4 2, 5 1, 6 1)', 0)),
       ('obiekt2', ST_GeomFromText(
               'CURVEPOLYGON(CIRCULARSTRING(10 2, 10 6, 14 6, 16 4, 14 2, 12 0, 10 2), CIRCULARSTRING(11 2, 13 2, 11 2))',
               0)),
       ('obiekt3', ST_PolygonFromText('POLYGON((7 15, 10 17, 12 13, 7 15))', 0)),
       ('obiekt4', ST_LineFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)', 0)),
       ('obiekt5', ST_GeomFromText('MULTIPOINT((30 30 59), (38 32 234))', 0)),
       ('obiekt6', ST_Collect(
               ST_LineFromText('LINESTRING(1 1, 3 2)', 0),
               ST_PointFromText('POINT(4 2)', 0)
                   ));

-- Zadanie 2
WITH najkrotsza_linia AS (
    SELECT ST_ShortestLine(o1.geometria, o2.geometria) AS linia
    FROM obiekty o1, obiekty o2
    WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4'
)
SELECT ST_Area(ST_Buffer(linia, 5)) AS pole_bufora
FROM najkrotsza_linia;

-- Zadanie 3
-- Aktualizacja obiektu4, aby geometria była zamknięta
UPDATE obiekty
SET geometria = ST_AddPoint(geometria, ST_StartPoint(geometria))
WHERE nazwa = 'obiekt4';

-- Zamiana obiektu4 na poligon
UPDATE obiekty
SET geometria = ST_MakePolygon(geometria)
WHERE nazwa = 'obiekt4';

-- Zadanie 4
INSERT INTO obiekty (nazwa, geometria)
SELECT 'obiekt7', ST_Union(a.geometria, b.geometria)
FROM obiekty a, obiekty b
WHERE a.nazwa = 'obiekt3' AND b.nazwa = 'obiekt4';

-- Zadanie 5
SELECT SUM(ST_Area(ST_Buffer(geometria, 5))) AS pole_buforow
FROM obiekty
WHERE ST_GeometryType(geometria) NOT IN ('ST_CircularString', 'ST_CurvePolygon');
