CREATE EXTENSION postgis;

-- Zadanie 1
SELECT t2019.*
FROM t2019_kar_buildings t2019
         LEFT JOIN t2018_kar_buildings t2018
                   ON t2019.gid = t2018.gid
WHERE t2018.gid IS NULL;

SELECT t2019.*
FROM t2019_kar_buildings t2019
         INNER JOIN t2018_kar_buildings t2018
                    ON t2019.gid = t2018.gid
WHERE NOT ST_Equals(t2019.geom, t2018.geom);

-- Zadanie 2
WITH new_pois AS (SELECT t2019_poi.*
                  FROM T2019_KAR_POI_TABLE t2019_poi
                           LEFT JOIN T2018_KAR_POI_TABLE t2018_poi
                                     ON t2019_poi.poi_id = t2018_poi.poi_id
                  WHERE t2018_poi.poi_id IS NULL),
     target_buildings AS (SELECT t2019.*
                          FROM t2019_kar_buildings t2019
                                   LEFT JOIN t2018_kar_buildings t2018
                                             ON t2019.gid = t2018.gid
                          WHERE t2018.gid IS NULL

                          UNION

                          SELECT t2019.*
                          FROM t2019_kar_buildings t2019
                                   INNER JOIN t2018_kar_buildings t2018
                                              ON t2019.gid = t2018.gid
                          WHERE NOT ST_Equals(t2019.geom, t2018.geom))
SELECT poi.type, COUNT(*) AS poi_count
FROM new_pois poi
         JOIN target_buildings b
              ON ST_DWithin(poi.geom, b.geom, 500)
GROUP BY poi.type;

-- Zadanie 3
-- UPDATE T2019_KAR_STREETS
-- SET geom = ST_SetSRID(geom, 4326)
-- WHERE ST_SRID(geom) = 0;
DO
$$
    DECLARE
        cols text;
    BEGIN
        SELECT string_agg(column_name, ', ')
        INTO cols
        FROM information_schema.columns
        WHERE table_name = 't2019_kar_streets'
          AND column_name != 'geom';

        EXECUTE format(
                'CREATE TABLE streets_reprojected AS SELECT %s, ST_Transform(geom, 3068) AS geom FROM T2019_KAR_STREETS;',
                cols);
    END
$$;

-- Zadanie 4
CREATE TABLE input_points
(
    id   SERIAL PRIMARY KEY,
    geom geometry
);

INSERT INTO input_points(geom)
VALUES ('POINT(8.36093 49.03174)'),
       ('POINT(8.39876 49.00644)');

-- Zadanie 5
UPDATE input_points
SET geom = ST_SetSRID(geom, 3068);

-- Zadanie 6
WITH reprojected_nodes AS (SELECT *,
                                  ST_Transform(geom, 3068) AS geom_3068
                           FROM T2019_STREET_NODE),
     input_line AS (SELECT ST_MakeLine(geom ORDER BY id) AS line_geom
                    FROM input_points)
SELECT rn.*
FROM reprojected_nodes rn,
     input_line il
WHERE ST_DWithin(rn.geom_3068, il.line_geom, 200);

-- Zadanie 7
SELECT COUNT(DISTINCT s.poi_id) AS sporting_goods_store_count
FROM T2019_KAR_POI_TABLE s
         JOIN T2019_KAR_POI_TABLE p
              ON ST_DWithin(s.geom, p.geom, 300)
WHERE s.type = 'Sporting Goods Store';

-- Zadanie 8
CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM T2019_KAR_RAILWAYS r
         JOIN T2019_KAR_WATER_LINES w
              ON ST_Intersects(r.geom, w.geom);