#region Windows
https://hub.docker.com/search?q=windows&type=image

# <-- 1. configure environment -->
Enable-WindowsOptionalFeature -Online -FeatureName $("Microsoft-Hyper-V", "Containers") -All

# <-- 2. switch docker to windows -->
& $env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon .

# <-- 3. download image, 1.718GB -->
docker pull mcr.microsoft.com/windows/servercore:ltsc2019
docker tag mcr.microsoft.com/windows/servercore:ltsc2019 winsrvc:ltsc2019
docker rmi mcr.microsoft.com/windows/servercore:ltsc2019
docker images -a

REPOSITORY   TAG        IMAGE ID       CREATED       SIZE
winsrvc      ltsc2019   152749f71f8f   2 weeks ago   5.27GB

# <-- 4. Create a container -->
docker run -it --network nat --hostname winsrv1 --name winsrv1 -d winsrvc:ltsc2019
docker run -it --network nat --hostname winsrv2 --name winsrv2 -d winsrvc:ltsc2019
docker ps -s

# <-- 5. Run a container -->
docker exec -it winsrv1 powershell
docker exec -it winsrv2 powershell

docker start winsrv1
docker start winsrv2

docker stop winsrv1
docker stop winsrv2

#endregion

#region Linux
REPOSITORY   TAG           IMAGE ID       CREATED       SIZE
pyhost       1.0.0         45fe1fb26c44   13 days ago   473MB
centos8      1.0.0         d4b86e62ff37   3 weeks ago   285MB
mongo        latest        f03be0dc25f8   4 weeks ago   448MB

#region MSSQL Server

# <-- download image -->
docker pull alpine
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker tag mcr.microsoft.com/mssql/server:2019-latest mssql:2019-latest
docker rmi mcr.microsoft.com/mssql/server:2019-latest
docker images -a

REPOSITORY   TAG           IMAGE ID       CREATED       SIZE
mssql        2019-latest   62c72d863950   3 weeks ago   1.49GB

#endregion

#region Build images from dockerfiles

# For Windows
$Location = "D:\docker\"
Set-Location "$Location\centos"; docker build -f "D:\docker\centos\dockerfile" -t centos8:1.0.0 .
Set-Location "$Location\pyhost"; docker build -f "D:\docker\pyhost\dockerfile" -t pyhost:1.0.0 .
Set-Location "$Location\pshost"; docker build -f "D:\docker\pshost\dockerfile" -t pshost:1.0.0 .

# For Mac OS
$Location = "/Users/Tinu/git/github.com/docker-example"
Set-Location "$Location/pyhost"; docker build -f "$Location/pyhost/dockerfile" -t pyhost:1.0.0 .

docker images -a
#endregion

#region compose
docker-compose -f "D:\docker\centos\docker-compose.yml"
#endregion

#region volume
Set-Location "/docker/volumes"
docker volume ls
docker volume create fileshare
docker volume inspect fileshare
docker volume ls
docker rm fileshare
docker volume create sqldata
docker volume prune
#endregion

#region start container
docker run -v fileshare:/shared-volume --hostname centos8 --name centos8  -it centos8:1.0.0 /bin/bash
docker run -v fileshare:/shared-volume --hostname pyhost1 --name pyhost1  -it pyhost:1.0.0  /bin/bash
docker run -v fileshare:/shared-volume --hostname pshost1 --name pshost1  -it pshost:1.0.0  pwsh

docker run -it -v fileshare:/shared-volume --hostname pyhost1 --name pyhost1 -d pyhost:1.0.0
docker run -it -v fileshare:/shared-volume --hostname pyhost2 --name pyhost2 -d pyhost:1.0.0

# create container with user-defined-network-bridge
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 1433:1433 -v sqldata:/var/opt/mssql --hostname mssqlsrv1 --name mssqlsrv1 --network custom -d mssql:2019-latest

docker run -it --network custom --hostname pyhost1 --name pyhost1 -d pyhost:1.0.0
docker run -it --network custom --hostname pyhost2 --name pyhost2 -d pyhost:1.0.0
docker network inspect custom

docker ps -s
#endregion

#region start a container
docker start mssqlsrv1
docker start centos8
docker start pyhost1
docker start pyhost2
docker start pshost1
#endregion

#region stop container
docker stop mssqlsrv1
docker stop centos8
docker stop pyhost1
docker stop pyhost2
docker stop pshost1
#endregion

#region attach bash or powershell to a running container
docker exec -it mssqlsrv1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'yourStrong(!)Password'
docker exec -it centos8  /bin/bash
docker exec -it pyhost1 /bin/bash
docker exec -it pyhost2 /bin/bash
docker exec -it mssqlsrv1 /bin/bash
docker exec -it pshost1 pwsh
#endregion

#region remove the container
docker rm centos8
docker rm pyhost1
docker rm pshost1
#endregion

#region remove the image
docker rmi entos8:1.0.0
docker rmi pyhost1:1.0.0
docker rmi pshost1:1.0.0
#endregion

#region rename image
docker images -a
docker tag CURRENT_IMAGE_NAME DESIRED_IMAGE_NAME
docker tag local/pyscripthost:1.0.0 pyhost:1.0.0
docker rmi local/pyscripthost:1.0.0
#endregion

#endregion