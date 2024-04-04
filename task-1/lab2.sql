SELECT locality_name
FROM localities
WHERE population >= 500000;
SELECT locality_name
FROM localities
WHERE area <= 500;
-- except
SELECT locality_name
FROM localities
WHERE population >= 500000
EXCEPT
SELECT locality_name
FROM localities
WHERE area <= 500;
-- intersect
SELECT locality_name
FROM localities
WHERE population >= 500000
INTERSECT
SELECT locality_name
FROM localities
WHERE area <= 500;
-- union
SELECT locality_name
FROM localities
WHERE population >= 1000000
UNION
SELECT locality_name
FROM localities
WHERE area >= 1000;