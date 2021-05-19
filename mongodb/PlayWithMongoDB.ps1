Import-Module -Name Mdbc
$DatabaseName   = 'JupyterNB'
$CollectionName = 'FailedPatching'
$mongo_client   = Connect-Mdbc mongodb://localhost
$mongo_db       = Get-MdbcDatabase -Name $DatabaseName
$mongo_col      = Get-MdbcCollection -Database $mongo_db -Name $CollectionName

Get-MdbcData -Collection (Get-MdbcCollection -Database $mongo_db -Name 'PoweredOffVMs') -As PS  | Format-Table
Get-MdbcData -Collection (Get-MdbcCollection -Database $mongo_db -Name 'FailedPatching') -As PS | Format-Table

$stage_lookup = @{
    '$lookup' = @{
        from         = 'PoweredOffVMs'
        localField   = 'PSComputerName'
        foreignField = 'PSComputerName'
        as           = 'temp_collection'
    }
}

$stage_unwind = @{
    '$unwind' = '$temp_collection'
}

$stage_project = @{
    '$project' = @{
        _id                  = 1
        PSComputerName       = 1
        PowerState           = '$temp_collection.PowerState'
        LastPatchRun         = 1
        LastPatchStatus      = 1
        UpdateServerStatus   = 1
        CcmExecVersion       = 1
        CCMCimInstanceStatus = 1
    } 
}

$pipeline = @(
    $stage_lookup,
    $stage_project
)
Invoke-MdbcAggregate -Collection $mongo_col -Pipeline $pipeline -As PS | Format-Table