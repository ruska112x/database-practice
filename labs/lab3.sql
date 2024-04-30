-- indexes
CREATE INDEX locality_name_index on localities (locality_name);
CREATE INDEX locality_population_index on localities (population);
CREATE INDEX locality_area_index on localities (area);
CREATE INDEX road_length on roads (length);
-- functions
CREATE FUNCTION before_insert_trigger_function() RETURNS TRIGGER AS $$ BEGIN IF LENGTH(NEW.locality_name) < 3 THEN RAISE EXCEPTION 'Значение в locality_name должно быть больше 2 ';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION after_insert_trigger_function() RETURNS TRIGGER AS $$ BEGIN RAISE NOTICE 'Новая запись добавлена: id = %',
NEW.locality_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION before_update_trigger_function() RETURNS TRIGGER AS $$ BEGIN IF LENGTH(NEW.locality_name) < 3 THEN RAISE EXCEPTION 'Значение в locality_name должно быть больше 2 ';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- triggers
CREATE TRIGGER before_insert_trigger BEFORE
INSERT ON localities FOR EACH ROW EXECUTE FUNCTION before_insert_trigger_function();
CREATE TRIGGER after_insert_trigger
AFTER
INSERT ON localities FOR EACH ROW EXECUTE FUNCTION after_insert_trigger_function();
CREATE TRIGGER before_update_trigger BEFORE
UPDATE ON localities FOR EACH ROW EXECUTE FUNCTION before_update_trigger_function();
-- procedures
-- START get_locations_with_roads
CREATE FUNCTION get_locations_with_roads() RETURNS TABLE (
    f_locality varchar(127),
    s_locality varchar(127),
    road_length int
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
SELECT l1.locality_name,
    l2.locality_name,
    r.length
FROM localities as l1
    left join roads as r on l1.locality_id = r.f_locality_id
    left join localities as l2 on r.s_locality_id = l2.locality_id;
END;
$$;
-- END get_locations_with_roads
-- START get_locality_with_all_roads
CREATE FUNCTION get_locality_with_all_roads() RETURNS TABLE (
    locality_id int,
    locality_name varchar(127),
    population int,
    area float,
    locality_type_id int,
    locality_trip_description_id int
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
SELECT *
FROM localities
WHERE locality_id in (
        SELECT f_locality_id
        FROM roads
        GROUP BY f_locality_id
        HAVING count(s_locality_id) = (
                SELECT count(*)
                FROM localities
                WHERE locality_type_id = 1
            )
    );
END;
$$;
-- END get_locality_with_all_roads
-- START get_density_of_locality_by_id
CREATE FUNCTION get_density_of_locality_by_id(p_id int) RETURNS TABLE (
    locality_name varchar(127),
    density float
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
SELECT locality_name,
    (population / area) as density
FROM localities
WHERE locality_id = p_id;
END;
$$;
-- END get_density_of_locality_by_id
-- START