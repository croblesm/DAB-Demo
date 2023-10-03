# export SQLCMDPASSWORD="_SqLr0ck5_"; 
# echo $SQLCMDPASSWORD

# SQL Container (ARM)
# docker run \
#     --name SQL-Plex \
#     --hostname SQL-Plex \
#     --env 'ACCEPT_EULA=Y' \
#     --env 'MSSQL_SA_PASSWORD=_SqLr0ck5_' \
#     --env 'MSSQL_PID=Developer' \
#     --publish 1401:1433 \
#     --network dab-network \
#     --platform linux/amd64 \
#     --detach mcr.microsoft.com/azure-sql-edge:latest
#     --detach mcr.microsoft.com/mssql/server:2019-latest

# Create docker network
docker network create dab-network
# --detach mcr.microsoft.com/mssql/server:2019-latest

# SQL Container
docker run \
    --name SQL-Plex \
    --hostname SQL-Plex \
    --env 'ACCEPT_EULA=Y' \
    --env 'MSSQL_SA_PASSWORD=_SqLr0ck5_' \
    --env 'MSSQL_PID=Developer' \
    --publish 1401:1433 \
    --network dab-network \
    --platform linux/amd64 \
    --detach mcr.microsoft.com/mssql/server:2019-latest

#"connection-string": "Server=localhost,1401;Database=HumanResources;User ID=SA;Password=_SqLr0ck5_;TrustServerCertificate=true",
#"$schema": "dab.draft-01.schema.json",

# Get SQL Server port
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker port SQL-Plex

# Checking SQL client
docker exec -it SQL-Plex "bash"

# Connect and execute queries (no SA exposed)
sqlcmd -S localhost,1401 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT name from sys.databases;" -C
sqlcmd -S localhost,1401 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT @@SERVERNAME;" -C

# Create database
# sqlcmd -S localhost,1401 -U SA -d master -e -i Create_Database.sql -C
# sqlcmd -S localhost,1401 -U SA -d HumanResources -h -1 -Q "SET NOCOUNT ON;SELECT TABLE_NAME FROM HumanResources.INFORMATION_SCHEMA.TABLES;" -C
# sqlcmd -S localhost,1401 -U SA -d HumanResources -Q "SET NOCOUNT ON;SELECT EmpID, EmpName FROM dbo.Employee;" -C
sqlcmd -S localhost,1401 -U SA -d master -e -i library.azure-sql.sql -C
sqlcmd -S localhost,1401 -U SA -d library -h -1 -Q "SET NOCOUNT ON;SELECT TABLE_NAME FROM library.INFORMATION_SCHEMA.TABLES;" -C
sqlcmd -S localhost,1401 -U SA -d library -h -1 -Q "SET NOCOUNT ON; SELECT title FROM books where id <= 1005;" -C

# DAB container
# docker run \
#     --name DAB-Plex \
#     --volume "/workspaces/DAB-Demo/DAB-Config:/App/configs" \
#     --publish 5001:5000 \
#     --network dab-network \
#     --detach mcr.microsoft.com/azure-databases/data-api-builder:latest \
#     --ConfigFileName /App/configs/dab-config.json

# # With env variable
# docker run \
#     --name DAB-Plex-env \
#     --volume "/workspaces/DAB-Demo/DAB-Config:/App/configs" \
#     --publish 5002:5000 \
#     --network dab-network \
#     --env CONN_STRING="Server=SQL-Plex,1433;Database=HumanResources;User ID=SA;Password=_SqLr0ck5_;TrustServerCertificate=true" \
#     --detach mcr.microsoft.com/azure-databases/data-api-builder:latest \
#     --ConfigFileName /App/configs/dab-config-env.json

# With env config file
docker run \
    --name DAB-Plex \
    --volume "./DAB-Config:/App/configs" \
    --publish 5001:5000 \
    --env-file "./DAB-Config/.env" \
    --network dab-network \
    --platform linux/amd64 \
    --detach mcr.microsoft.com/azure-databases/data-api-builder:latest \
    --ConfigFileName /App/configs/dab-config-env.json

# Checking image env variables
docker exec DAB-Plex env
docker inspect -f \
   '{{range $index, $value := .Config.Env}}{{$value}} {{end}}' DAB-Plex

docker inspect DAB-Plex | jq '.[] | .Config.Env'


docker inspect   --format '{{ .NetworkSettings.IPAddress }}' SQL-Plex
#172.17.0.2

curl http://localhost:5001/
curl -v http://localhost:5001/

curl --request GET --url http://localhost:5001/api/Book
curl --request GET --url http://localhost:5001/api/Author
#curl --request GET --url http://localhost:5001/api/Employee

#curl --silent --request GET --url http://localhost:5001/api/Employee | jq '.value[] | {EmpID, EmpName}'
#curl --silent --request GET --url http://localhost:5001/api/Employee | jq '.value[2] | {EmpID, EmpName}'
curl --silent --request GET --url http://localhost:5001/api/Book | jq '.value[] | {id, title}' | head -n 5
curl --silent --request GET --url http://localhost:5001/api/Author | jq '.value[1] | {id, first_name, last_name}'

#https://zany-waffle-g5wr5x9v9q9hgp9-5001.app.github.dev/api/Employee

docker rm -f DAB-Plex
docker exec -it DAB-Plex "bash"
docker logs -f DAB-Plex

#"connection-string": "Server=172.17.0.2,1433;Database=HumanResources;User ID=SA;Password=_SqLr0ck5_;TrustServerCertificate=true"
#"connection-string": "@env('my-connection-string')"

#http://127.0.0.1:5001/api/Employee?$first=2&$orderby=EmpID
#http://127.0.0.1:5001/api/Employee?$first=2&$orderby=EmpID desc

http://localhost:5001/api/Book?$first=2&$orderby=id
http://localhost:5001/api/Book?$first=2&$orderby=id desc


# FROM mcr.microsoft.com/azure-databases/data-api-builder:latest

# WORKDIR /App/configs
# COPY DAB-Config/dab-config-env.json ./
# COPY env.list ./
# CMD ["dotnet", "Azure.DataApiBuilder.Service.dll"]

# docker build -t DABv2:1 .
# docker run --env-file env.list DABv2:1

# docker run \
#     --name DAB-Plex-env \
#     --volume "/workspaces/DAB-Demo/DAB-Config:/App/configs" \
#     --publish 5002:5000 \
#     --network dab-network \
#     --detach DABv2:1 \
#     --env-file env.list \
#     --ConfigFileName /App/configs/dab-config-env.json


docker run --name DAB-Plex-env --publish 5002:5000 --detach mcr.microsoft.com/azure-databases/data-api-builder:latest

curl http://localhost:5002/

dkrm DAB-Plex-env
dkstp DAB-Plex-env
dkstrt DAB-Plex-env
dklgsf DAB-Plex-env