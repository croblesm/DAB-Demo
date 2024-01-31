# Create docker network
docker network create library-network

# SQL Container
docker run \
    --hostname SQL-Library \
    --name SQL-Library \
    --env 'ACCEPT_EULA=Y' --env 'MSSQL_SA_PASSWORD=P@ssw0rd!' \
    --publish 1401:1433 \
    --network library-network \
    --platform linux/amd64 \
    --detach mcr.microsoft.com/mssql/server:2019-latest

# SQLCMD env variable - SA password
# export SQLCMDPASSWORD=P@ssw0rd! 

# Connect and execute queries (no SA exposed)
sqlcmd -S localhost,1401 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT name from sys.databases;" -C
sqlcmd -S localhost,1401 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT @@SERVERNAME;" -C

# Create database and tables
sqlcmd -S localhost,1401 -U SA -d master -e -i ./Scripts/library.azure-sql.sql -C

# Connect and execute queries (no SA exposed)
sqlcmd -S localhost,1401 -U SA -d library -h -1 -Q "SET NOCOUNT ON;SELECT TABLE_NAME FROM library.INFORMATION_SCHEMA.TABLES;" -C
sqlcmd -S localhost,1401 -U SA -d library -h -1 -Q "SET NOCOUNT ON; SELECT title FROM books where id <= 1005;" -C

# DAB Container
docker run \
    --name DAB-Library \
    --volume "./DAB-Config:/App/configs" \
    --publish 5001:5000 \
    --env-file "./DAB-Config/.env" \
    --network library-network \
    --platform linux/amd64 \
    --detach mcr.microsoft.com/azure-databases/data-api-builder:latest \
    --ConfigFileName /App/configs/dab-config.json

# Checking image env variables
docker exec DAB-Library env

# Testing DAB health
curl -v http://localhost:5001/

# Testing DAB API
curl -s http://localhost:5001/api/Book | jq
curl -s http://localhost:5001/api/Author | jq

# Testing DAB API with jq
curl -s 'http://localhost:5001/api/Book?$first=2' | jq '.value[] | {id, title}'
curl -s http://localhost:5001/api/Author | jq '.value[1] | {id, first_name, last_name}'

# Testing DAB API with jq and filter
# From brower
http://localhost:5001/api/Book?$first=2&$orderby=id
http://localhost:5001/api/Book?$first=2&$orderby=id desc

# From command line
curl -s 'http://localhost:5001/api/Book?$first=2&$orderby=id' | jq
curl -s 'http://localhost:5001/api/Book?$first=2&$orderby=id' | jq

# Testing DAB API with GraphQL
curl -X POST -H "Content-Type: application/json" -d '{"query": "{ books(first: 2, orderBy: {id: ASC}) { items { id title } } }"}' http://localhost:5001/graphql | jq


# Using docker compose
SA_PASSWORD=P@ssw0rd! docker-compose up -d

# Destroying containers
docker-compose down -v

# Testing DAB API
curl -s http://localhost:5001/api/Book | jq
curl -s http://localhost:5001/api/Author | jq

# Docker compose diagram
docker run --rm -it --name dcv -v .:/input pmsipilot/docker-compose-viz render -m image --force docker-compose.yml --output-file=topology.png