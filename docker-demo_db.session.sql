SELECT l1.locality_name as l1_name,
    l1.locality_id as l1_id,
    l2.locality_id as l2_id,
    l2.locality_name as l2_name
FROM localities as l1
    join localities as l2 on l1.locality_id < l2.locality_id
    AND l1.locality_name <> l2.locality_name;