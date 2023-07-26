SELECT *
FROM KhangPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM KhangPortfolioProject..CovidDeaths
ORDER BY 1,2

--Information about Total Cases, Total Deaths and Death Percentage in VietNam

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM KhangPortfolioProject..CovidDeaths
WHERE Location LIKE '%viet%'
ORDER BY 1,2

--Compared Total Cases vs Population and Percetage of Population got Covid in VietNam

SELECT Location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
FROM KhangPortfolioProject..CovidDeaths
WHERE Location LIKE '%viet%'
ORDER BY 1,2

--Countries have the Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,
							 MAX((total_deaths/population))*100 as PercentPopulationInfected
FROM KhangPortfolioProject..CovidDeaths
--WHERE Location LIKE '%viet%'
GROUP BY Location, population
ORDER BY 1,2

--Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM KhangPortfolioProject..CovidDeaths
--WHERE Location LIKE '%viet%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--From Countries down to Continent

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM KhangPortfolioProject..CovidDeaths
--WHERE Location LIKE '%viet%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM KhangPortfolioProject..CovidDeaths
--WHERE Location LIKE '%viet%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBER

SELECT SUM(new_cases) as total_newcases,
			 SUM(cast(new_deaths as INT)) as total_newdeaths,
			 SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM KhangPortfolioProject..CovidDeaths
--WHERE Location LIKE '%viet%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER 
		(PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM KhangPortfolioProject..CovidDeaths dea
JOIN KhangPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Percent People who Vaccinated

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as

(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER 
		(PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM KhangPortfolioProject..CovidDeaths dea
JOIN KhangPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac 


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER 
		(PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM KhangPortfolioProject..CovidDeaths dea
JOIN KhangPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM #PercentPopulationVaccinated 


--Create view for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER 
		(PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM KhangPortfolioProject..CovidDeaths dea
JOIN KhangPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated