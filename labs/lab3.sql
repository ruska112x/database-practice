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