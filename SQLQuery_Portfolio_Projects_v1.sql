SELECT * FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Order By 1,2


--Total Cases vs Total Deaths
Select location, date, total_cases, 
total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%states%'
Order By 1,2

--Total cases vs population
--what percentage of the population contracted covid
Select location, date, total_cases, 
population, (total_cases/population)*100 AS ConfirmedCases
From PortfolioProjects..CovidDeaths
Where location like '%states'
Order By 1,2



--Countries with highest infection rate compared to the location
Select Location, population, Max(total_cases) AS HighestInfectionCount,  
Max((total_cases/population))*100 AS PercentageInfected
From PortfolioProjects..CovidDeaths
Group By Location, Population
Order By PercentageInfected desc



--Continent and their total deaths
Select continent, Max(cast(total_deaths as int)) AS TotalDeathCount  
From PortfolioProjects..CovidDeaths
where continent is not null
Group By continent
Order By TotalDeathCount desc


--Countries with highest death counts per population
Select location, Max(cast(total_deaths as int)) AS TotalDeathCount  
From PortfolioProjects..CovidDeaths
where continent is null
Group By location
Order By TotalDeathCount desc\


--Global numbers
Select date, SUM(new_cases) From PortfolioProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths,
SUM(cast (new_deaths as int))/SUM(new_cases)*100
as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2



--Joining Tables CovidDeaths and CovidVaccinations
Select *
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date


--Total population vs vaccinations

Select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE
With PopvsVac(continent, location, date, population,
new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac




--Temp Table
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated




--Creating Views to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated