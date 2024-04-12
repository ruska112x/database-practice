SELECT l1.locality_name,
    l1.locality_id,
    l2.locality_id,
    l2.locality_name
FROM localities as l1
    join localities as l2 on l1.locality_id <> l2.locality_id;