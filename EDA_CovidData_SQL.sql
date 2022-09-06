select * from dbo.CovidDeaths
order by 2,3;
--- Select data that we are going to be using 
select location, date, total_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2;
--- looking at total_cases and total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from dbo.CovidDeaths
where location like '%states%'
order by 1,2;

---looking at Total cases vs population 
--- show what percentage  of population got Covid 
select location,population, date, total_cases, (total_cases/population)*100 as DeathPercentage 
from dbo.CovidDeaths
where location like '%states%'
order by 1,2;

---looking at  Countries with Highest Infection Rate compared to Population 
select location, population, Max(total_cases)  as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from dbo.CovidDeaths
Group by location, population
order by HighestInfectionCount desc

--- showing country which highest deaths count  per population 
select location, Max(cast(total_deaths as int))  as TotalDeathsCount, Max((total_deaths/population))*100 as PercentagePopulationDeaths
from dbo.CovidDeaths
where continent is not null 
Group by location
order by TotalDeathsCount desc

---LET'S BREAK IT DOWN BY CONTINENT
select continent, Max(cast(total_deaths as int))  as TotalDeathsCount, Max((total_deaths/population))*100 as PercentagePopulationDeaths
from dbo.CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathsCount desc
--- showing continents with the highest death count per population 
select continent, Max(cast(total_deaths as int))  as TotalDeathsCount, Max((total_deaths/population))*100 as PercentagePopulationDeaths
from dbo.CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathsCount desc

--- Global Covid Cases and Deaths 

select sum(new_cases) as TotalNewcases, sum(cast(new_deaths as int)) as TotalNewdeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathsPercentage  --total_cases, (total_cases/population)*100 as DeathPercentage 
from dbo.CovidDeaths
where continent is not null
--where location like '%states%'
--group by date
order by 1,2;

---LET'S BREAK DOWN WITH COVIDVACINATION TABLE 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidData..CovidDeaths cd  
join CovidData..CovidVacination cv
on cd.location =cv.location 
and cd.date = cv.date
where cd.continent is not null 
order by 2,3 

---Using CTE 
With CTE_Population_Vaccinated(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidData..CovidDeaths cd  
join CovidData..CovidVacination cv
on cd.location =cv.location 
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3 
)

select * 
from CTE_Population_Vaccinated;

---USING THE TEMPORARY TABLE FOR DATA 

Drop table if exists #percent_population_vaccinated 
Create table #percent_population_vaccinated 
(
continent nvarchar (255),
location nvarchar (255),
date datetime ,
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric 
)
Insert into #percent_population_vaccinated 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidData..CovidDeaths cd  
join CovidData..CovidVacination cv
on cd.location =cv.location 
and cd.date = cv.date
where cd.continent is not null 
order by 2,3 


select *, (RollingPeopleVaccinated/ population)*100 as percenteage_vaccinated 
from #percent_population_vaccinated 
 
 ---USING VIEW FOR DATA 
 
 create view percent_population_vaccinated as 
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(bigint, cv.new_vaccinations)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidData..CovidDeaths cd  
join CovidData..CovidVacination cv
on cd.location =cv.location 
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3 

select * from percent_population_vaccinated