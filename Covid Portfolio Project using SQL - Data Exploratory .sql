/* Covid 19 Deaths And Vaccination Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--Select data from CovidDeaths$ table

Select * 
From ProtfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 3,4

--Select data from CovidVaccinations$

Select * 
From ProtfolioProject.dbo.CovidVaccinations$
Order by 3,4


--Select the data that we are going to be using to explore the database

Select location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the death rate if you are affected

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths$
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population infected with covid

Select location, date, population, total_cases, (total_cases/population)* 100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
Order by 1,2


-- Looking at Countries with highest infection rate compared to population 


Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))* 100 as PercentofPopulationInfected
From ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
Group by location, population
Order by PercentofPopulationInfected desc


-- Showing the Countries with the highest Death Count per Population


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continent with the Highest Death Count


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProtfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount DESC



-- Global numbers to check the number of deaths all over the world


Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
From ProtfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 1,2



-- Looking at Total Population vs Vaccinations 
-- Shows percentage of population who has received atleast one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths$ dea
Join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE
-- Performing Partition by on previous queries


WITH PopVsVac (Continent, Loaction, Date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths$ dea
Join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select * From PopVsVac


-- TEMP Table
-- Using Temp table to use partition by on previous queries


DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths$ dea
Join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating view to store data


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From ProtfolioProject.dbo.CovidDeaths$ dea
Join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select * From PercentPopulationVaccinated
