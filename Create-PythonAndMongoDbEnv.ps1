#region define python-host for the docker file
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
RUN yum install bind-utils -y
RUN dnf install glibc-langpack-de -y
RUN yum install git -y
RUN yum install -y python3
RUN python3 -m pip install -U pip
RUN python3 -m pip install pywinrm
RUN python3 -m pip install pymongo
RUN python3 -m pip install pandas
RUN python3 -m pip install html2text
RUN mkdir /home/scripts/
COPY get-mongodbs.py /home/scripts/
COPY py-listener.py /home/scripts/
COPY py-sender.py /home/scripts/
RUN echo "*** Build finished ***"
"@
#endregion

function New-MongoDBContainer{
    <#
    .SYNOPSIS
        New-MongoDBContainer

    .DESCRIPTION
        Create a New-MongoDBContainer

    .PARAMETER ContainerName
        The name of the new container

    .PARAMETER ImageName
        The name of the image

    .EXAMPLE
        New-MongoDBContainer -ContainerName mongodb -ImageName mongo
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String] $ContainerName,

        [Parameter(Mandatory=$true)]
        [String] $ImageName
    )

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

    docker pull $ImageName
    docker run -e TZ="Europe/Zurich" -it -p 27017:27017 -v mongodata:/data/db -v mongoconf:/data/configdb --name "$($ContainerName)1" --hostname "$($ContainerName)1" --network custom -d $ImageName
    $container = docker inspect $ContainerName
    $object = $container | ConvertFrom-Json
    $object | Select-Object Name, @{l="IPAddress";e={$object.NetworkSettings.IPAddress}}
}

function New-Dockerfile{
    <#
    .SYNOPSIS
        New-Dockerfile

    .DESCRIPTION
        Create a new dockerfile

    .PARAMETER Location
        The path where the new dockerfile

    .PARAMETER content
        The content of the new dockerfile

    .EXAMPLE
        New-Dockerfile -Location "D:\docker\pyhost" -content pyhost
    #>
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

function New-PythonHostImage{
    <#
    .SYNOPSIS
        New-PythonHost

    .DESCRIPTION
        Create a new python-container

    .PARAMETER Name
        The name of the new container, hostname and image

    .PARAMETER ContentName
        The content-name of the new dockerfile

    .EXAMPLE
        New-PythonHost -Name pyhost -ContentName $pyhost
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String] $Name, 

        [Parameter(Mandatory=$true)]
        [String] $ContentName
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    if($IsWindows){
        if(Test-Path "D:\docker"){
            New-Dockerfile -Location "D:\docker\$($Name)" -content $ContentName
        }
        if(Test-Path "D:\docker\$($Name)"){
            Set-Location "D:\docker\$($Name)"; docker build -f "D:\docker\$($Name)\dockerfile" -t "$($Name):1.0.0" .
        }
    }else{
        $location = "/Users/Tinu/git/github.com/docker-example/"
        if(Test-Path $location){
            New-Dockerfile -Location "$($location)/$($Name)" -content $ContentName
        }
        if(Test-Path "$($location)/$($Name)"){
            Set-Location "$($location)/$($Name)"; docker build -f "$($location)/$($Name)/dockerfile" -t "$($Name):1.0.0" .
        }
    }
    
}

<#

# Download a MongoDB-Image and create a new MongoDB-Container
New-MongoDBContainer -ContainerName mongodb -ImageName mongo

# Create a new Python3-Image from a dockerfile
New-PythonHostImage -Name pyhost -ContentName $pyhost -Verbose

# New PythonHost-Container1
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --network custom --hostname pyhost1 --name pyhost1 -d pyhost:1.0.0

# New PythonHost-Container2
docker run -e TZ="Europe/Zurich" -it -v fileshare:/shared-volume --network custom --hostname pyhost2 --name pyhost2 -d pyhost:1.0.0

docker ps -s

#>
