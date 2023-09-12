select *
from CovidDeaths
order by 3,4


--select * 
--From CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases,total_deaths, population
From CovidDeaths
Order By 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you are a covid patient in your country

Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
From CovidDeaths
where location = 'Pakistan'
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of popution got Covid

Select location, date, population, total_cases, ((total_cases/population)*100) as CovidPatientsPercentage
From CovidDeaths
where location = 'Pakistan'
Order By 1,2

-- Looking at Countries with Hightes Infection rate compared to Popilation

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as CovidPatientsPercentage
From CovidDeaths
where continent is not null
Group by location, population
Order By 4 desc

-- Showing Counteris Hight mortality rate per Population

Select location, Max(total_deaths)  as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by 2 desc

-- Data as per Continets 
-- Showing the Continents with Highest Death Counts
Select continent, Max(total_deaths)  as TotalDeathCount
From CovidDeaths
where continent is not null
Group by Continent
order by 2 desc


Select location, Max(total_deaths)  as TotalDeathCount
From CovidDeaths
where continent is  null
Group by location
order by 2 desc

-- Global Numbers 

Select date, sum(new_cases) as WorldWideCases, sum(new_deaths) WorldWideDeaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null and new_cases is not null and new_deaths is not null 
	and new_cases > 0 and new_deaths > 0
group by date
order by 1

Select sum(new_cases) as WorldWideCases, sum(new_deaths) WorldWideDeaths , (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From CovidDeaths
Where continent is not null and new_cases is not null and new_deaths is not null 
	and new_cases > 0 and new_deaths > 0
--group by date
order by 1


-- Looking at Total Population vs Vaccination

Select CD.continent, CD.location, CD.date, CD.population, new_vaccinations
, Sum(convert(bigint, new_vaccinations)) over ( Partition by CD.Location order by CD.location, CD.date) as SumOfRunningValueNewVaccin
From CovidDeaths CD
join CovidVaccinations CV 
	on CD.location = CV.location 
	and CD.date = cv.date
Where cd.continent is not null and  new_vaccinations is not null and new_vaccinations > 0
order by 2,3

-- Using CTE or With Statment 

With PopVsVac ( Continent, Location, date, population, New_vaccinations, SumOfRunningValueNewVaccin)
	as
	(
	Select CD.continent, CD.location, CD.date, CD.population, new_vaccinations
	, Sum(convert(bigint, new_vaccinations)) over ( Partition by CD.Location order by CD.location, CD.date) as SumOfRunningValueNewVaccin
	From CovidDeaths CD
	join CovidVaccinations CV 
	on CD.location = CV.location 
	and CD.date = cv.date
	Where cd.continent is not null and  new_vaccinations is not null and new_vaccinations > 0
	--order by 2,3
	)
	Select * , (SumOfRunningValueNewVaccin/population)*100
	 from PopVsVac

-- With Temp Table
drop table if exists #temp1

Select * into #temp1 
from(
Select CD.continent, CD.location, CD.date, CD.population, new_vaccinations
	, Sum(convert(bigint, new_vaccinations)) over ( Partition by CD.Location order by CD.location, CD.date) as SumOfRunningValueNewVaccin
	From CovidDeaths CD
	join CovidVaccinations CV 
	on CD.location = CV.location 
	and CD.date = cv.date
	Where cd.continent is not null and  new_vaccinations is not null and new_vaccinations > 0
	
	) as x

Select * , (#temp1.SumOfRunningValueNewVaccin/population )* 100 TotalPercentageOfVacPop from #temp1
where location = 'india'

select location, new_vaccinations, sum( convert( bigint, new_vaccinations)) over( partition by location order by location , date), total_vaccinations from CovidVaccinations
where location = 'india'

--Creating view to store data for leter use

Create view PercentPopulationVaccinated as

With PopVsVac ( Continent, Location, date, population, New_vaccinations, SumOfRunningValueNewVaccin)
	as
	(
	Select CD.continent, CD.location, CD.date, CD.population, new_vaccinations
	, Sum(convert(bigint, new_vaccinations)) over ( Partition by CD.Location order by CD.location, CD.date) as SumOfRunningValueNewVaccin
	From CovidDeaths CD
	join CovidVaccinations CV 
	on CD.location = CV.location 
	and CD.date = cv.date
	Where cd.continent is not null and  new_vaccinations is not null and new_vaccinations > 0
	--order by 2,3
	)
	Select * , (SumOfRunningValueNewVaccin/population)*100 as PercentPopulationVaccinated
	 from PopVsVac

	 select * from PercentPopulationVaccinated