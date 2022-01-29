SELECT *
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..covidVaccination
--ORDER BY 3,4

--SELECT Data we are going to be using

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location like '%Australia%'
and continent IS NOT NULL
ORDER BY 1,2


SELECT Location,date,total_cases,population,(total_cases/population)*100  AS PercentagePopulationInfected
FROM PortfolioProject..covidDeaths
WHERE location like '%Australia%'
and continent IS NOT NULL
ORDER BY 1,2


SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100  AS PercentagePopulationInfected
FROM PortfolioProject..covidDeaths
--WHERE location like '%Australia%'
GROUP BY Location,population
ORDER BY PercentagePopulationInfected DESC

SELECT Location, MAX(cast(total_deaths AS INT)) AS TOTALDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TOTALDeathCount DESC

--Exact figure
SELECT location AS Continent, MAX(cast(total_deaths AS INT)) AS TOTALDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NULL and (location NOT LIKE '%income%')
GROUP BY location
ORDER BY TOTALDeathCount DESC


--Global
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
--WHERE location like '%china%'
--WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations

WITH PopvsVac(continent, Location, date, population, New_Vaccination, RollingPeopleVacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVacinated/population) * 100
FROM PopvsVac
WHERE location like '%Australia%'

--

DROP TABLE IF EXISTS #PercentRollingPeopleVacinated
CREATE TABLE #PercentRollingPeopleVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)
INSERT INTO #PercentRollingPeopleVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
SELECT *,(RollingPeopleVacinated/population)*100 AS PercentRollingPeopleVacinated
FROM #PercentRollingPeopleVacinated


--Creating view
CREATE VIEW PercentRollingPeopleVacinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccination vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentRollingPeopleVacinated
