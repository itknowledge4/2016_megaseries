#Get a list of all features and roles
Get-WindowsFeature
#Get a list of all removed roles and features
Get-windowsFeature | Where-Object {$_.InstallState -eq 'Removed'}
#Permanently remove a role/feature
Remove-WindowsFeature WINS -Remove

#To recover a feature or role we have to specify a path to where the binary is
#This can be directly a Windows Install image or a folder (or Windows Update)
#To use directly the image: Install-WindowsFeature <name> -Source wim:path:index

#Get a list of indexes from an image
Get-WindowsImage -ImagePath D:\sources\install.wim
#Install the feature/role again
Install-WindowsFeature WINS -Source wim:D:\sources\install.wim:2

#If you want to use a folder where you have the SxS copied just run the command as follows
# Install-WindowsFeature Wireless-Networking -Source \\server\sharedfolder
#                                            -Source C:\features

#For .NET 3.5 you will either need the installation DVD or a folder with the files (or Windows Update)
#The binary for .NET 3.5 is not directly in the install.wim but on the install DVD
Install-WindowsFeature NET-Framework-Core -Source D:\sources\sxs