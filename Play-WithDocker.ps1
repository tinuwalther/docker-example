#region my environment

#network
docker network create custom
docker network ls
docker network inspect custom

#volumes
docker volume create sqldata
docker volume create mysqldata
docker volume create mongodata
docker volume create mongoconf
docker volume create fileshare

docker pull mcr.microsoft.com/mssql/server:2019-latest
docker tag mcr.microsoft.com/mssql/server:2019-latest mssql:2019-latest
docker rmi mcr.microsoft.com/mssql/server:2019-latest
docker pull mysql:latest
docker pull mongo
docker images -a

#containers
docker run -e TZ="Europe/Zurich" -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 8433:1433 -v sqldata:/var/opt/mssql --hostname mssqlsrv1 --name mssqlsrv1 --network custom -d mssql:2019-latest
docker run -e TZ="Europe/Zurich" -e MYSQL_ROOT_PASSWORD=my-secret-pw -p 3306:3306 -v mysqldata:/var/lib/mysql --hostname mysqlsrv1 --name mysqlsrv1 --network custom -d mysql:latest
docker run -e TZ="Europe/Zurich" -it -p 27017:27017 -v mongodata:/data/db -v mongoconf:/data/configdb --name mongodb1 --hostname mongodb1 --network custom -d mongo
docker ps -a
#endregion


#region Linux Container
docker images -a

REPOSITORY   TAG           IMAGE ID       CREATED       SIZE
alpine       latest        6dbb9cc54074   2 weeks ago   5.61MB
pyhost       1.0.0         45fe1fb26c44   2 weeks ago   473MB
centos8      1.0.0         d4b86e62ff37   3 weeks ago   285MB
mssql        2019-latest   62c72d863950   4 weeks ago   1.49GB
mongo        latest        f03be0dc25f8   5 weeks ago   448MB

#region alpine
docker pull grafana/grafana
docker tag grafana/grafana grafana:latest
docker rmi grafana/grafana

docker run -d --name=grafana -p 3000:3000 grafana
admin/grafana

# <-- download image -->
docker pull alpine
docker images -a
docker inspect alpine

# <-- create volume -->
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+fileshare$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create fileshare
}

# <-- create container -->
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --hostname alpine1 --name alpine1 -d alpine:latest
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --hostname pyalpine1 --name pyalpine1 -d pyalpine:latest
docker ps -a

# <-- run bash on container -->
docker exec -it alpine1 /bin/ash

# <-- install python3 -->
apk --update-cache upgrade
apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
python3 -m ensurepip
pip3 install --no-cache --upgrade pip setuptools
cat /etc/os-release

# <-- create image from container -->
docker commit alpine1 pyalpine1
docker images -a

REPOSITORY   TAG           IMAGE ID       CREATED          SIZE
pyalpine     latest        860db30f5ddc   39 seconds ago   63.8MB

# <-- start, stop, remove container -->
docker start alpine1
docker stop alpine1
docker rm alpine1
#endregion

#region MSSQL Server

# <-- download image -->
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker tag mcr.microsoft.com/mssql/server:2019-latest mssql:2019-latest
docker rmi mcr.microsoft.com/mssql/server:2019-latest
docker images -a

# <-- create volume -->
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+sqldata$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create sqldata
}

# <-- create container -->
docker run -e TZ="Europe/Zurich" -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 8433:1433 -v sqldata:/var/opt/mssql --hostname mssqlsrv1 --name mssqlsrv1 --network custom -d mssql:2019-latest
docker run -e TZ="Europe/Zurich" -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 9433:1433 -v sqldata:/var/opt/mssql --hostname mssqlsrv2 --name mssqlsrv2 --network custom -d mssql:2019-latest
docker ps -a

# <-- run sqlcmd on container -->
docker exec -it mssqlsrv1 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'yourStrong(!)Password'
docker exec -it mssqlsrv2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'yourStrong(!)Password'
EXEC sp_databases;

# Install Extension mssql for Visual Studio Code

# <-- start, stop, remove container -->
docker start mssqlsrv1
docker stop mssqlsrv1
docker rm mssqlsrv1 -f

#endregion

#region universal
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+psudata$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create psudata
}
docker run -e TZ="Europe/Zurich" -p 5000:5000 -v psudata:/data --hostname psuhost1 --name psuhost1 --network custom -d psuhost:1.0.0
#endregion

#region mongodb
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+mongodata$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create mongodata
}
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+mongoconf$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create mongoconf
}

docker pull mongo
docker run -e TZ="Europe/Zurich" -it -p 27017:27017 -v mongodata:/data/db -v mongoconf:/data/configdb --name mongodb1 --hostname mongodb1 --network custom -d mongo

Invoke-WebRequest -URI http://localhost:27017 | Select Status*,Content

# Install Extension MongoDB for VS Code
docker start mongodb1
docker stop mongodb1
docker rm mongodb1
#endregion

#region Build images from dockerfiles

# For Windows
$Location = "D:\docker\"
Set-Location "$Location\alpine"; docker build -f "D:\docker\alpine\dockerfile" -t alpine:latest .
Set-Location "$Location\centos"; docker build -f "D:\docker\centos\dockerfile" -t centos8:1.0.0 .
Set-Location "$Location\pyhost"; docker build -f "D:\docker\pyhost\dockerfile" -t pyhost:1.0.0 .
Set-Location "$Location\pshost"; docker build -f "D:\docker\pshost\dockerfile" -t pshost:1.0.0 .

# For Mac OS
$Location = "/Users/Tinu/git/github.com/docker-example"
Set-Location "$Location/pyhost"; docker build -f "$Location/pyhost/dockerfile" -t pyhost:1.0.0 .
Set-Location "$Location/pshost"; docker build -f "$Location/pshost/Dockerfile" -t pshost:1.0.0 .
Set-Location "$Location/psuhost"; docker build -f "$Location/psuhost/dockerfile" -t psuhost:1.0.0 .

docker images -a
#endregion

#region compose
docker-compose -f "D:\docker\centos\docker-compose.yml"
#endregion

#region volume
Set-Location "/docker/volumes"
docker volume ls
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+fileshare$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create mongod
}

# <-- backup volume -->
https://github.com/loomchild/volume-backup

docker volume ls
#backup
$Location = "D:\docker\"
Set-Location "$Location\alpine"; docker build -f "D:\docker\alpine\dockerfile" -t alpine:latest .

docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup backup [archive-name]
docker run -v sqldata:/volume -v D:\docker\backup:/backup --rm alpine:latest backup sqldata

docker run --rm --volumes-from mssqlsrv1 -v D:\docker\backup:/backup ubuntu tar cvf /backup/backup.tar /sqldata
docker run --rm --volume mssqlsrv1:/source --volume D:\docker\backup:/backup ubuntu tar -cvf mssqlsrv1.tar -C /source .
docker exec -it mssqlsrv1 /bin/bash

#restore
docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup restore [archive-name]
docker run -v sqldata:/volume -v /tmp:/backup --rm loomchild/volume-backup restore some_archive

docker run -d --name access_volume --volume hello:/sqldata busybox
docker cp access_volume:/sqldata local-data
# modify local-data
docker cp local-data access_volume:/sqldata


docker rm fileshare
docker volume prune
#endregion

#region start container
# <-- create volume -->
$volume = foreach($item in (docker volume ls)){
    if($item -match 'local\s+fileshare$'){
        $true; break
    }
}
if(-not($volume)){
    docker volume create fileshare
}

docker run -e TZ="Europe/Zurich" -v fileshare:/shared-volume --hostname centos8 --name centos8  -it centos8:1.0.0 /bin/bash
docker run -e TZ="Europe/Zurich" -v fileshare:/shared-volume --hostname pyhost1 --name pyhost1  -it pyhost:1.0.0  /bin/bash
docker run -e TZ="Europe/Zurich" -v fileshare:/shared-volume --hostname pshost1 --name pshost1  -it pshost:1.0.0  pwsh

# create container with user-defined-network-bridge
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --network custom --hostname pyhost1 --name pyhost1 -d pyhost:1.0.0
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --network custom --hostname pyhost2 --name pyhost2 -d pyhost:1.0.0
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --network custom --hostname pshost1 --name pshost1 -d pshost:1.0.0

docker run -e TZ="Europe/Zurich" -it -v mongodata:/data/db -v mongoconf:/data/configdb --name mongodb1 --hostname mongodb1 --network custom -d mongo

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
docker exec -it centos8  /bin/bash
docker exec -it pyhost1 /bin/bash
docker exec -it pyhost2 /bin/bash
docker exec -it mssqlsrv1 /bin/bash
docker exec -it pshost1 pwsh
#endregion

#region remove the container
docker rm centos8
docker rm pyhost1 -f
docker rm pyhost2 -f
docker rm mongodb1 -f
docker rm pshost1
docker rm mssqlsrv1
#endregion

#region remove the image
docker rmi entos8:1.0.0
docker rmi pyhost:1.0.0
docker rmi pshost:1.0.0
#endregion

#region rename image
docker images -a
docker tag CURRENT_IMAGE_NAME DESIRED_IMAGE_NAME
docker tag local/pyscripthost:1.0.0 pyhost:1.0.0
docker rmi local/pyscripthost:1.0.0
#endregion

#endregion

#region Windows Container
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