select *
from PortofolioProject..CovidDeaths
where continent is not null and continent != ''
order by 3,4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

-- Select the Data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null and continent != ''
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != '' and location like '%states%'
order by 1

-- Look at total cases vs population
Select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PopCasesPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != ''
order by 1


-- Look at countries with highest infection rate compared to population
Select location, population, max(cast(total_cases as float)) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PopCasesPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != ''
group by location, population
order by PopCasesPercentage desc

-- showing countries with highest death count per population

Select location, max(cast(total_deaths as float)) as TotalDeathCount, MAX((cast(total_deaths as float)/cast(population as float)))*100 as PopDeathsPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != ''
group by location
order by TotalDeathCount DESC

-- Let's break things down by continent or location

Select continent, max(cast(total_deaths as float)) as TotalDeathCount, MAX((cast(total_deaths as float)/cast(population as float)))*100 as PopDeathsPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != ''
group by continent
order by TotalDeathCount DESC

Select location, max(cast(total_deaths as float)) as TotalDeathCount, MAX((cast(total_deaths as float)/cast(population as float)))*100 as PopDeathsPercentage
from CovidDeaths
WHERE total_deaths != 0 and total_cases != 0 and total_deaths != '' and total_cases != '' and continent is not null and continent != ''
group by location
order by TotalDeathCount DESC


-- Global numbers

Select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from CovidDeaths
WHERE new_cases != 0 and new_deaths != 0 and new_cases != '' and new_deaths != '' and continent is not null and continent != '' 
--group by date
order by 1,2

Select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from CovidDeaths
WHERE new_cases != 0 and new_deaths != 0 and new_cases != '' and new_deaths != '' and continent is not null and continent != '' 
group by date
order by 1,2



-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(new_vaccinations as float)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where new_vaccinations != '' and dea.continent != '' 
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3


--USE CTE for above

With PopvsVac(Continent, Location, Date, Population, New_Vacccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(new_vaccinations as float)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where new_vaccinations != '' and dea.continent != '' 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(new_vaccinations as float)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where new_vaccinations != '' and dea.continent != '' 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(new_vaccinations as float)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
JOIN CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
Where new_vaccinations != '' and dea.continent != '' 
--order by 2,3


select *
from PercentPopulationVaccinated