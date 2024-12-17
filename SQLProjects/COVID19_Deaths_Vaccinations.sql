SELECT *
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4
;

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you have a covid in Kazakhstan
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio project]..CovidDeaths
WHERE location LIKE '%kazakhstan%'
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows percentage of people got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM [Portfolio project]..CovidDeaths
WHERE location LIKE '%kazakhstan%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Looking at countries with highest numbers of total deaths

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths DESC

--Looking at continents with highest numbers of total deaths

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM [Portfolio project]..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage 
FROM [Portfolio project]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
GO

CREATE VIEW PercentsPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio project]..CovidDeaths dea
JOIN [Portfolio project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * FROM dbo.PercentsPopulationVaccinated;
