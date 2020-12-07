# 12 Days Of Chocolatey Examples

## Day 5 - 7 December 2020

Day 5 covered building packages! We went over creating packages manually using `choco new packagename`, Package Builder, building large packages, and touched on Package Internalizer.

This repository contains all of the sample code that you saw during the demos presented on this day.

## Quick Tips

### Create a Chocolatey package from all installers in the same folder

```powershell
Get-ChildItem . -Recurse -Include *.msi,*.exe |
    ForEach-Object {
        choco new $($_.BaseName) --file $_.FullName --build-package --output-directory C:\packages
    }
```

### Push all newly-created packages up to repository (replace `chocoserver` with your repo)

```powershell
Get-ChildItem . -Recurse -Include *.nupkg |
    ForEach-Object {
        choco push $_.FullName -s https://chocoserver:8443/repository/ChocolateyInternal/
    }
```
