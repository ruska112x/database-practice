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