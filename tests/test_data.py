import duckdb
import pytest

import aviation.main


ROUTES = """
with routes as (
SELECT * FROM read_csv_auto('data/flight_emission_data_2025-01-17/emissionV22_2025-02-24.csv', header=true)
)
"""


@pytest.fixture(scope='session', autouse=True)
def data():
    aviation.main.ensure_data()


def test_global_emissions(data):
    # test that computed emissions are within 5% of the actual value
    total_emissions = f"""
{ROUTES}
SELECT
SUM(values_averageclass_co2withoutrfiperpassengerintons * frequency * emissionflightinfo_passengerloadfactor * seatcount) AS co2
FROM routes
"""
    result = duckdb.sql(total_emissions).fetchall()[0][0]

    # https://www.iea.org/energy-system/transport/aviation
    expected = 544.91e6  # in tons
    print(result, expected, abs(result - expected), abs(result - expected) / expected)
    assert abs(result - expected) / expected < 0.07


def test_passagers_within_count(data):
    sql = f"""
{ROUTES}
SELECT 
    SUM(emissionflightinfo_passengerloadfactor * seatcount * frequency) AS passengers,
    SUM(seatcount * frequency) AS seats
FROM routes
"""
    passengers, seats = duckdb.sql(sql).fetchall()[0]
    assert passengers < seats


def test_uniqueness(data):
    sql = f"""
{ROUTES}
SELECT 
COUNT(*) AS count,
COUNT(DISTINCT (airlineiatacode, aircraftiatacode, emissionflightinfo_arrivaliatacode, emissionflightinfo_departureiatacode)) AS unique_routes,
COUNT(DISTINCT id)  AS unique_id,
FROM routes
"""
    count, unique_routes, unique_id = duckdb.sql(sql).fetchall()[0]
    assert count == unique_id
    assert count == unique_routes


def test_average_load(data):
    query = f"""
    {ROUTES}
    SELECT
        airlineiatacode,
        SUM(emissionflightinfo_passengerloadfactor * frequency) / SUM(frequency) AS average_load
    FROM routes
    GROUP BY airlineiatacode
    """

    result = dict(duckdb.sql(query).fetchall())

    expected = {
        # https://corporate.ryanair.com/facts-figures/key-stats/#twentythree
        'FR': 0.96,
        # https://investor-relations.lufthansagroup.com/fileadmin/downloads/en/financial-reports/traffic-figures/lufthansa/2023/Traffic-figures-Q4-2023_EN.pdf
        'LH': 0.82,
        # https://americanairlines.gcs-web.com/news-releases/news-release-details/american-airlines-reports-fourth-quarter-and-full-year-2023
        'AA': 0.835,
    }

    for airline, expected in expected.items():
        observed = result[airline]
        assert abs(observed - expected) / expected < 0.1, (airline, observed, expected)
        print([airline, expected, observed, abs(observed - expected) / expected])
