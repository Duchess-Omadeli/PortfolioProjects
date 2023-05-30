SELECT *
FROM PORTFOLIO..CovidDeaths
ORDER by 3,4;

--SELECT *
--FROM PORTFOLIO..CovidVaccinations
--ORDER by 3,4;

--Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population	
FROM PORTFOLIO..CovidDeaths
ORDER by 1,2;

--BREAK DOWN DATA BY LOCATION

--COMPARISON BETWEEN TOTAL CASES VS TOTAL DEATHS

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS percentage_of_deaths
FROM PORTFOLIO..CovidDeaths

ORDER by 1,2;

--Percentage_of_deaths shows the likelihood of dying if you contract the Covid19 Virus

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS percentage_of_deaths
FROM PORTFOLIO..CovidDeaths
WHERE location like '%canada%'
AND continent is not null
ORDER by 1,2;

--COMPARISON BETWEEN TOTAL CASES AND POPULATION

SELECT location, date,population,total_cases, (total_cases/population)*100 AS 'infection_rate(%)'
FROM PORTFOLIO..CovidDeaths
--WHERE location like '%states%'
ORDER by 1,2;

--COUNTRIES WITH HIGHEST INFECTION RATE IN RELATION TO ITS POPULATION

SELECT location,population,MAX(cast(total_cases as int)) AS highest_infection_count, MAX((total_cases/population))*100 AS 'infection_rate(%)'
FROM PORTFOLIO..CovidDeaths
--WHERE location like '%states%
WHERE continent is not null
GROUP by location, population
order by [infection_rate(%)] desc;

--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location,population, MAX(cast(total_deaths as int))AS highest_death_count, MAX((total_deaths/population))*100 AS 'death_rate(%)'
FROM PORTFOLIO..CovidDeaths
--WHERE location like '%states%
WHERE continent is not null
GROUP by location, population
ORDER by highest_death_count desc;

--BREAKDOWN BY CONTINENT

--CONTINENTS AND THEIR DEATH COUNTS

SELECT continent,SUM(cast(new_deaths as int)) as total_death_count
FROM PORTFOLIO..CovidDeaths
--where location is %canada%
WHERE continent is not null 
GROUP by continent
ORDER by total_death_count desc;


--NUMBER OF TOTAL CASES VS DEATHS WORLDWIDE

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS "percentage_of_deaths"
FROM PORTFOLIO..CovidDeaths
--WHERE location like '%canada%'
WHERE continent is not null
--GROUP by date
ORDER by 1,2;



--TOTAL POPULATION VS NUMBER OF VACCINATIONS

SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations,SUM(convert(int, VAC.new_vaccinations))
OVER (partition by DEA.location ORDER by DEA.location, DEA.date) AS "rolling_count_of_people_vaccinated"
FROM PORTFOLIO..CovidDeaths DEA
JOIN PORTFOLIO..CovidVaccinations VAC
on DEA.location = VAC.location 
AND DEA.DATE= VAC.DATE
WHERE DEA.continent is not null
ORDER by 2,3; 



--CONTINENTS, LOCATIONS AND THEIR VACCINATION RATE IN PERCENT
--USING CTE

WITH POPvsVAC (continent, location, date,population, new_vaccination, rolling_count_of_people_vaccinated)         
AS
(SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations,SUM(convert(int, VAC.new_vaccinations))
OVER (partition by DEA.location ORDER by DEA.location, DEA.date) as "rolling_count_of_people_vaccinated"
FROM PORTFOLIO..CovidDeaths DEA
JOIN PORTFOLIO..CovidVaccinations VAC
     on DEA.location = VAC.location 
     AND DEA.DATE= VAC.DATE
WHERE DEA.continent is not null
--ORDER by 2,3
)
SELECT * , (rolling_count_of_people_vaccinated/population)*100 AS "vaccination_rate(%)"
FROM POPvsVAC;


--USING TEMP TABLE
DROP TABLE if exists #PERCENTAGEOFPOPULATIONVACCINATED
CREATE TABLE #PERCENTAGEOFPOPULATIONVACCINATED
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccination numeric, rolling_count_of_people_vaccinated numeric)

INSERT INTO #PERCENTAGEOFPOPULATIONVACCINATED
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations,SUM(convert(int, VAC.new_vaccinations))
OVER (partition by DEA.location ORDER by DEA.location, DEA.date) as "rolling_count_of_people_vaccinated"
FROM PORTFOLIO..CovidDeaths DEA
JOIN PORTFOLIO..CovidVaccinations VAC
     on DEA.location = VAC.location 
     AND DEA.DATE= VAC.DATE
--WHERE DEA.continent is not null
--ORDER by 2,3

SELECT * ,(rolling_count_of_people_vaccinated/population)*100 AS "vaccination_rate(%)"
FROM #PERCENTAGEOFPEOPLEVACCINATED;


--CREATING VIEWS FOR VISUALIZATIONS

CREATE VIEW PERCENTAGEOFPEOPLEVACCINATED as
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations,SUM(convert(int, VAC.new_vaccinations))
OVER (partition by DEA.location ORDER by DEA.location, DEA.date) as "rolling_count_of_people_vaccinated"
FROM PORTFOLIO..CovidDeaths DEA
JOIN PORTFOLIO..CovidVaccinations VAC
     on DEA.location = VAC.location 
     AND DEA.DATE= VAC.DATE
WHERE DEA.continent is not null
--ORDER by 2,3


CREATE VIEW ROLLINGCOUNTOFPOPULATIONVACCINATED as
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations,SUM(convert(int, VAC.new_vaccinations))
OVER (partition by DEA.location ORDER by DEA.location, DEA.date) AS "rolling_count_of_people_vaccinated"
FROM PORTFOLIO..CovidDeaths DEA
JOIN PORTFOLIO..CovidVaccinations VAC
on DEA.location = VAC.location 
AND DEA.DATE= VAC.DATE
WHERE DEA.continent is not null
--ORDER by 2,3; 

CREATE VIEW CONTINENTDEATHTOLL as 
SELECT continent, MAX(cast(total_deaths as int))AS total_death_count
FROM PORTFOLIO..CovidDeaths
WHERE continent is not null 
GROUP by continent
--ORDER by total_death_count desc;

