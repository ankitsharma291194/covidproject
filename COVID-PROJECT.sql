SELECT * FROM covid.`covid-death`;

# TOTAL CASES VS TOTAL DEATH
SELECT date, continent, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent FROM covid.`covid-death`
WHERE location like '%india%'
ORDER BY total_cases DESC;

# TOTAL CASES VS POPULATIOM
SELECT date, location, total_cases, population, (total_cases/population)*100 as covidpercent FROM covid.`covid-death`
WHERE location like '%india%'
ORDER BY covidpercent DESC;

# HIGHEST INFECTION RATE COUNTRY
SELECT  location, max(cast(total_cases as unsigned)) as higestinfection, population, max((total_cases/population))*100 as populationpercent FROM covid.`covid-death`
GROUP BY location , population
ORDER BY populationpercent DESC;

# HIGHEST DEATH COUNTRY
SELECT  location, max(cast(total_deaths as unsigned)) as totaldeath FROM covid.`covid-death`
WHERE continent IS NOT NULL AND continent <> ''
GROUP BY location 
ORDER BY totaldeath DESC;

# HIGHEST DEATH CONTINENT
SELECT  continent, max(cast(total_deaths as unsigned)) as totaldeath FROM covid.`covid-death`
WHERE  continent <> ''
GROUP BY continent 
ORDER BY totaldeath DESC;

# GLOBAL NUMBER
SELECT SUM(cast(new_cases as unsigned)) as all_case, SUM(cast(new_deaths as unsigned)) as all_death,  (SUM(cast(new_cases as unsigned))/SUM(cast(new_deaths as unsigned)))*100 as deathpercent 
FROM covid.`covid-death`
ORDER BY deathpercent DESC;

#JOIN
SELECT * FROM covid.`covid-death` dea
JOIN covid.`covid-vacine` vac
    ON dea.location = vac.location
    AND dea.dated = vac.dated

#total population vs total vacination
SELECT dea.continent, dea.location, dea.dated, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.dated) AS ROLLINGVACINE
FROM covid.`covid-death` dea
JOIN covid.`covid-vacine` vac
    ON dea.location = vac.location
    AND dea.dated = vac.dated
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


#CTE
WITH PopvsVac (continent, location, dated, population, new_vaccinations, ROLLINGVACINE)
as
(
SELECT dea.continent, dea.location, dea.dated, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.dated) AS ROLLINGVACINE
FROM covid.`covid-death` dea
JOIN covid.`covid-vacine` vac
    ON dea.location = vac.location
    AND dea.dated = vac.dated
WHERE dea.continent IS NOT NULL
)
SELECT * , (ROLLINGVACINE/cast(population as unsigned))*100
FROM PopvsVac

# TEMP TABLE

DROP TABLE IF exist VACINATEDPEOPLE
CREATE TABLE VACINATEDPEOPLE
(
continent VARCHAR(255),
location VARCHAR(255),
dated DATE,
population NUMERIC,
new_vaccinations NUMERIC,
ROLLINGVACINE NUMERIC
)

INSERT INTO VACINATEDPEOPLE
SELECT dea.continent, dea.location, dea.dated, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.dated) AS ROLLINGVACINE
FROM covid.`covid-death` dea
JOIN covid.`covid-vacine` vac
    ON dea.location = vac.location
    AND dea.dated = vac.dated
WHERE dea.continent IS NOT NULL

SELECT * , (ROLLINGVACINE/(population )*100
FROM VACINATEDPEOPLE


# CREATE VIEW TO STORE DATA

CREATE VIEW HIGHESTDEATHCONTINENT AS
SELECT  continent, max(cast(total_deaths as unsigned)) as totaldeath FROM covid.`covid-death`
WHERE  continent <> ''
GROUP BY continent 
ORDER BY totaldeath DESC;

SELECT * FROM HIGHESTDEATHCONTINENT