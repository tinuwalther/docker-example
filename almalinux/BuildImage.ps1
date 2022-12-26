# Build almalinux with python and pwsh
# https://osnote.com/how-to-install-python-on-almalinux-8/
# https://tecadmin.net/install-python-3-7-on-centos-8/

Set-Location "F:\github.com\docker\almalinux"
$ImageName = 'talma'

# Run Snyk tests against images to find vulnerabilities and learn how to fix them
docker build -f .\dockerfile -t $ImageName .
break
docker scan --accept-license $ImageName

# Start a container
$Container = "$($ImageName)1"
$HostName  = "$($ImageName)1"
docker run -e TZ="Europe/Zurich" --hostname $HostName --name $Container -v fileshare:/data --network custom -it $ImageName /bin/bash
cat /etc/almalinux-release
python3.7 -V
pwsh
Get-EsxSoftwareDepot
break

docker start $Container
docker exec -it $Container /bin/bash

# Remove the container
exit
docker stop $Container
docker rm $Container

# Remove the image
docker rmi $ImageName