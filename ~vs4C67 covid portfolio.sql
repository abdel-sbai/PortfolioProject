SELECT *
FROM PortofolioProject..covidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM PortofolioProject..CovidVaccinations
ORDER BY 3,4

select location, date, total_cases,new_cases, total_deaths, population
from PortofolioProject..covidDeaths
order by 1,2

 --checking the total cases vs total deaths

select location, date, total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as deathPercentage
from PortofolioProject..covidDeaths
where location like '%costa%'
and continent is not null
order by 1,2

-- checking total cases vs population(InfectedPopulation percentage)

select location, date, population,total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectedPopulation
from PortofolioProject..covidDeaths
where location like '%bolivia%'
order by 1,2

 --checking the countries with the highest infection rates


select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as PercentagePopInfected
from PortofolioProject..covidDeaths
--where location like '%bolivia%'
Group by location, population
order by PercentagePopInfected desc

--showing countries with highest death count per population

select location, MAX(convert(float, total_deaths)) as TotalDeathCount
from PortofolioProject..covidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- covid cases by continent

select continent, MAX(convert(float, total_deaths)) as TotalDeathCount
from PortofolioProject..covidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


--covid around the globe 

select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from  PortofolioProject..covidDeaths
--where location like '%costa%'
where continent is not null
group by date
order by 1,2

--Total figure of covid around the globe

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from  PortofolioProject..covidDeaths
--where location like '%costa%'
where continent is not null
--group by date
order by 1,2

--looking at total populatiin vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as VaccinatedPeople
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopulationVsVacc (continent, location, date, population, new_vaccinations, VaccinatedPeople)

as

(


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as VaccinatedPeople
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (VaccinatedPeople/population)*100
from PopulationVsVacc

--TEMP TABLE

drop table if exists #percentpeoplevaccinated
create Table #percentpeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinatedPeople numeric
)
Insert into #percentpeoplevaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as VaccinatedPeople
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
select *, (VaccinatedPeople/population)*100
from #percentpeoplevaccinated

-- CREATE view for vizualisations

Create view percentpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as VaccinatedPeople
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpeoplevaccinated