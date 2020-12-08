# Creating and Running A Deployment with ChocoCCM

# Login to CCM
$Credential = Get-Credential
Connect-CCMServer -Hostname chocoserver -UseSsl -Credential $credential

# Find CCM Group to use for our deployment
$Group = Get-CCMGroup -Group 'All Clients'

# Create a new deployment
$Deployment = New-CCMDeployment -Name "Keep Packages Up to Date $(Get-Date)"

# Add steps to deployment
$step = @{
    Deployment   = $Deployment.Name
    Name         = 'Choco Upgrade All'
    TargetGroup  = $Group.Name
    Type         = 'Basic'
    ChocoCommand = 'upgrade'
    PackageName  = 'all'
}
New-CCMDeploymentStep @step

$step = @{
    Deployment   = $Deployment.Name
    Name         = 'Clean Temp Folders'
    TargetGroup  = $Group.Name
    Type         = 'Advanced'
    Script       = {
        Get-ChildItem $env:TEMP | Remove-Item -Recurse -Force
    }
}
New-CCMDeploymentStep @step

# Move deployment to Ready
Move-CCMDeploymentToReady -Deployment $Deployment.Name

# Start the deployment
Start-CCMDeployment -Deployment $Deployment.Name
