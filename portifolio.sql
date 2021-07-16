-- View Covid 19 data

SELECT
	*
FROM
	PortifolioProject..CovidDeaths
ORDER BY
	3,4


-- Selecting and arranging useful data

SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM
	PortifolioProject..CovidDeaths
WHERE
	continent is not null
-- since data in those fields is for groupings
ORDER BY
	1, 2

-- Percentageof infectd people who died 

SELECT
	location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM
	PortifolioProject..CovidDeaths
WHERE
	continent is not null
ORDER BY
	1, 2

-- check my area
SELECT
	location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM
	PortifolioProject..CovidDeaths
WHERE
	location like '%afri%'
ORDER BY
	1, 2

-- country with the highest infectiion rate
SELECT
	location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percentage_infection
FROM
	PortifolioProject..CovidDeaths
	WHERE
	continent is not null
GROUP BY
	location, population
ORDER BY
	percentage_infection desc

-- country with the highest death rate

SELECT
	location, MAX(total_deaths) as highest_infection_count, MAX((total_deaths)/population)*100 as percentage_deaths
FROM
	PortifolioProject..CovidDeaths
	WHERE
	continent is not null
GROUP BY
	location
ORDER BY
	percentage_deaths desc

-- countries with the highest death count
SELECT
	location, MAX(cast(total_deaths as int)) as death_count
FROM
	PortifolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	location
ORDER BY
	death_count desc

--summary of deaths by continent

SELECT
	continent, MAX(cast(total_deaths as int)) as death_count
FROM
	PortifolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
ORDER BY
	death_count desc

-- Global statistics for death percentage
SELECT
	 SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM
	PortifolioProject..CovidDeaths
WHERE
	continent is not null
ORDER BY
	1, 2


-- Joining tables, vaccinations and deaths

SELECT 
	*
FROM
	PortifolioProject.dbo.CovidDeaths dea
JOIN
	PortifolioProject.dbo.CovidVaccination vac
	ON
		dea.location = vac.location
		AND
			dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	PortifolioProject..CovidDeaths dea
JOIN 
	PortifolioProject..CovidVaccination vac
	ON
		dea.location = vac.location
			AND dea.date = vac.date
WHERE 
	dea.continent is not null 
ORDER BY
	2,3

--create a table(CTE)

WITH PopVsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	PortifolioProject..CovidDeaths dea
JOIN 
	PortifolioProject..CovidVaccination vac
	ON
		dea.location = vac.location
			AND dea.date = vac.date
WHERE 
	dea.continent is not null 
)
SELECT
	*, (RollingPeopleVaccinated/Population)*100
FROM
	PopVsVac

--creating views to store data for later use

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
