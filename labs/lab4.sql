---------------------------------------------------------------
-- 4.1
---------------------------------------------------------------
;
DROP FUNCTION IF EXISTS fllt_streak;
CREATE FUNCTION fllt_streak(needed_lt INT)
RETURNS TABLE (
    locality_type_id INT,
    longest_streak INT
) AS $$
DECLARE
    rec RECORD;
    streak INT := 0;
    max_streak INT := 0;
    my_cursor CURSOR FOR
        SELECT l1.locality_type_id
        FROM localities as l1
        ORDER BY l1.locality_id;
BEGIN
    open my_cursor;

    fetch my_cursor into rec;

    while found loop
        if (rec.locality_type_id = needed_lt) then
            streak := streak + 1;
        else if (rec.locality_type_id <> needed_lt) then
            if (streak > max_streak) then
                max_streak := streak;
                streak := 0;
            else
                streak := 0;
            end if;
        end if;
        end if;
        fetch my_cursor into rec;
    end loop;
    if (streak > max_streak) then
        max_streak := streak;
    end if;

    close my_cursor;
    RETURN QUERY VALUES(needed_lt, max_streak);
    end;
$$ LANGUAGE plpgsql;
SELECT * FROM fllt_streak(2);
---------------------------------------------------------------
-- 4.2 
---------------------------------------------------------------
;
CREATE TABLE IF NOT EXISTS "questions" (
    question text not null,
    answer_1 varchar(32) not null,
    answer_2 varchar(32) not null,
    answer_3 varchar(32) not null,
    difficult int not null
);
INSERT INTO "questions" VALUES
    ('1+1=?', '3', '1', '2', 1),
    ('2^2=?', '4', '8', '16', 1),
    ('Capital of the Russia?', 'Moscow', 'Saint-Petersburg', 'Leningrad', 1),
    ('First prime number?', '1', '2', '3', 2),
    ('sqrt(144)', '12', '-16', '+-12', 2),
    ('ln(1)', '-1', '0', '1', 3),
    ('Count of days in the year?', '365', '31', '365(366)', 1),
    ('10-8=?', '1', '3', '2', 3),
    ('7*3=?', '21', '49', '27', 3),
    ('56/8=?', '9', '-5', '7', 3),
    ('121/11=?', '-11', '0', '11', 2),
    ('4*3=?', '12', '13', '14', 2),
    ('3+3=?', '5', '6', '7', 1);
---------------------------------------------------------------
;
CREATE OR REPLACE FUNCTION
create_test(p_easy_percent INT, p_medium_percent INT, p_hard_percent INT, p_total_questions INT)
RETURNS TABLE(question TEXT, answer_1 varchar(32), answer_2 varchar(32), answer_3 varchar(32), difficult INT) AS $$
DECLARE
    easy_questions INT := (p_easy_percent * p_total_questions) / 100;
    medium_questions INT := (p_medium_percent * p_total_questions) / 100;
    hard_questions INT := (p_hard_percent * p_total_questions) / 100;

    cur_easy CURSOR FOR SELECT * FROM questions q WHERE q.difficult = 1 ORDER BY random() LIMIT easy_questions;
    cur_medium CURSOR FOR SELECT * FROM questions q WHERE q.difficult = 2 ORDER BY random() LIMIT medium_questions;
    cur_hard CURSOR FOR SELECT * FROM questions q WHERE q.difficult = 3 ORDER BY random() LIMIT hard_questions;

    r RECORD;
BEGIN
    CREATE TEMP TABLE tmp_table (question TEXT, answer_1 varchar(32), answer_2 varchar(32), answer_3 varchar(32), difficult INT) ON COMMIT DROP;

    OPEN cur_easy;
    LOOP
        FETCH cur_easy INTO r;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_table VALUES (r.question, r.answer_1, r.answer_2, r.answer_3, r.difficult);
    END LOOP;
    CLOSE cur_easy;

    OPEN cur_medium;
    LOOP
        FETCH cur_medium INTO r;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_table VALUES (r.question, r.answer_1, r.answer_2, r.answer_3, r.difficult);
    END LOOP;
    CLOSE cur_medium;

    OPEN cur_hard;
    LOOP
        FETCH cur_hard INTO r;
        EXIT WHEN NOT FOUND;
        INSERT INTO tmp_table VALUES (r.question, r.answer_1, r.answer_2, r.answer_3, r.difficult);
    END LOOP;
    CLOSE cur_hard;

    RETURN QUERY SELECT * FROM tmp_table ORDER BY random();
END;
$$ LANGUAGE plpgsql;
select * from create_test(20, 30, 50, 13);
---------------------------------------------------------------
-- 4.3
---------------------------------------------------------------
;
CREATE OR REPLACE FUNCTION shuffle_answers(answer_1 varchar(32), answer_2 varchar(32), answer_3 varchar(32))
RETURNS varchar(32)[] AS $$
DECLARE
    s_cursor CURSOR FOR SELECT * FROM (
        SELECT * FROM (
            SELECT answer_1 UNION
            SELECT answer_2 UNION
            SELECT answer_3
        )
        ORDER BY random()
    );
    answer varchar(32);
    answers varchar(32)[];
BEGIN
    OPEN s_cursor;
    FETCH s_cursor INTO answer;
    answers := array_append(answers, answer);
    FETCH s_cursor INTO answer;
    answers := array_append(answers, answer);
    FETCH s_cursor INTO answer;
    answers := array_append(answers, answer);
    CLOSE s_cursor;
    RETURN answers;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------
;
CREATE OR REPLACE FUNCTION random_test()
RETURNS TABLE(question TEXT, answer_1 varchar(32), answer_2 varchar(32), answer_3 varchar(32), difficult INT) AS $$
DECLARE
    r RECORD;
    answers varchar(32)[];
    my_cursor CURSOR FOR SELECT * FROM questions;
BEGIN
    CREATE TEMP TABLE tmp_table (question TEXT, answer_1 varchar(32), answer_2 varchar(32), answer_3 varchar(32), difficult INT) ON COMMIT DROP;
    
    OPEN my_cursor;
    LOOP
        FETCH my_cursor INTO r;
        EXIT WHEN NOT FOUND;
        answers := shuffle_answers(r.answer_1, r.answer_2, r.answer_3);
        INSERT INTO tmp_table VALUES (r.question, answers[1], answers[2], answers[3], r.difficult);
    END LOOP;
    CLOSE my_cursor;

    RETURN QUERY SELECT * FROM tmp_table ORDER BY random();
END;
$$ LANGUAGE plpgsql;
select * from random_test();
---------------------------------------------------------------
-- 4.4
---------------------------------------------------------------
;
CREATE OR REPLACE FUNCTION generate_and_analyze_data(num_records INT)
RETURNS TABLE (
    dataset TEXT,
    mean DOUBLE PRECISION,
    stddev DOUBLE PRECISION,
    median DOUBLE PRECISION
) AS $$
DECLARE
    avg_a DOUBLE PRECISION;
    min_a INT;
    max_a INT;
    r RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS data (
        id SERIAL PRIMARY KEY,
        a INT
    );
    TRUNCATE TABLE data RESTART IDENTITY;

    INSERT INTO data (a)
    SELECT floor(random() * 100 + 1)::int
    FROM generate_series(1, num_records);

    SELECT AVG(a) INTO avg_a FROM data;

    SELECT MIN(a), MAX(a) INTO min_a, max_a FROM data;

    CREATE TEMP TABLE IF NOT EXISTS data_prime (
        id_prime INT,
        a_prime INT
    );
    TRUNCATE TABLE data_prime RESTART IDENTITY;

    FOR r IN SELECT * FROM data LOOP
        INSERT INTO data_prime(id_prime, a_prime)
        VALUES (
            r.id,
            CASE 
               WHEN r.a > avg_a THEN min_a
               ELSE max_a
            END
        );
    END LOOP;

    RAISE NOTICE 'DATA';
    FOR r IN SELECT * FROM data LOOP
        RAISE NOTICE '%', to_json(r);
    END LOOP;
    RAISE NOTICE 'DATA_PRIME';
    FOR r IN SELECT * FROM data_prime LOOP
        RAISE NOTICE '%', to_json(r);
    END LOOP;

    RETURN QUERY
    WITH stats AS (
        SELECT 
            'data' AS dataset,
            AVG(a)::double precision AS mean,
            STDDEV(a)::double precision AS stddev,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a)::double precision AS median
        FROM data
    ),
    stats_prime AS (
        SELECT 
            'data_prime' AS dataset,
            AVG(a_prime)::double precision AS mean,
            STDDEV(a_prime)::double precision AS stddev,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a_prime)::double precision AS median
        FROM data_prime
    )
    SELECT * FROM stats
    UNION ALL
    SELECT * FROM stats_prime;

END;
$$ LANGUAGE plpgsql;
select * from generate_and_analyze_data(10);