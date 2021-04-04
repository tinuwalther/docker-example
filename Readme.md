# Docker

![Docker](docker-icon.png)

````text
root:
|   Play-WithDocker.ps1
|   Create-PythonAndMongoDbEnv.ps1
|
+---centos
|       dockerfile
|
+---pshost
|       dockerfile
|       PsNetTools.zip
|
\---pyhost
        dockerfile
        get-mongodbs.py
````

## Create a mongodb host

### Create the image

Donwload the latest image from [Docker Hub](https://hub.docker.com/_/mongo).

````powershell
docker pull mongo
````

### Create the container

````powershell
docker run -it --name mongodb -d mongo
docker ps -s
````

Get the ip address of the mongodb-container:

````powershell
$container = docker inspect mongodb
$object = $container | ConvertFrom-Json
$object | Select-Object Name, @{l="IPAddress";e={$object.NetworkSettings.IPAddress}}
````

## Create a python host

### Create the dockerfile

````powershell
$pyhost = @"
FROM centos:8
LABEL os="CentOS 8"
LABEL author="Martin Walther"
LABEL content="Python3"
LABEL release-date="2021-04-03"
LABEL version="0.0.1-beta"
ENV container docker
RUN echo "*** Build Image ***"
RUN yum -y update && yum clean all
RUN yum install git -y
RUN yum install -y python3
RUN python3 -m pip install -U pip
RUN python3 -m pip install pywinrm
RUN python3 -m pip install pymongo
RUN echo "*** Build finished ***"
"@

function New-Dockerfile{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String] $Location, 

        [Parameter(Mandatory=$true)]
        [String] $content
    )
    if(Test-Path $Location){
        Write-Host "$Location already exists"
    }else{
        $null = New-Item $Location -ItemType Directory
    }
    $content | Out-File (Join-Path $Location 'dockerfile') -Force
    Get-Item (Join-Path $Location 'dockerfile') | Select-Object Name,LastWriteTime,Length
}

New-Dockerfile -Location "D:\docker\pyhost" -content $pyhost
````

### Create the image

````powershell
Set-Location "D:\docker\pyhost"; docker build -f "D:\docker\pyhost\dockerfile" -t pyhost:1.0.0 .
````

### Create the container

````powershell
docker run -it --hostname pyhost --name pyhost -d pyhost:1.0.0
````

## Work on the python host

Login to the python-host and create the python-script to connect to the mongodb.

````powershell
docker exec -it pyhost  /bin/bash
````

````bash
cd /home
touch get-mongodbs.py
vi get-mongodbs.py
````

Insert the following code and save the file (esc, :wq):

````python3
import sys

def get_dbs(connectionstring):
    '''Connect to MongoDB and print out all databases'''
    import pymongo
    mongo_client = pymongo.MongoClient(connectionstring)
    print(mongo_client.list_database_names())
    mongo_client.close()

if len(sys.argv) == 1:
  mongohost = ''
else:
  mongohost = str(sys.argv[1])

if len(mongohost) == 0 or mongohost == '--help':
  print('Usage: python3 ' + str(sys.argv[0]) + ' <argument>')
  print('  Argument: hostname or ip-address to connect to the mongodb')
  print('  Example:  172.17.0.2')
else:
  connectionstring = "mongodb://"+ mongohost
  print('Trying to connect to: ' + connectionstring + ':27017')
  get_dbs(connectionstring)
````

Run the python-script and print all database:

````bash
python3 get-mongodbs.py <ip address of the mongodb>
````

````bash
Trying to connect to: mongodb://172.17.0.2:27017
['admin', 'config', 'local']
````
