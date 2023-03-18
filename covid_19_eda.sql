SELECT *
FROM dbo.CovidDeaths
ORDER BY 3, 4;

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3, 4

-- Select the needed data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2;

-- Display Total Cases Vs Total Deaths in percentages
SELECT Location, date,  total_cases Total_cases, 
				Total_deaths Total_deaths,
				(Total_deaths/total_cases) * 100 Percentage_of_death
FROM dbo.CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1, 2;

-- Display the Total cases Vs Population
-- What percentage of the population is infected with covid-19
SELECT Location, date,  
				population,
				total_cases Total_cases, 
				(total_cases/population) * 100 Percentage_of_pop_infected
FROM dbo.CovidDeaths
--WHERE Location LIKE '%States%'
ORDER BY 1, 2;

-- What are the top 10 countries with the highest numbers of infected people

SELECT TOP 10 Location,
				population,
				MAX(total_cases) MaxTotal_casesCount, 
				MAX((total_cases/population)) * 100 Percentage_of_pop_infected			
FROM dbo.CovidDeaths
GROUP BY Location, population
--WHERE Location LIKE '%States%'
ORDER BY Percentage_of_pop_infected DESC;



-- Display the continents with the highest numbers of deaths
SELECT location,
				MAX(CAST(total_deaths AS int)) Total_death_counts		
FROM dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_death_counts DESC;


-- Display the countries with the highest numbers of deaths
SELECT Location,
				MAX(CAST(total_deaths AS int)) Total_death_counts		
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_death_counts DESC;


-- Global deaths

SELECT SUM(new_cases) as total_cases, 
	   SUM(CAST(new_deaths AS int)) AS total_deaths,
	   SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Display the total number of people that was vaccinated per every population
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.Location, Deaths.Date) AS
	Cummulative_vacccination
FROM dbo.CovidDeaths AS deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location 
AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 1,2,3


-- USE CTE
WITH PopVsVacc (continent, location, date, population, new_vaccinations, Cummulative_vacccination)
AS
(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.Location, Deaths.Date) AS
	Cummulative_vacccination
FROM dbo.CovidDeaths AS deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location 
AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (Cummulative_vacccination/population)*100 AS pop_vaccinated
FROM PopVsVacc


-- USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopVaccinated

CREATE TABLE #PercentPopVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cummulative_Vaccination numeric
)


INSERT INTO #PercentPopVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.Location, Deaths.Date) AS
	Cummulative_vaccination
FROM dbo.CovidDeaths AS deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location 
AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL

SELECT *, (Cummulative_vaccination/population)*100 AS pop_vaccinated
FROM #PercentPopVaccinated;


-- Creating View to store data for visualizations

CREATE VIEW percentageofvaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.Location, Deaths.Date) AS
	Cummulative_vacccination
FROM dbo.CovidDeaths AS deaths
JOIN dbo.CovidVaccinations vacc
	ON deaths.location = vacc.location 
AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL

SELECT *
FROM percentageofvaccinated;