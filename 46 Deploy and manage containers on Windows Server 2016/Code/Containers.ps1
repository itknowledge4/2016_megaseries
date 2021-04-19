#Install the Docker provide module
Install-Module DockerMsftProvider -Force
#Install the Docker package
Install-Package Docker -ProviderName DockerMsftProvider -Force
#Restart the container host
Restart-Computer
#Start the Docker service
Start-Service docker
#Test that docker works
docker version
docker info
#Install Hyper-V (if you need Hyper-V Containers)
Install-WindowsFeature Hyper-V
#Restart the container host
Restart-Computer

#Get a docker image and list images
docker pull mcr.microsoft.com/nanoserver
docker images
#Run containers
docker run -ti mcr.microsoft.com/nanoserver cmd.exe
docker run mcr.microsoft.com/nanoserver ping localhost -t
#Run docker commands
docker ps
docker top <id>
docker ps -a
docker rm <id>
docker stop <id>
#Run a Hyper-V Container
docker run -ti --isolation=hyperv mcr.microsoft.com/nanoserver cmd.exe