select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as Deathrate 
from PortfolioProject..CovidDeaths
where location like '%india%'	
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select location, date, total_cases, population, (total_cases / population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)*100) as PercentInfectionRate
from PortfolioProject..CovidDeaths
group by population, location
order by PercentInfectionRate desc 

-- Countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as deathCounts
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by deathCounts desc

Select location, MAX(cast(total_deaths as int)) as HighestDeathCounts
from PortfolioProject..CovidDeaths
where continent is not null

group by location

order by HighestDeathCounts desc;

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCounts
from PortfolioProject..CovidDeaths
where continent is not null

group by continent

order by HighestDeathCounts desc;

 GLOBAL Numbers

Select 
	--date,
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int)) / SUM(new_cases)) *100 as DeathPercentage
		
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


Select D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(Convert(bigint, V.new_vaccinations)) Over (PARTITION by D.location Order by D.location, D.date ) as RollingPeopleVaccinated,
	
from PortfolioProject..CovidDeaths D
join PortfolioProject..covidVaccinations V 
	On D.location = V.location
	and D.date = V.date
where D.continent is not null

order by 2,3

--USE Common Table Expression (CTE)

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(Convert(bigint, V.new_vaccinations)) Over (PARTITION by D.location Order by D.location, D.date ) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths D
join PortfolioProject..covidVaccinations V 
	On D.location = V.location
	and D.date = V.date
where D.continent is not null

--order by 2,3
)
Select *, (RollingPeopleVaccinated / population) *100 as PercentVaccinated
from PopVsVac

-- TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(Convert(bigint, V.new_vaccinations)) Over (PARTITION by D.location Order by D.location, D.date ) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths D
join PortfolioProject..covidVaccinations V 
	On D.location = V.location
	and D.date = V.date
where D.continent is not null

Select *, (RollingPeopleVaccinated / population) *100 as PercentVaccinated
from #PercentPopulationVaccinated

--Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
	,SUM(Convert(bigint, V.new_vaccinations)) Over (PARTITION by D.location Order by D.location, D.date ) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths D
join PortfolioProject..covidVaccinations V 
	On D.location = V.location
	and D.date = V.date
where D.continent is not null

--order by 2,3
 DROP VIEW PercentPopulationVaccinated
