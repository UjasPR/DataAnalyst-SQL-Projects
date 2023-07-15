-----------------------Covid Dataset--------------------------------------
--Dataset divided into two tables(CovidDeaths,CovidVacination)------------
select * from PortFolio_Project..CovidDeaths 
order by 3,4



--select * from PortFolio_Project..CovidVacination
--order by 3,4

------------Selecting our required column for EDA----------------------
select location,date,total_cases,new_cases,total_deaths,population from PortFolio_Project..CovidDeaths 
order by 1,2 desc

--Total Cases Vs Total Deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 death_percentage from PortFolio_Project..CovidDeaths
order by 1,2 desc
-----------------------------
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 death_percentage from PortFolio_Project..CovidDeaths
where location like '%india%'
order by 1,2 desc
--Total Cases Vs Populations
select location,date,population,total_cases,((total_cases)/population)*100 infected_percentage from PortFolio_Project..CovidDeaths
order by 1,2 desc
-------------------
select location,date,population,total_cases,((total_cases)/population)*100 infected_percentage from PortFolio_Project..CovidDeaths
where location like '%india%'
order by 1,2 desc
---Country with highest infected rate with population
select location,population,max(total_cases) as highestInfectionCount,max((total_cases/population))*100 infected_percentage from PortFolio_Project..CovidDeaths
where continent is not null
group by location,population
order by infected_percentage desc
-- Countries with Highest Death per Population
select continent,max(cast(total_deaths as int)) as highestDeathCount from PortFolio_Project..CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc
--Global count checks
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortFolio_Project..CovidDeaths
where continent is not null
--group by date
order by 1,2 desc


select * from PortFolio_Project..CovidVacination
order by 3,4
-- Population Vs Vaccination

select cv.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(bigint,cv.new_vaccinations)) over 
(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortFolio_Project.dbo.CovidVacination cv 
join PortFolio_Project.dbo.CovidDeaths cd on
cv.location=cd.location and cv.date=cd.date
where cd.continent is not null
order by 2,3 

--- Usage of CTE
with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(select cv.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,sum(convert(bigint,cv.new_vaccinations)) over 
(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from PortFolio_Project.dbo.CovidVacination cv 
join PortFolio_Project.dbo.CovidDeaths cd on
cv.location=cd.location and cv.date=cd.date
where cd.continent is not null
 )
select *,(RollingPeopleVaccinated/Population)*100 as Rolling_Number from popvsvac



---Temp Table

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
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortFolio_Project.dbo.CovidDeaths dea
Join PortFolio_Project.dbo.CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
	
Select *, (RollingPeopleVaccinated/Population)*100 as Rolling_Number
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortFolio_Project..CovidDeaths dea
Join PortFolio_Project..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated
------------------------------------------------------------------------------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortFolio_Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
---------------------------
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortFolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
----------------------------------
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortFolio_Project..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc
----------------------------------------

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortFolio_Project..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
-----------------Views for our SQL Query---------------------------

CREATE  OR REPLACE VIEW [DeathPercentageView]
AS
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 death_percentage from PortFolio_Project..CovidDeaths
where location like '%india%';
--order by 1,2 desc;
select * from [DeathPercentageView];
----------------------------------
CREATE  VIEW [InfectedPercentageView]
AS
select location,date,population,total_cases,((total_cases)/population)*100 infected_percentage from PortFolio_Project..CovidDeaths
where location like '%india%';
--order by 1,2 desc;
select * from [InfectedPercentageView];
----------------------------------
