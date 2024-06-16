select * 
from portfolioProject..CovidDeaths
Where continent is not null
order by 3,4;



/*select .* 
from portfolioProject..CovidVaccinations
order by 3,4;*/

--Select Data that we are going to be using

select location, date ,total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
Where continent is not null
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Showes Likelyhood of dying if you contract covid in your country
select location, date ,total_cases, total_deaths,(total_deaths/ total_cases)*100 AS DeathPercentage
from portfolioProject..CovidDeaths
Where location like'%states%'
order by 1,2;


--Looking at the total cases vs Population
--Shows what percentage of population got Covid
select location, date ,Population,total_cases ,(total_cases/ population)*100 AS PercentPopulationInfected
from portfolioProject..CovidDeaths
--Where location like'%states%'
order by 1,2;


-- Looking at country with highest infection rate comparied to Population
select location, Population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population))*100 AS 
	PercentPopulationInfected
from portfolioProject..CovidDeaths
--Where location like'%states%'
Group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Cout per Population
select location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
from portfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by location, population
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
from portfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select  SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
from portfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
--group by date
order by 1,2;

--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as numeric) )OVER (Partition by dea.location Order by dea.location,
	dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

--USE CTE

;WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) 
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as numeric) )OVER (Partition by dea.location Order by dea.location,
	dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

)
Select * ,(RollingPeopleVaccinated/Population)*100  as Percent_VAC
From PopvsVac


--TEMP TABLE
DROP TABLE IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as numeric) )OVER (Partition by dea.location Order by dea.location,
	dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select * ,(RollingPeopleVaccinated/Population)*100  as Percent_VAC
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as numeric) )OVER (Partition by dea.location Order by dea.location,
	dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
