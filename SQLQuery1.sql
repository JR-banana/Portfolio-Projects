USE PortfolioProjectCOVID19


SELECT * FROM CovidDeaths
order by 3,4;


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

--Looking at Total cases vs Total Deaths 
--Shows likelyhood of dying in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths
WHERE Location like 'United States' --<Country Of Interest>
ORDER BY 1,2; -- totalcases = 33307363 totaldeaths = 595833 DeathPercentage ~1.78% For United States 

--Looking at Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
WHERE Location like '%United States%' --As of 6/7/2021 10 percent has gotten a test and has been confirmed
ORDER BY 1,2 DESC ;-- DESC to see most recent Date

--Countries with highest infectious rate compared to population

SELECT Location, Population, MAX(Total_Cases) as Highest_Infectious_Count, MAX((total_cases/population))*100 as 
Percent_Population_Infected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC;

--Showing Countries with Highest Death Count Per Population

SELECT Location, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- The total deaths is in the wrong data type for querying our information.
--It is in nvarchar (255). Thus We need to convert it by "Casting" it into an interger.
FROM CovidDeaths
WHERE Continent is not NULL -- To hide Continents from our view
GROUP BY Location 
ORDER BY Total_Death_Count DESC;

--Let's Break it down by Continent

SELECT Continent, MAX(cast(Total_Deaths as int)) as Total_Death_Count -- The total deaths is in the wrong data type for querying our information.
--It is in nvarchar (255). Thus We need to convert it by "Casting" it into an interger.
FROM CovidDeaths
WHERE Continent is not NULL -- To hide Continents from our view
GROUP BY Continent
ORDER BY Total_Death_Count DESC;

--Global Numbers

SELECT date, SUM(new_cases) as total_cases_by_date, SUM(cast(new_deaths as int)) as total_deaths_by_date, 
SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
group by date
order by 1,2;


--Looking at Total Poulation vs Vaccinations

--USE CTE

with popvsvac (Continent, Location, Date, Population, New_Vaccinations, Rolling_TotalVaccinations)
as
(


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_TotalVaccinations

FROM CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null -- and vac.new_vaccinations is not null
--ORDER BY 2,3;-- means order by second and third column btw
)

Select *, (Rolling_TotalVaccinations/Population)* 100 --Tells you the added percantage of people vaccinated per date and location
FROM popvsvac






-- Temp Table



Drop Table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_TotalVaccinations numeric
)

Insert Into #PercentPopulationvaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_TotalVaccinations

FROM CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null -- and vac.new_vaccinations is not null
--ORDER BY 2,3;-- means order by second and third column btw


Select *, (Rolling_TotalVaccinations/Population)* 100 --Tells you the added percantage of people vaccinated per date and location
FROM #PercentPopulationvaccinated;


-- Creating Views for data for later vizualiztions


Create View PercentPopulationvaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_TotalVaccinations

FROM CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null -- and vac.new_vaccinations is not null
--ORDER BY 2,3;-- means order by second and third column btw

--View PercentPopulationVaccinated
Select *
From PercentPopulationvaccinated













