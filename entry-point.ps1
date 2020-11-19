C:\Solr\bin\solr.cmd start

if ($env:PRECREATE -eq "true" -and $env:PRECREATE_ARG -ne "")
{
    if (Test-Path C:\SolrCreateCoreFinished.txt)
    {
        Write-Output "core already created."
    }
    else {
        Write-Output "create core use arg: -c $env:PRECREATE_CORE_NAME -d $env:PRECREATE_CONFDIR_NAME"
        C:\Solr\bin\solr.cmd create_core -c $env:PRECREATE_CORE_NAME -d $env:PRECREATE_CONFDIR_NAME
        "create core use arg: '-c $env:PRECREATE_CORE_NAME -d $env:PRECREATE_CONFDIR_NAME' finished." > C:\SolrCreateCoreFinished.txt      
    }

}

while (!(Test-Path C:\Solr\server\logs\solr.log)) {
    Write-Output "solr log not exist, sleep 5 seconds."
    Start-Sleep -Seconds 5
}

if (Test-Path C:\Solr\server\logs\solr.log) {
    Get-Content C:\Solr\server\logs\solr.log -Wait
}