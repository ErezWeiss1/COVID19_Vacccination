

/* Deaths and Vaccinations - world */


Select	location,
		population, 
		max(total_cases) as total_cases,
		max(cast(total_deaths as int)) as total_deaths,
		max(cast(total_deaths as int))/population*100 as "deaths_%_population",
		max(cast(people_fully_vaccinated as int)) as people_fully_vaccinated,
		max(cast(people_fully_vaccinated as int))/population*100 as "fully_vaccinated_%_population"
	
from dbo.CovidData
where location = 'world'
group by location,population
order by "fully_vaccinated_%_population" desc


/* Deaths and Vaccinations - continent */


Select	location as Continent,
		max(cast(total_deaths as int)) as total_deaths,
		max(cast(people_fully_vaccinated as int)) as people_fully_vaccinated

from dbo.CovidData
Where continent is null and location not in ('World', 'European Union', 'International')
group by location
order by people_fully_vaccinated desc


/* Vaccinations - world map */


Select	location,
		continent,
		max(cast(people_fully_vaccinated as int))/population*100 as "fully_vaccinated_%_population"

from dbo.CovidData
where continent is not null and population is not null
group by location,continent,population
order by "fully_vaccinated_%_population" desc


/* GDP and Vaccinations - scatter plot */


begin
with vac_GDP(location,continent,"fully_vaccinated_%_population",gdp_per_capita) as
(
Select	location,
		continent,
		max(cast(people_fully_vaccinated as int))/population*100 as "fully_vaccinated_%_population",
		gdp_per_capita

from dbo.CovidData
where continent is not null and population>100000
group by location,population,gdp_per_capita,continent
)
select*

from vac_GDP
where "fully_vaccinated_%_population" BETWEEN 0 and 100 and gdp_per_capita is not null
order by 2,3 desc ,4
end


/* Vaccinations - distribution */


Select  location,
		continent,
		population, 
		max(cast(people_fully_vaccinated as int)) as people_fully_vaccinated,
		max(cast(people_fully_vaccinated as int))/population*100 as "fully_vaccinated_%_population"

from dbo.CovidData
where continent is not null
group by location,continent,population
order by 2,1


/* Vaccinations - top country from each continent */


begin
with vac_top_chart (continent,location,total_vaccinations) as
(
Select	continent,
		location,
		max(cast (total_vaccinations as int))as total_vaccinations

from dbo.CovidData
where continent is not null
group by location,continent
)
select top 1 with ties   
		*

from vac_top_chart
order by row_number() over (partition by continent order by total_vaccinations desc)
end


/* Total Vaccinations */


Select  continent,
		location,
		date,
		(cast (total_vaccinations as int))as total_vaccinations

from dbo.CovidData
where continent is not null
order by 1,2,3