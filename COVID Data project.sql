SELECT * 
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM ProfolioProject..CovidVaccinations
ORDER BY 3,4;

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases,total_deaths,population
FROM ProfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
-- Covid death Rate in United States

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS Death_Rate
FROM ProfolioProject..CovidDeaths
WHERE location = 'United States'
Order by 1,2

---Looking at total cases vs population
SELECT location,date,population,total_cases, (total_cases/population) * 100 AS  Percentage_of_population_infected
FROM ProfolioProject..CovidDeaths
WHERE location = 'United States' AND total_cases IS NOT NULL
Order by 1,2

--Looking at Countries with highest infection Rate compared to population

SELECT location,population,MAX(total_cases) AS Max_Cases, MAX((total_cases/population))* 100 AS Percentage_of_population_infected
FROM ProfolioProject..CovidDeaths
GROUP BY location,population
Order by 4 DESC

--Showing Countries with the highest death count per population

SELECT location,max(total_deaths) AS Total_Death_Count
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

--- Break Down Total death count via Continent

-- Showing continent with the highest total death counts 

SELECT location,max(total_deaths) AS Total_Death_Count
FROM ProfolioProject..CovidDeaths
WHERE continent IS  NULL AND location IN('Europe','North America','Asia','South America','Africa','Oceania')
GROUP BY location
ORDER BY Total_Death_Count DESC

--- GLOBAL NUMBERS

--- Total Deaths Worldwide
SELECT location,MAX(total_deaths)
FROM ProfolioProject..CovidDeaths
WHERE continent IS  NULL AND location = 'World'
GROUP BY location

-- Death Percentage Worldwide
SELECT location, SUM(new_cases) AS Total_Cases_worldwide,MAX(total_deaths) AS Total_deaths_Worldwide,SUM(new_deaths)/ SUM(new_cases) * 100 AS Death_Percentage_worldwide
FROM ProfolioProject..CovidDeaths
WHERE continent IS  NULL AND location = 'World'
GROUP BY location

-- Combine both the Covid deaths Table and Covid Vaccinations Table
SELECT *
FROM ProfolioProject..CovidVaccinations AS Vaccinations
JOIN ProfolioProject..CovidDeaths AS Deaths
ON Deaths.location = Vaccinations.location AND Deaths.date=Vaccinations.date;


-- Looking at Total Population vs Vaccinations

SELECT Deaths.continent,Deaths.location,Deaths.date,Deaths.population, Vaccinations.new_vaccinations, 
SUM(Vaccinations.new_vaccinations) OVER (Partition by Deaths.Location ORDER BY Deaths.Location,Deaths.date) AS Total_Amount_of_Vaccinations_per_day
FROM ProfolioProject..CovidVaccinations AS Vaccinations
JOIN ProfolioProject..CovidDeaths AS Deaths
ON Deaths.location = Vaccinations.location AND Deaths.date=Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
ORDER BY 2,3;


----Temp table

CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
population numeric,
new_vaccinations numeric,
Total_Amount_of_Vaccinations_per_day numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent,Deaths.location,Deaths.date,Deaths.population, Vaccinations.new_vaccinations, 
SUM(Vaccinations.new_vaccinations) OVER (Partition by Deaths.Location ORDER BY Deaths.Location,Deaths.date) AS Total_Amount_of_Vaccinations_per_day
FROM ProfolioProject..CovidVaccinations AS Vaccinations
JOIN ProfolioProject..CovidDeaths AS Deaths
ON Deaths.location = Vaccinations.location AND Deaths.date=Vaccinations.date
WHERE Deaths.continent IS NOT NULL 
--ORDER BY 2,3;

SELECT *,(Total_Amount_of_Vaccinations_per_day/population) *100
FROM #PercentPopulationVaccinated
WHERE Location = 'United States'

----- Create View for visualization 

--Total Death Count per Continent
Create view TotalContinentDeathCount AS
SELECT location,max(total_deaths) AS Total_Death_Count
FROM ProfolioProject..CovidDeaths
WHERE continent IS  NULL AND location IN('Europe','North America','Asia','South America','Africa','Oceania')
GROUP BY location
--ORDER BY Total_Death_Count DESC

SELECT * FROM TotalContinentDeathCount ORDER BY 2 DESC

-- TOP 10 HIGHEST INFECTED COVID COUNTRYS PER POPULATION
CREATE VIEW HighestInfectedCovidCountriesPerPopulation AS
SELECT TOP 10 location,population,MAX(total_cases) AS Max_Cases, MAX((total_cases/population))* 100 AS Percentage_of_population_infected
FROM ProfolioProject..CovidDeaths
GROUP BY location,population
Order by 4 DESC

SELECT * FROM HighestInfectedCovidCountriesPerPopulation

-- DEATH PERCENTAGE WORLDWIDE
CREATE VIEW DeathPercentageWorldwide AS
SELECT location, SUM(new_cases) AS Total_Cases_worldwide,MAX(total_deaths) AS Total_deaths_Worldwide,SUM(new_deaths)/ SUM(new_cases) * 100 AS Death_Percentage_worldwide
FROM ProfolioProject..CovidDeaths
WHERE continent IS  NULL AND location = 'World'
GROUP BY location

SELECT * FROM DeathPercentageWorldwide

--- Total Deaths Worldwide Highest 30
CREATE VIEW Top30CountiresHighestCovidDeaths AS
SELECT TOP 30 location, MAX(total_deaths) AS All_Deaths
FROM ProfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY All_Deaths desc

SELECT * FROM Top30CountiresHighestCovidDeaths