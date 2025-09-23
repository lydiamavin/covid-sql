-- select entire data
SELECT * 
FROM public."CovidDeaths";

SELECT * 
FROM public."CovidVaccines";

--select required data 
SELECT location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM public."CovidDeaths"
WHERE continent is not null
ORDER BY 1,2;

--total cases vs total deaths in the states / shows likelihood of dying
SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM public."CovidDeaths"
WHERE location like '%States%'
ORDER BY 1,2;


--total cases vs population / shows what population of people got covid
SELECT location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 as AffectedPercentage
FROM public."CovidDeaths"
WHERE location like '%States%'
ORDER BY 1,2;


-- countries with highest infection rate compared to population
SELECT location,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM public."CovidDeaths"
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- countries with highest deathcount per population
SELECT location,
       MAX(total_deaths) AS HighestDeathCount
FROM public."CovidDeaths"
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- countries with highest deathcount per continent
SELECT continent,
       MAX(total_deaths) AS HighestDeathCount
FROM public."CovidDeaths"
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC;


--global data
SELECT sum(new_cases) as TotalCases,
	sum(new_deaths) as TotalDeaths,
	(sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
FROM public."CovidDeaths"
WHERE continent is not null
ORDER BY 1,2;


--join on location and data
SELECT * 
FROM public."CovidDeaths" d
JOIN public."CovidVaccines" v
ON d.location=v.location and d.date=v.date


--total population vs vaccinations
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population , 
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM public."CovidDeaths" d
JOIN public."CovidVaccines" v
ON d.location=v.location and d.date=v.date
WHERE d.continent is not null
ORDER BY 2,3


-- using Common Table Expression (CTE)
WITH PopvsVac (Continent , Location, Date, Population, New_Vaccines, RollingPeopleVaccinated)
as (
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population , 
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM public."CovidDeaths" d
JOIN public."CovidVaccines" v
ON d.location=v.location and d.date=v.date
WHERE d.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)* 100 as VaccinatedPercent
FROM PopvsVac;


--temp table
DROP table if exists PercentPopulationVaccinated;
CREATE table PercentPopulationVaccinated(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric, 
New_Vaccines numeric, 
RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population , 
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM public."CovidDeaths" d
JOIN public."CovidVaccines" v
ON d.location=v.location and d.date=v.date;
--WHERE d.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)* 100 as VaccinatedPercent
FROM PercentPopulationVaccinated;


--create views
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population , 
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location,d.date) as RollingPeopleVaccinated
FROM public."CovidDeaths" d
JOIN public."CovidVaccines" v
ON d.location=v.location and d.date=v.date
WHERE d.continent is not null
--ORDER BY 2,3

Select * from PercentPopulationVaccinatedView;

