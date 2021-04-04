
#region Build images from dockerfiles
$Location = "D:\docker\"
Set-Location "$Location\centos"; docker build -f "D:\docker\centos\dockerfile" -t local/centos8:1.0.0 .
Set-Location "$Location\pyhost"; docker build -f "D:\docker\pyhost\dockerfile" -t local/pyscripthost:1.0.0 .
Set-Location "$Location\pshost"; docker build -f "D:\docker\pshost\dockerfile" -t local/psscripthost:1.0.0 .
docker images -a
#endregion

#region compose
docker-compose -f "D:\docker\centos\docker-compose.yml"
#endregion

#region volume
Set-Location "D:\docker\volumes"
docker volume ls
docker volume create localvolume
docker volume inspect localvolume
docker volume ls
docker rm localvolume
docker volume prune
#endregion

#region start container
docker run -v localvolume:/shared-volume --hostname centos8 --name centos8  -it local/centos8:1.0.0 /bin/bash
docker run -v localvolume:/shared-volume --hostname pyhost  --name pycentos -it local/pyhost:1.0.0  /bin/bash
docker run -v localvolume:/shared-volume --hostname pshost  --name pscentos -it local/pshost:1.0.0  pwsh
docker ps
#endregion

#region start a container
docker start centos8
docker start pycentos
docker start pscentos
#endregion

#region stop container
docker stop centos8
docker stop pycentos
docker stop pscentos
#endregion

#region attach bash or powershell to a running container
docker exec -it centos8  /bin/bash
docker exec -it pycentos /bin/bash
docker exec -it pscentos pwsh
#endregion

#region remove the container
docker rm centos8
docker rm pycentos
docker rm pscentos
#endregion

#region remove the image
docker rmi local/centos8:1.0.0
docker rmi local/pyhost:1.0.0
docker rmi local/pshost:1.0.0
#endregion
