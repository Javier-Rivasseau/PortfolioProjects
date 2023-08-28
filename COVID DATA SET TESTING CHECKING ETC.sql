# Looking the data
# Mirando los datos
SELECT * FROM portfolioproject.coviddeathscsv
where continent is not null
order by 3,4;


#Select the data that we are going to be using.
# Seleccionado los datos que vamos a usar.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject.coviddeathscsv
order by 1,2;

# Total cases vs Total Deaths
# Casos totales vs muertes totales.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject.coviddeathscsv
order by 1,2;

#Looking at total cases vs total deaths
#Shows likelihood of dying if you contract COVID in your country
# Comparando casos totales vs muertes totales.
# Mostrar la probabilidad de morir si te contagias de COVID en tu país.

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
where location like "United Sta%"
order by 1,2;

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
where location like "Argen%" AND
date like "2022%"
order by 1,2;


# Looking at the total cases vs the population.
# show what % of population got Covid
# Mirando los casos totales vs la población.
# mostrar que % de la población se contagió con COVID.

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPct
FROM portfolioproject.coviddeathscsv
where location like "United Stat%"
order by 1,2;

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPct
FROM portfolioproject.coviddeathscsv
where location like "Argen%"
order by 1,2;

#Looking at countries with Highest infection rate compared to population and the percentaje.
# Mirando países con alta tasa de contagiados de covid vs la población y porcentaje de infectados.

select location,population, max(total_cases) as TotalHasGottenCovid ,max(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject.coviddeathscsv
group by location,population
order by 4 desc;



#Showing countries with the highest death count per poupulation.
#where continent is not null, we take out all of the rows where continent == null.
# Mostrando países con alto numero de muertes por covid por población
# donde el dato de continente no es nulo, para poder sacar las filas donde el continente es nulo.


select location, max(total_deaths)
from portfolioproject.coviddeathscsv
where continent is not null
group by location
order by 2 desc;

-- LETS BREAK THINGS DOWN BY CONTINENT 
-- Separemos por continente.

# Deaths by Countries
# Muertes por país.
select location, sum(new_deaths) as Total_death_count
from portfolioproject.coviddeathscsv
where continent  is not null
and location not in("World","High income","Upper middle income","Lower middle income",'European Union','International')
group by location
order by 2 desc;

#Death count by continent
#Muertes por continente

select continent, sum(new_deaths) as Death_count_by_Continent
from portfolioproject.coviddeathscsv
where continent is not null
group by continent
order by 2 desc;

# GLOBAL NUMBERS
#Numeros GLOBALES

#TOTAL CASES PER DAY, NOT CUMULATIVE.
#Casos totales por día, no acumulativo.

SELECT date, sum(new_cases) as new_cases,sum(new_deaths) as new_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
-- where location like "United Sta%" AND
where continent is not null
group by date
order by 1 desc;

# TOTAL infected, TOTAL DEATHS and TOTAL Death % around the globe
# Total de infectados, total de muertos y Porcentaje total de muertos alrededor del globo	
SELECT  sum(new_cases) as new_cases,sum(new_deaths) as new_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
-- where location like "United Sta%" AND
where continent is not null
order by 1;

#JOINING COVIDDEATHS WITH COVIDVACCIONATION
# Uniendo dos tablas.

select * from portfolioproject.coviddeathscsv as death
inner join portfolioproject.covidvaccinationcsv  as vacc
on    death.location = vacc.location
and     death.date = vacc.date;

# POPULATION VS VACCINATION
# POBLACION VS VACUNACION
# Make a new column "RollingPeopleVaccinated", adding up the people who are vaccinated as they are vaccinated
# separated by country.
# Hacer una nueva columna "RollingPeopleVaccinated", que vaya sumando la gente que se va vacunando a medida que lo vaya haciendo
# separado por País.

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by death.location order by death.date) as RollingPeopleVaccinated
from portfolioproject.coviddeathscsv as death
join portfolioproject.covidvaccinationcsv  as vacc
on  death.location = vacc.location
and   death.date = vacc.date
where death.continent is not null
order by 2,3;

#NOW WE WANT TO USE THE ROLLINGPEOPLEVACCINATED AS A VARIABLE SO WE CAN DIVIDE IT BY THE POPULATION. FOR
# THIS WE NEED TO CREATE A CTE or derived table. (Common Table expresion )

# Ahora queremos usar la columna "RollingPeopleVaccinated",dado que como vimos
# en el querie anterior, no podemos dividirla por la población para poder conocer el porcentaje de gente vacunada
# para poder hacer esto creamos una CTE o tabla común de expresion.


#POPULATION VS VACCINATION
# POBLACION VS VACCINATION
with PopvsVacc (Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from portfolioproject.coviddeathscsv as death
join portfolioproject.covidvaccinationcsv  as vacc
on  death.location = vacc.location
and   death.date = vacc.date
where death.continent is not null 
-- and death.location like "Argen%"
order by 2,3
)

#NOW WE CAN USE THE column RollingPeopleVaccinated so we can know the percentage.
#AHORA SI PODEMOS USAR LA COLUMNA PARA PODER CONOCER EL PORCENTAJE
select *, (RollingPeopleVaccinated/population)*100 from popvsvacc;


#DOING THE SAME WITHOUT A DERIVED TABLE OR CTE.
# HACER LO MISMO QUE LO ANTERIOR, PERO SIN LA TABLA COMUN DE EXPRESION.

-- select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
-- sum(vacc.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated,
-- (sum(vacc.new_vaccinations) over (partition by death.location order by death.location,death.date) / death.population) * 100 as PercentageVaccinated
-- from portfolioproject.coviddeathscsv as death
-- join portfolioproject.covidvaccinationcsv  as vacc
-- on  death.location = vacc.location
-- and   death.date = vacc.date
-- where death.continent is not null 
-- and death.location like "Argen%"
-- order by 2,3



#TEMPT TABLE (Temporary table)
# 			  Tabla temporaria

#create table
#creamos una tabla

DROP table IF exists PercentPopoulationVaccinated;
Create table PercentPopoulationVaccinated
 ( 
 Continent varchar(255),
 Location varchar(255),
 Date datetime,
 Population bigint,
 New_Vaccinations bigint,
 RollingPeopleVaccinated bigint
 )
;
#Insert all the data, including that column RollingPeopleVaccinated that we could not calculate
#Insertamos toda la data, incluso la columna RollingPeopleVaccinated que no podíamos realizar cálculos.
 insert into PercentPopoulationVaccinated
 (
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by death.location order by death.location,death.date) 
as RollingPeopleVaccinated
from portfolioproject.coviddeathscsv as death
join portfolioproject.covidvaccinationcsv  as vacc
on  death.location = vacc.location
and   death.date = vacc.date
where death.continent is not null 
-- and death.location like "Argen%"
order by 2,3

)
;
# Testing the TEMPT TABLE with Argentina data.
# Probando la tabla temporaria con datos de Argentina

select *, (RollingPeopleVaccinated/population)*100 from
PercentPopoulationVaccinated where percentpopoulationvaccinated.Location like "Arg%";

-- select count(*) from percentpopoulationvaccinated;


#CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION.
#CREANDO UNA VIEW PARA ALMACENAR LOS DATOS PARA VERLOS LUEGO.

create view PercentPopoulationVaccinatedView as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by death.location order by death.location,death.date) 
as RollingPeopleVaccinated
from portfolioproject.coviddeathscsv as death
join portfolioproject.covidvaccinationcsv  as vacc
on  death.location = vacc.location
and   death.date = vacc.date
where death.continent is not null 
-- and death.location like "Argen%"
-- order by 2,3






 



