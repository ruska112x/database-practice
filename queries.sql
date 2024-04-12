SELECT l1.locality_name, r.length, l2.locality_name
from localities as l1
    LEFT JOIN roads as r on l1.locality_id = r.f_locality_id
    LEFT JOIN localities as l2 on r.s_locality_id = l2.locality_id
WHERE r.f_locality_id IS not NULL
    AND r.s_locality_id IS not NULL;