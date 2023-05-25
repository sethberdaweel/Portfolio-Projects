
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2 -- order by the number of columns, instead of their names

-- Looking at Total Cases vs Total Deaths + the death percentage
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%jordan%'
order by 1, 2

-- Total cases vs Population
-- Shows the percentage of the population that is infected
Select Location, date, population, total_cases, round((total_cases/population)*100, 4) as TotalCasesPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%jordan%'
order by 1, 2

-- Countries with Hightest Infection Rate Comapred to the Population
Select Location, continent, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100, 4) as
	PercentInfectPopulation
From PortfolioProject..CovidDeaths
Group by continent, location, population
order by PercentInfectPopulation DESC

-- The Countries with the Highest DeathCount per Population
Select Location, Population, continent, MAX(cast(total_deaths as int)) as TotalDeathCount, ROUND(MAX((total_deaths/population))*100, 4) as 
	PercentDeathPopulation
From PortfolioProject..CovidDeaths
Where continent is not null -- Because when the continent is null, it effects the location with some
-- weird categories(like "low income", etc)
Group by continent, location, population
order by PercentDeathPopulation DESC


-- Exploring by Continent

-- Showing the continents with the highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- Global insights
Select date, SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths,
	ROUND(SUM(cast(new_deaths as int))/SUM(new_cases), 4) as DeathPercenetage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1, 2


------------------


-- Looking at Total Population vs. Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as AccumulatedNumberVaccinations,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1, 2, 3
 

-- The next goal is to know how many people from each country have been vaccinated

-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, AccumulatedNumberVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as AccumulatedNumberVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, ROUND((AccumulatedNumberVaccinations/Population)*100, 4)
From PopvsVac