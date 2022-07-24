Select * 
from ProtfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select * 
--from ProtfolioProject.dbo.CovidVaccinations$
--order by 3,4

--Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from ProtfolioProject.dbo.CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from ProtfolioProject.dbo.CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at total cases vs population

Select location, date, population, total_cases, (total_cases/population)* 100 as DeathPercentage
from ProtfolioProject.dbo.CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))* 100 as PercentofPopulationInfected
from ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentofPopulationInfected desc

-- Showing the countries with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continent with the highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from ProtfolioProject.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject.dbo.CovidDeaths$ dea
join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH PopVsVac (Continent, Loaction, Date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject.dbo.CovidDeaths$ dea
join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * from PopVsVac


-- TEMP Table

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject.dbo.CovidDeaths$ dea
join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store data

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject.dbo.CovidDeaths$ dea
join ProtfolioProject.dbo.CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated