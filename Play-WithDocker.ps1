
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
docker volume prune
#endregion

#region start container
docker run -v fileshare:/shared-volume --hostname centos8 --name centos8  -it centos8:1.0.0 /bin/bash
docker run -v fileshare:/shared-volume --hostname pyhost1 --name pyhost1  -it pyhost:1.0.0  /bin/bash
docker run -v fileshare:/shared-volume --hostname pshost1 --name pshost1  -it pshost:1.0.0  pwsh

docker run -it -v fileshare:/shared-volume --hostname pyhost1 --name pyhost1 -d pyhost:1.0.0
docker run -it -v fileshare:/shared-volume --hostname pyhost2 --name pyhost2 -d pyhost:1.0.0

docker ps -s
#endregion

#region start a container
docker start centos8
docker start pyhost1
docker start pshost1
#endregion

#region stop container
docker stop centos8
docker stop pyhost1
docker stop pshost1
#endregion

#region attach bash or powershell to a running container
docker exec -it centos8  /bin/bash
docker exec -it pyhost1 /bin/bash
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