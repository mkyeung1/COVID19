select *
from P2..CovidDeaths
order by 1,2

select *
from P2..CovidVaccination
order by 1,2


select Location, Date, Population, total_cases
from P2..CovidDeaths
order by 1,2

-- Looking at the death percentage 
select  Continent, Location, Date, Population, Total_Cases, Total_Deaths, Total_Deaths / CONVERT(float, Total_cases) * 100 as DeathPercentage 
from P2..CovidDeaths
where Continent is not null
and Location like'%king%'
order by 2,3

-- Looking at the death percentage 
select Continent, Location, Date, Population, Total_Cases, Total_Deaths, Total_cases / Population * 100 as PercentInfected
from P2..CovidDeaths
where Continent is not null
and Location like '%kingdom%'
order by 2,3

-- Looking at the percentage of hosptial patients
select Continent, Location, Date, Population, Total_Cases, Hosp_Patients as HospitalPatients,  Hosp_Patients / CONVERT(float, Total_cases) * 100 as PercentHospital
from P2..CovidDeaths
where Continent is not null
and Location like '%kingdom%'
order by PercentHospital desc


-- Looking at the countries with highest infection rate compared to population
select Location, Population, MAX(CONVERT(int,total_cases)) as HighestInfectionCount, MAX(CONVERT(int,total_cases))/ population * 100 as PercentPopulationInfected
from P2..CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc


-- Looking at the countries with highest death count compared to population
select Location, Population, date, Max(CONVERT(int,total_deaths)) as HighestDeathCount, MAX(CONVERT(int,total_deaths)) / population * 100 as PercentPopulationDeath
from P2..CovidDeaths
group by Location, Population, date
order by PercentPopulationDeath desc


-- Countries with Highest Death Count
select Location, Max(CONVERT(int,total_deaths)) as TotalDeathCount
from P2..CovidDeaths
where Continent is not null
group by Location
order by TotalDeathCount desc


-- Showing the continent with Highest Death Count
select Continent, SUM(CONVERT(int, new_deaths)) as TotalDeathCount
from P2..CovidDeaths
where continent is not null
group by Continent
order by TotalDeathCount desc

-- Global number World Death Percentage
select SUM( new_cases) as Total_Cases, SUM(CONVERT(int, new_deaths)) as Total_deaths, SUM(CONVERT(int, new_deaths)) / SUM(new_cases) * 100 as DeathPercentage
from P2..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from P2..CovidDeaths dea
join P2..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Use CTE
with PopVsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from P2..CovidDeaths dea
join P2..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population * 100) as PecentPeopleVaccinated
from PopVsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from P2..CovidDeaths dea
join P2..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated / Population * 100)
from #PercentPopulationVaccinated


-- Creating view to store data for visualisation 
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from P2..CovidDeaths dea
join P2..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select Location, SUM(CONVERT(int, new_deaths)) as TotalDeathCount
from P2..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc 