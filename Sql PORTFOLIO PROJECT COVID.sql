SELECT * FROM portfolioproject.coviddeathscsv
where continent is not null
order by 3,4;

UPDATE portfolioproject.coviddeathscsv
SET continent = NULLIF(continent, '');


#Select the data that we are going to be using.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject.coviddeathscsv
order by 1,2;

# Total cases vs Total Deaths

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject.coviddeathscsv
order by 1,2;

#Lookin at total cases vs total deaths
#Shows likelihood of dying if you contract COVID in your country

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
#show what % of population got Covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPct
FROM portfolioproject.coviddeathscsv
where location like "United Stat%"
order by 1,2;

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPct
FROM portfolioproject.coviddeathscsv
where location like "Argen%"
order by 1,2;

#Looking at countries with Highest infection rate compared to population

select location,population, max(total_cases) as TotalHasGottenCovid ,max(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject.coviddeathscsv
group by location,population
order by 4 desc;



#Showing countries with the highest death count per poupulation.

#con where continent is not null, sacamos las filas donde continent estaba null para que nos 
# devuelva todos los paises sin los continentes

select location, max(total_deaths)
from portfolioproject.coviddeathscsv
where continent is not null
group by location
order by 2 desc;

-- LETS BREAK THINGS DOWN BY CONTINENT 

#THIS IS THE CORRECT INFORMATION, NOT THE ONE BELOW.

select location, max(total_deaths)
from portfolioproject.coviddeathscsv
where continent is null
group by location
order by 2 desc;

select continent, max(total_deaths)
from portfolioproject.coviddeathscsv
where continent is not null
group by continent
order by 2 desc;

-- LETS BREAK THINGS DOWN BY CONTINENT 
-- Showing continents with the highest deat count per population.
select continent, max(total_deaths)
from portfolioproject.coviddeathscsv
where continent is not null
group by continent;

# GLOBAL NUMBERS


#TOTAL CASES CUMULATIVE ?
SELECT date, max(total_cases),max(total_deaths) ,MAX(total_deaths)/max(total_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
-- where location like "United Sta%" AND
where continent is not null
group by date
order by 1;

#TOTAL CASES PER DAY, NOT CUMULATIVE.
SELECT date, sum(new_cases) as new_cases,sum(new_deaths) as new_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
-- where location like "United Sta%" AND
where continent is not null
group by date
order by 1;

# TOTAL Death % around the globe	
SELECT  sum(new_cases) as new_cases,sum(new_deaths) as new_deaths ,sum(new_deaths)/sum(new_cases)*100 as DeathPct
FROM portfolioproject.coviddeathscsv
-- where location like "United Sta%" AND
where continent is not null
order by 1;

#JOINING COVIDDEATHS WITH COVIDVACCIONATION

select * from portfolioproject.coviddeathscsv as death
inner join portfolioproject.covidvaccinationcsv  as vacc
on    death.location = vacc.location
and     death.date = vacc.date;

#POPULATION VS VACCINATION

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

#POPULATION VS VACCINATION

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
#NOW WE CAN USE THE RollingPeopleVaccinated as a variable.
select *, (RollingPeopleVaccinated/population)*100 from popvsvacc;

-- UPDATE portfolioproject.covidvaccinationcsv
-- SET new_vaccinations = NULLIF(new_vaccinations, '');

#DOING THE SAME WITHOUT A DERIVED TABLE OR CTE.

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



#TEMPT TABLE

#create table

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
select *, (RollingPeopleVaccinated/population)*100 from
PercentPopoulationVaccinated where percentpopoulationvaccinated.Location like "Arg%";

-- select count(*) from percentpopoulationvaccinated;


#CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION.

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






 



