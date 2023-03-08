#Cargando los datos desde mi PC hacia la base de datos en MySQL
# Loading data in MySQL

load data local infile 'C:\\Users\\Javi\\Desktop\\DATA ANALYSIS PROJECT COVID\\Nashville Project\\Nashville data.csv'

into table nashville_data

fields terminated by ';'

enclosed by '"'

lines terminated by '\n'

ignore 1 rows;


-- show global variables like 'local_infile';

-- if it shows-

-- +---------------+-------+
-- | Variable_name | Value |
-- +---------------+-------+
-- | local_infile  |  OFF  |
-- +---------------+-------+
-- (this means local_infile is disable)

#mysql> SET GLOBAL local_infile=true;
-- Query OK, 0 rows affected (0.00 sec)

-- mysql> SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- +---------------+-------+
-- | Variable_name | Value |
-- +---------------+-------+
-- | local_infile  | ON    |
-- +---------------+-------+
-- 1 row in set (0.01 sec)

