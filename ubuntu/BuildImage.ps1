# Build almalinux with python and pwsh
Set-Location "F:\github.com\docker\ubuntu"
$ImageName = 'tubutu'
break

# Run Snyk tests against images to find vulnerabilities and learn how to fix them
docker build -f .\dockerfile -t $ImageName .
docker scan --accept-license $ImageName
break

# Start a container
$Container = "$($ImageName)1"
$HostName  = "$($ImageName)1"
docker run -e TZ="Europe/Zurich" --hostname $HostName --name $Container -v fileshare:/data --network custom -it $ImageName /bin/bash
break
docker start $Container
docker exec -it $Container sh

# Remove the container
docker stop $Container
docker rm $Container

# Remove the image
docker rmi $ImageName