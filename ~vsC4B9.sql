select *
from [PROJECT PORTFOLIO].dbo.CovidDeaths
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From [PROJECT PORTFOLIO]..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PROJECT PORTFOLIO]..CovidDeaths
order by 1,2

--Looking at Death Percentage based on the country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PROJECT PORTFOLIO]..CovidDeaths
where location like '%donesia'
order by 1,2

--Looking at the total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [PROJECT PORTFOLIO]..CovidDeaths
order by 1,2

--Looking at the total cases vs population based on the country
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From [PROJECT PORTFOLIO]..CovidDeaths
where location like '%donesia'
order by 1,2

--Looking at the highest infected case 
Select location, MAX(cast(total_cases as int)) as TotalDeathCount
From [PROJECT PORTFOLIO].dbo.CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

--LET'S BREAK IT DOWN BY CONTINENT
Select continent, MAX(cast(total_cases as int)) as TotalDeathCount
From [PROJECT PORTFOLIO].dbo.CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount desc

--LOOKING AT THE PERCENTAGE OF NEW deaths VS New Cases
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageDeaths
From [PROJECT PORTFOLIO].dbo.CovidDeaths
where continent is not NULL
order by 1, 2


--UNION 2 TABLES 
Select *
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--LOOKING AT TOTAL VACCINATION VS TOTAL POPULATION
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--LOOKING A TOTAL VACCINATION VS TOTAL POPULATION BY ADDING UP FROM THE PREVIOUS CELL
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Create CTE to calculate for the next step
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercetage
From PopvsVac

--CREATE TEMP TABLE
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *
From #PercentPopulationVaccinated

--CREATE VIEW PercentPeopleVaccinated

create view PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [PROJECT PORTFOLIO]..CovidDeaths dea
join [PROJECT PORTFOLIO]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPeopleVaccinated

