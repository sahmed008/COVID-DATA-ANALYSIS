SELECT * FROM dbo.CovidDeaths;
SELECT * FROM dbo.CovidVaccination;

-- Looking at Total Cases Vs Total Deaths
SELECT 
location, date, total_deaths, total_cases, (CONVERT(decimal(10,2), total_deaths) / CONVERT(int, total_cases)) * 100 as deaths
FROM dbo.CovidDeaths
-- WHERE location LIKE '%states'
WHERE location = 'Canada'
ORDER BY 1, 2;

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got Covid
SELECT 
location, date, total_deaths, population, total_cases, (total_cases/population) * 100 as PercentPopInfected 
FROM dbo.CovidDeaths
--WHERE location LIKE '%states'
WHERE location = 'Canada'
ORDER BY 1, 2;


-- Looking at countries with highest infection rate compared to population

SELECT 
location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopInfected  
FROM dbo.CovidDeaths
--WHERE location LIKE '%states'
WHERE location = 'Canada'
GROUP by location, population
ORDER BY 4 DESC;


--Showing Countries with Highest Death Count per population

SELECT 
location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%states'
--WHERE location = 'Canada'
WHERE continent IS NOT NULL
GROUP by location
ORDER BY 2 DESC;



-- Showing Continents with the highest death count

SELECT 
continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%states'
--WHERE location = 'Canada'
WHERE continent IS not NULL
GROUP by continent
ORDER BY 2 DESC;

-- Global Numbers

SELECT 
SUM(new_cases) AS total_cases, SUM(Cast(new_deaths AS int)) as total_deaths, 
SUM(Cast(new_deaths AS int))/SUM(new_cases)*100 as death_percentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%states'
--WHERE location = 'Canada'
--WHERE continent IS not NULL
--GROUP by date
ORDER BY 2 DESC;


-- Joining Vaccination and Death tables

SELECT 
 cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccinated_count
FROM dbo.CovidDeaths AS cd
INNER JOIN dbo.CovidVaccination AS cv
ON cd.location = cv.location
 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'Albania'
 ORDER BY 2, 3

-- use cte
WITH PopsVac AS (
SELECT 
 cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccinated_count
FROM dbo.CovidDeaths AS cd
INNER JOIN dbo.CovidVaccination AS cv
ON cd.location = cv.location
 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'United Kingdom'
)
Select *, (rolling_vaccinated_count/population) * 100 AS rolling_vaccinated_perc
from PopsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PopVac
CREATE TABLE #PopVac (
 continent NVARCHAR(255), 
 location NVARCHAR(255),
 date datetime,
 population bigint,
 new_vaccinations bigint,
 rolling_vaccinated_count int
 )

 INSERT INTO #PopVac
 SELECT 
 cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
 SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_vaccinated_count
FROM dbo.CovidDeaths AS cd
INNER JOIN dbo.CovidVaccination AS cv
ON cd.location = cv.location
 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'United Kingdom'

Select *, (rolling_vaccinated_count/population) * 100 AS rolling_vaccinated_perc
from #PopVac