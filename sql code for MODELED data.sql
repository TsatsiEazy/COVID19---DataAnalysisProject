
--We are going to Select Data we want to use

	--SELECT location, date, total_cases, new_cases, total_deaths, population
	--FROM PortfolioProject..CovidDeaths
	--ORDER BY 1,2


--We are going to be looking  at Total Cases vs Total Deaths 
--and showing likelihood of getting infected by %

	SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percantage
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not NULL
	ORDER BY 1,2

--Tota Cases vs Population
--will show percentage of population had COVID

	--SELECT location, date, population, total_cases, (total_cases/population)*100 AS TotalCasesByPopulation
	--FROM PortfolioProject..CovidDeaths
	--WHERE location LIKE '%Africa%'
	--ORDER BY 1,2


--Finding Countries with highest Infection Rate as compared to Population
	
	SELECT location, population,  MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)*100) AS PercentofPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location LIKE '%Africa%'
	GROUP BY location, population
	ORDER BY PercentofPopulationInfected DESC --HIGHEST to LOWEST

	SELECT location, population, date ,MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)*100) AS PercentofPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location LIKE '%Africa%'
	GROUP BY location, population, date
	ORDER BY PercentofPopulationInfected DESC

--Displaying Countries with Highest Death Count as compared to Population by %, HIGHEST to LOWEST
	
	SELECT location, population, MAX(cast(total_deaths as int)) AS Highest_Death_Count,
	MAX((total_deaths/population)*100) AS PercentofTotalDeathCount
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not NULL
	GROUP BY location, population
	ORDER BY Highest_Death_Count DESC


--Displaying CONTINENTS with highest Death Rate as compared to Population by %, HIGHEST to LOWEST
	--Below is the correct way to view deaths of continents but Incorrect for visualization DRILLDOWN

	--CREATE VIEW HighestDeathRate AS
	--SELECT location, MAX(cast(total_deaths as bigint)) AS Highest_Death_Count,
	--MAX((total_deaths/population)*100) AS PercentofTotalDeathCount
	--FROM PortfolioProject..CovidDeaths
	--WHERE continent is NULL
	--GROUP BY location
	--ORDER BY Highest_Death_Count DESC
	

	--For drill purposes, use this code below
	--SELECT continent, MAX(cast(total_deaths as bigint)) AS Highest_Death_Count
	--FROM PortfolioProject..CovidDeaths
	--WHERE continent is not NULL
	--GROUP BY continent
	--ORDER BY Highest_Death_Count DESC

--Global Numbers

	SELECT location, SUM(new_cases) AS Global_Total_Cases, SUM(CAST(new_deaths AS int)) AS Global_Total_Death_Cases,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percantage
	FROM PortfolioProject..CovidDeaths
	WHERE continent is NULL AND location = 'World'
	GROUP BY location


	Select location, SUM(cast(new_deaths AS int)) AS Total_Death_Count
	From PortfolioProject..CovidDeaths
	Where continent is NULL 
		AND location NOT IN ('World', 'European Union', 'International') --Removing these specific objects from our display
	Group by location
	order by Total_Death_Count DESC
	

--Making Use of another Database, dbo.CovidVaccinations
	--Looking at total population vs. vaccination
	--Finding the total vaccinations per day and CONCATINATING that day with a new day to find SUM of vaccinations

	--SELECT CovidDeath.continent,CovidDeath.location, CovidDeath.date, CovidDeath.population, CovidVaccine.new_vaccinations,
	--SUM(CAST(CovidVaccine.new_vaccinations as bigint)) 
	--OVER (PARTITION BY CovidDeath.location ORDER BY CovidDeath.location , CovidDeath.date) AS Total_Vaccine_Rollout,
	--(Total_Vaccine_Rollout/population)*100 /* ERROR MESSAGE HERE */
	--FROM PortfolioProject..CovidDeaths AS CovidDeath
	--JOIN PortfolioProject..CovidVaccinations AS CovidVaccine
	--ON CovidDeath.location = CovidVaccine.location 
	--AND CovidDeath.date = CovidVaccine.date
	--WHERE CovidDeath.continent is not NULL
	--ORDER BY 2,3

--Using a CTE to circumvent 'ABOVE ERROR' which is using a created table(fictional table) in our SELECT statement within our SELECT statement
	WITH PopulationVSVaccine(Continent, location, Date, Population, New_Vaccinations ,Total_Vaccine_Rollout) AS
	(
	SELECT CovidDeath.continent,CovidDeath.location, CovidDeath.date, CovidDeath.population, CovidVaccine.new_vaccinations,
	SUM(CAST(CovidVaccine.new_vaccinations as bigint)) 
	OVER (PARTITION BY CovidDeath.location ORDER BY CovidDeath.location , CovidDeath.date) AS Total_Vaccine_Rollout
	--(Total_Vaccine_Rollout/population)*100 /*finding out amount of vaccined people in that country*/
	FROM PortfolioProject..CovidDeaths AS CovidDeath
	JOIN PortfolioProject..CovidVaccinations AS CovidVaccine
		ON CovidDeath.location = CovidVaccine.location 
		AND CovidDeath.date = CovidVaccine.date
	WHERE CovidDeath.continent is not NULL
	--ORDER BY 2,3
	)
	SELECT *, (Total_Vaccine_Rollout/Population)*100 AS Total_Percent_of_Population_Vaccinated
	FROM PopulationVSVaccine





















