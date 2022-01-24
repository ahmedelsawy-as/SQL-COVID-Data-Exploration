-- Exploring the dataset
select *
from [dbo].[covid_data];


select 
[location],[date],[population],[total_cases],[new_cases],[total_deaths],[new_deaths],[icu_patients],[hosp_patients],
[weekly_icu_admissions],[weekly_hosp_admissions],[total_vaccinations],[people_vaccinated],[people_fully_vaccinated],
[total_boosters],[new_vaccinations],[aged_70_older],[hospital_beds_per_thousand]
from [dbo].[covid_data]
where continent is not null
order by 1, 2;



-- select data that I will use
select
[continent],[location],[date],[population],[total_cases],[new_cases],[new_deaths],
[total_vaccinations],[new_vaccinations]
from covid_data
where continent is not null
order by 1,2




-- Exploring Global Data
--CREATE VIEW covid_world_data as
select
SUM(new_cases) as world_total_cases, 
SUM(cast(new_deaths as int)) as world_total_deaths,
SUM(convert(float, new_vaccinations)) as world_total_vaccinations
from covid_data
where continent is not null


-- total cases versus population 
-- showing likelihood to be infected if you live in  certain country
select
location, population, total_cases,
(total_cases/population)*100 as percentage_infected
from 
	(
	select 
	location, 
	AVG(population) as population,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub
--where location = 'Egypt'
order by percentage_infected desc


-- showing highest 20 countries in infection rates
select top 20
location, population, total_cases,
(total_cases/population)*100 as percentage_infected
from 
	(
	select 
	location, 
	AVG(population) as population,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub
order by percentage_infected desc


-- total deaths versus total cases 
-- showing likelihood to die if got infected in certain country
select
location,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	location,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub
--where location = 'Egypt'
order by percent_to_die_if_infected desc


-- showing highest 20 countries in death rates
select top 20
location,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	location,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub
order by percent_to_die_if_infected desc


-- showing lowest 40 countries in death rates
select top 40
location,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	location,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub
order by percent_to_die_if_infected 


-- showing death rates by continents
select 
continent,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	continent,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by continent
	) as sub
order by percent_to_die_if_infected desc



-- Total number of people who received at least one vaccine dose (people_vaccinated) versus population 
-- showing likelihood to received at least one vaccine dose if you live in  certain country

with temp as
			(
			select
			location,
			population,
			MAX(convert(float,people_vaccinated)) as people_vaccinated
			from covid_data
			where continent is not null
			group by location,population
			)
select
location, population, people_vaccinated,
(people_vaccinated/population)*100 as percentage_vaccinated
from temp
--where location = 'Egypt'
order by percentage_vaccinated  desc



-- showing top countries in people received at least one vaccine dose
with temp as
			(
			select
			location,
			population,
			MAX(convert(float,people_vaccinated)) as people_vaccinated
			from covid_data
			where continent is not null
			group by location,population
			)
select top 20
location, population, people_vaccinated,
(people_vaccinated/population)*100 as percentage_vaccinated
from temp
order by people_vaccinated desc


-- showing cummulative total cases per country
select
location,
date,
new_cases,
SUM(new_cases) over (partition by location order by location,date) as cummulative_sum_cases
from covid_data
where continent is not null


-- showing cummulative infection rates
with temp as
			(
			select
			location,
			date,
			population,
			new_cases,
			SUM(new_cases) over (partition by location order by location,date) as cummulative_sum_cases
			from covid_data
			where continent is not null
			)
select
*, (cummulative_sum_cases/population)*100 as runing_infection_percent
from temp
order by 1,2



-- Creating views to store data from previous insights

create view Covid_Infection_Rates as
select
location, population, total_cases,
(total_cases/population)*100 as percentage_infected
from 
	(
	select 
	location, 
	AVG(population) as population,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub


create view Covid_Death_Rates_Countries as
select
location,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	location,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by location
	) as sub


create view Covid_Death_Rates_Continents as
select 
continent,
total_deaths,
total_cases,
(total_deaths/total_cases)*100 as percent_to_die_if_infected
from
	(
	select
	continent,
	SUM(cast(new_deaths as float)) as total_deaths,
	SUM(new_cases) as total_cases
	from covid_data
	where continent is not null
	group by continent
	) as sub


create view Covid_Vaccination_Rates as
with temp as
			(
			select
			location,
			population,
			MAX(convert(float,people_vaccinated)) as people_vaccinated
			from covid_data
			where continent is not null
			group by location,population
			)
select
location, population, people_vaccinated,
(people_vaccinated/population)*100 as percentage_vaccinated
from temp


