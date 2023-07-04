SELECT *
FROM PortFolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortFolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

--SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, Population
--FROM PortFolioProject..CovidDeaths$
--ORDER BY 1,2

--Looking at the total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT LOCATION, DATE, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths$
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

--looking at the total cases versus populations
-- Shows what percentage of population got covid

SELECT LOCATION, DATE, total_cases, population, (total_cases/population)*100 as PercentOfPopulationInfected
FROM PortFolioProject..CovidDeaths$
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

--Looking at Countries with Higest Infecction Rate Compared to Population
SELECT LOCATION, POPULATION, MAX(total_cases) as HighContractionCount, MAX(total_cases/population)*100 as 
   PercentOfPopulationInfected
FROM PortFolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
GROUP BY LOCATION, POPULATION
ORDER BY PercentOfPopulationInfected DESC

-- Showing Countries with The Highest Death counts Per Population

SELECT LOCATION, MAX(CAST(Total_Deaths as int)) as TotalDeathCount
   FROM PortFolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
WHERE continent is not null
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the higest death count per population

SELECT continent, MAX(CAST(Total_Deaths as int)) as TotalDeathCount
   FROM PortFolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Global Numbers

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, 
SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
WHERE Continent is not null
--GROUP BY DATE
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*
From PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH POPVSVAC (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM POPVSVAC



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100 as Percentage
FROM #PercentPopulationVaccinated


-- Creating view to Store data for later visualzations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition By dea.location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortFolioProject..CovidDeaths$ dea
join PortFolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated