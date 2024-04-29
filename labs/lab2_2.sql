-- 1
SELECT *
FROM localities
WHERE locality_id IN (
        SELECT f_locality_id
        FROM roads
        GROUP BY f_locality_id
        HAVING count(s_locality_id) > 1
    );
-- 2
SELECT *
FROM localities
WHERE locality_id IN (
        SELECT f_locality_id
        FROM roads
        GROUP BY f_locality_id
        HAVING count(s_locality_id) = (
                SELECT count(*)
                FROM localities
                WHERE locality_type_id = 1
            )
    );
-- 3
select s_locality_id
from roads as r1
group by s_locality_id
having count(f_locality_id) = (
        select count(distinct f_locality_id)
        from roads as r2
        where r2.f_locality_id <> r1.s_locality_id
    );
-- 4
SELECT *
FROM localities
WHERE locality_id NOT IN (
        SELECT f_locality_id
        FROM roads
        WHERE s_locality_id = 1
    );
-- 5
select *
from localities as l1
where locality_id in (
        select f_locality_id
        from roads as r1
        group by f_locality_id
        having r1.f_locality_id = l1.locality_id
            and avg(length) > (
                select avg(length)
                from roads
            )
    );