SELECT *
FROM portefolioproject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM portefolioproject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portefolioproject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portefolioproject..CovidDeaths
where location like 'portugal'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT location,date, population, total_cases, (total_cases/population)*100 as infectionPercentage
FROM portefolioproject..CovidDeaths
--where location like 'portugal'
order by 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portefolioproject..CovidDeaths
--where location like 'portugal'
group by location,population
order by PercentPopulationInfected desc

-- let's break down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portefolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portefolioproject..CovidDeaths
where continent is not null
group by location,population
order by TotalDeathCount desc

-- Global numbers

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast( new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
FROM portefolioproject..CovidDeaths
--where location like 'portugal'
where continent is not null
--group by date
order by 1,2
--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM portefolioproject..CovidDeaths dea
Join portefolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portefolioproject..CovidDeaths dea
Join portefolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac

-- Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portefolioproject..CovidDeaths dea
Join portefolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
sELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM portefolioproject..CovidDeaths dea
Join portefolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from #PercentPopulationVaccinated