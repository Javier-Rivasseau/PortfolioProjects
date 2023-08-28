#Cargando los datos desde mi PC hacia la base de datos en MySQL
# Loading data in MySQL

load data local infile 'C:\\Users\\Javi\\Desktop\\DATA ANALYSIS PROJECT COVID\\Covid Project\\CovidVaccinationCSV.csv'

into table portfolioproject.covidvaccinationcsv

fields terminated by ';'

enclosed by '"'

lines terminated by '\n'

ignore 1 rows;


load data local infile 'C:\\Users\\Javi\\Desktop\\DATA ANALYSIS PROJECT COVID\\Covid Project\\CovidDeathsCSV.csv'

into table portfolioproject.coviddeathscsv

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


# 1- GLOBAL NUMBERS, TOTAL DEATHS, TOTAL CASES, DEATH PERCENTAGE SINCE START TO 7 FEBRUARY 2023
# NUMEROS GLOBALES, MUERTES TOTALES, CASOS TOTALES, PORCENTAJE DE MORTANDAD DESDE EL INICIO DE LA PANDEMIA HASTA EL 7 DE FEBRERO DE 2023

SELECT sum(portfolioproject.coviddeathscsv.new_deaths) as TotalDeaths, sum(portfolioproject.coviddeathscsv.new_cases) as TotalCases,
(sum(portfolioproject.coviddeathscsv.new_deaths)/sum(portfolioproject.coviddeathscsv.new_cases)*100) as DeathPercentage
 from coviddeathscsv where continent is not null
 ;
 
 # 2- GLOBAL NUMBERS BY CONTINENT, TOTAL DEATHS, TOTAL CASES, DEATH PERCENTAGE SINCE START TO 7 FEBRUARY 2023
# NUMEROS GLOBALES POR CONTINENTE, MUERTES TOTALES, CASOS TOTALES, PORCENTAJE DE MUERTES DESDE EL INICIO HASTA EL 7 DE FEBRERO DE 2023.
 
 # we take out where continent is null(with the clause where continent is not null) as they are not 
 # included in the above queries and want to stay consistent. (checked data with google.)
 # Usamos where continent is not null porque en este set de datos, los datos de continentes tambien se encuentran en location.
 # entonces queremos tener consistencia en los datos, (chequeados con google)
 
 SELECT continent, sum(portfolioproject.coviddeathscsv.new_deaths) as TotalDeaths, sum(portfolioproject.coviddeathscsv.new_cases) as TotalCases,
(sum(portfolioproject.coviddeathscsv.new_deaths)/sum(portfolioproject.coviddeathscsv.new_cases)*100) as DeathPercentage
 from coviddeathscsv 
 where continent is not null -- location not in ("World","Eurpean Union","International")
 group by continent
 order by 2 desc;
 
 # This is the same as the above querie
 # Con este querie, obtenemos el mismo resusltado que el querie anterior
 
  SELECT continent, sum(portfolioproject.coviddeathscsv.new_deaths) as TotalDeaths, sum(portfolioproject.coviddeathscsv.new_cases) as TotalCases,
(sum(portfolioproject.coviddeathscsv.new_deaths)/sum(portfolioproject.coviddeathscsv.new_cases)*100) as DeathPercentage
 from coviddeathscsv 
 where location not in ("World","Eurpean Union","International")
 group by continent
 order by 2 desc;
 
 # 3-  Select the highest infection count till the date , and the percent of the people infected till the date.(7 feb 2023)
 # Seleccionar la maxima cantidad de infectados y el porcentaje de infectados hasta la fecha. (7 feb 2023)
 
 select location, population, max(portfolioproject.coviddeathscsv.total_cases) as HighestInfectCount,
 max((portfolioproject.coviddeathscsv.total_cases/portfolioproject.coviddeathscsv.population)*100) as PercentPopulationInfected 
 from portfolioproject.coviddeathscsv
 where continent is not null
 group by location,population 
 order by PercentPopulationInfected desc;
 
 #4- Highest count of infection per date per country.
 # Maximo conteo y porcentaje de gente infectada por fecha y por lugar
 
   select location, population, cast(portfolioproject.coviddeathscsv.date as date), max(portfolioproject.coviddeathscsv.total_cases) as HighestInfectCount,
 max((portfolioproject.coviddeathscsv.total_cases/portfolioproject.coviddeathscsv.population)*100) as PercentPopulationInfected 
 from portfolioproject.coviddeathscsv
 where continent is not null
 group by location,population,date
 order by PercentPopulationInfected desc;
 
 
 


