Select *
From Covid19PortfolioProject..CovidDeaths
Where continent is not null 
Order by 3, 4



--Select *
--From Covid19PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Covid19PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2 -- this will order them by location 1st, date 2nd

-- looking at total cases vs total deaths 
-- calculating the death rate
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatePercentage
From Covid19PortfolioProject..CovidDeaths
Where location like '%states'
and continent is not null 
Order by 1,2

-- looking at Total Cases vs Population 
-- Show the percentage of the population has gotten covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentageWithCovid
From Covid19PortfolioProject..CovidDeaths
Where location like '%states'
Order by 1,2


-- Which countries have the highest infection rates compared to the population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentageWithCovid
From Covid19PortfolioProject..CovidDeaths
-- Where location like '%states'
Group by population, location
Order by PercentageWithCovid Desc



-- Highest Death Count by CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid19PortfolioProject..CovidDeaths
-- Where location like '%states'
Where continent is not null 
Group by continent
Order by TotalDeathCount Desc


-- Looking at highest death count from population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid19PortfolioProject..CovidDeaths
-- Where location like '%states'
Where continent is not null 
Group by location
Order by TotalDeathCount Desc

-- GLOBAL NUMBERS

-- Number of new cases per day/ new deaths per day / death percentage per day
Select date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRatePercentage
From Covid19PortfolioProject..CovidDeaths
-- Where location like '%states'
Where  continent is not null 
Group by date
Order by 1,2

-- Number of new tota cases/ total deaths / death percetage
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRatePercentage
From Covid19PortfolioProject..CovidDeaths
-- Where location like '%states'
Where  continent is not null 
Order by 1,2


-- VACCINATIONS
Select *
From Covid19PortfolioProject..CovidDeaths dea
Join Covid19PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date

-- Looking at Total Population vs Vaccination -- Rolling Vaccinations as well as Percentage of Population Vaccinated (Rolling as well)
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
--	dea.date) as RollingVaccinations
--From Covid19PortfolioProject..CovidDeaths dea
--Join Covid19PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

-- USE CTE
With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingVaccinations)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
	dea.date) as RollingVaccinations
From Covid19PortfolioProject..CovidDeaths dea
Join Covid19PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingVaccinations/Population)*100
From PopvsVac

-- TEMPT TABLE

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
	dea.date) as RollingVaccinations
From Covid19PortfolioProject..CovidDeaths dea
Join Covid19PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated

-- Creating a view for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
	dea.date) as RollingVaccinations
From Covid19PortfolioProject..CovidDeaths dea
Join Covid19PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

