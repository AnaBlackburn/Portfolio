
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Deaths vs. Total Cases
SELECT location, date, total_cases, new_cases, total_deaths, population, 
	(total_deaths/total_cases)*100 AS 'DeathPercentage'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs. Population
SELECT location, date, total_cases, new_cases, total_deaths, population, 
	(total_cases/population)*100 AS 'InfectedPopulationPercentage'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Countries with the highest infection rate vs. population
SELECT location, MAX(total_cases) AS 'HighestInfectionRate', MAX((total_cases/population))*100 AS 'HighestInfectionPercentage'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Countries with the highest death count vs. population
SELECT location, SUM(total_deaths) AS 'HighestDeathCount'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Death count per continent
SELECT continent, MAX(total_deaths) AS 'DeathCount'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global Death Percentage by Date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 2) as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
	AND new_cases > 0
GROUP BY date
ORDER BY 1,2

-- Total Vaccinations Per Day By Location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Percentage of Population Vaccinated Per Day By Location
WITH PopVsVac AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated,
	MAX(CONVERT(bigint, vac.people_fully_vaccinated)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
	FROM CovidPortfolioProject..CovidDeaths dea
	JOIN CovidPortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL)
SELECT *, (TotalVaccinations/Population)*100 AS PercentageVaccinated
FROM PopVsVac
ORDER BY 2,3

-- Percentage of Vaccinated Population Per Location
-- Some countries are showing as higher than 100% vaccination rate, this could be because their population number is not updated since the population number is constinent despite the dates
SELECT dea.location, AVG(dea.population) AS population, MAX(CONVERT(bigint, vac.people_fully_vaccinated)) AS TotalVacNum,
ROUND((MAX(CONVERT(bigint, vac.people_fully_vaccinated))/AVG(dea.population))*100,2) AS PercentTotalVac
FROM CovidPortfolioProject..CovidVaccinations vac
JOIN CovidPortfolioProject..CovidDeaths dea
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location
ORDER BY dea.location

--Temp Table for Percentage of Population Vaccinated Per Day By Location

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
People_fully_vaccinated numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated,
MAX(CONVERT(bigint, vac.people_fully_vaccinated)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalVaccinations/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


--Creating views to store data for later vizualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated,
MAX(CONVERT(bigint, vac.people_fully_vaccinated)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated



CREATE VIEW PercentageOfDeaths AS 
SELECT location, date, total_cases, new_cases, total_deaths, population, 
	(total_deaths/total_cases)*100 AS 'DeathPercentage'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM PercentageOfDeaths
ORDER BY 1,2


CREATE VIEW PercentageOfPopulationInfected AS
SELECT location, date, total_cases, new_cases, total_deaths, population, 
	(total_cases/population)*100 AS 'InfectedPopulation(%)'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM PercentageOfPopulationInfected
ORDER BY 1,2

CREATE VIEW HighestInfectionRate AS
SELECT location, MAX(total_cases) AS 'HighestInfectionRate', MAX((total_cases/population))*100 AS 'HighestInfectionPercentage'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

SELECT *
FROM HighestInfectionRate
ORDER BY 2 DESC

CREATE VIEW HighestDeathCount AS
SELECT location, SUM(total_deaths) AS 'HighestDeathCount'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

SELECT *
FROM HighestDeathCount
ORDER BY 2 DESC

CREATE VIEW ContinentDeathCount AS
SELECT continent, MAX(total_deaths) AS 'DeathCount'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

SELECT *
FROM ContinentDeathCount
ORDER BY 2 DESC