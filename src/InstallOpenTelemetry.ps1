##  Install OpenTelemetry DotNet 


#Requires -RunAsAdministrator


Param(
    [string]$InstallDir = $env:OTEL_DOTNET_AUTO_HOME,
    [string]$Platform = "windows",
    [string]$ServiceNamespace = "Default",
    [string]$CollectorURL = "http://localhost",
    [switch]$Unregister
 )

[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls';
$otelPort = "4318"  #  Currently DotNet AUTO-Insturmentaion only supports HTTP
$ResourceAttributes =  "platform=$($Platform),service.name=$($ServiceNamespace),host.name=$($env:COMPUTERNAME),service.name=$($ServiceNamespace)"
$otelEndpoint = "$($CollectorURL):$($otelPort)"

function Set-EnvironmentVariables([string] $key, [string] $value) {
          [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Machine)
}


if($InstallDir -eq "") {
    Write-Output "You are missing the install directory!"
    Exit 1
}

Write-Output "Downloading and importing the Install Module..."
# Download the module
$module_url = "https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/download/v1.11.0/OpenTelemetry.DotNet.Auto.psm1"
$download_path = Join-Path $env:temp "OpenTelemetry.DotNet.Auto.psm1"

if (-not(Test-Path -Path $download_path -PathType Leaf)) {
    Invoke-WebRequest -Uri $module_url -OutFile $download_path -UseBasicParsing
    #Write-Output "Downloading the OpenTelemetry framework..."
}
if ((Test-Path -Path $download_path -PathType Leaf)) {
    Write-Output "Importing OTEL module..."
    # Import the module to use its functions
    Import-Module $download_path
}else{
    Write-Output "Failed to download and import the OTEL module. "
    Exit 1
}

if ($Unregister -eq $true){
    Write-Output "Stopping IIS"
    net stop was /y
    Write-Output "Unregistering all ENV variables...."
    Set-EnvironmentVariables "OTEL_SERVICE_NAME" $null
    Set-EnvironmentVariables "COR_ENABLE_PROFILING" $null
    Set-EnvironmentVariables "COR_PROFILER" $null
    Set-EnvironmentVariables "CORECLR_PROFILER" $null
    Set-EnvironmentVariables "CORECLR_ENABLE_PROFILING" $null
    Set-EnvironmentVariables "COR_PROFILER_PATH_64" $null
    Set-EnvironmentVariables "COR_PROFILER_PATH_32" $null
    Set-EnvironmentVariables "CORECLR_PROFILER_PATH_64" $null
    Set-EnvironmentVariables "CORECLR_PROFILER_PATH_32" $null
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_INTEGRATIONS_FILE" $null
    Set-EnvironmentVariables "ASPNETCORE_HOSTINGSTARTUPASSEMBLIES" $null
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_TRACES_ENABLED_INSTRUMENTATIONS" $null
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_METRICS_INSTRUMENTATION_ENABLED" $null
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_HOME" $null
    Set-EnvironmentVariables "OTEL_RESOURCE_ATTRIBUTES" $null
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_INSTRUMENTATION_ENABLED" $null
    Set-EnvironmentVariables "OTEL_EXPORTER_OTLP_PROTOCOL" $null
    Uninstall-OpenTelemetryCore
    Write-Output "Done...."
    Exit 0
}

if($Unregister -eq $false){
    Write-Output "Installing the OpenTelemetry framework to $($InstallDir)..."

    Install-OpenTelemetryCore -InstallDir $InstallDir

    $32Bit = Join-Path $InstallDir "\win-x64\OpenTelemetry.AutoInstrumentation.Native.dll"
    $64Bit = Join-Path $InstallDir "\win-x86\OpenTelemetry.AutoInstrumentation.Native.dll"
    $integrationsFile = Join-Path $InstallDir "integrations.json"

    Write-Output "Setting Environment Values"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_INSTRUMENTATION_ENABLED" "1"
    Set-EnvironmentVariables "COR_ENABLE_PROFILING" "1"
    Set-EnvironmentVariables "COR_PROFILER" "{918728DD-259F-4A6A-AC2B-B85E1B658318}"
    Set-EnvironmentVariables "CORECLR_PROFILER" "{918728DD-259F-4A6A-AC2B-B85E1B658318}"
    Set-EnvironmentVariables "CORECLR_ENABLE_PROFILING" "1"
    Set-EnvironmentVariables "COR_PROFILER_PATH_64" $64Bit
    Set-EnvironmentVariables "COR_PROFILER_PATH_32" $32Bit
    Set-EnvironmentVariables "CORECLR_PROFILER_PATH_64" $64Bit
    Set-EnvironmentVariables "CORECLR_PROFILER_PATH_32" $32Bit
    Set-EnvironmentVariables "OTEL_EXPORTER_OTLP_PROTOCOL" "http/protobuf"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_INTEGRATIONS_FILE" $integrationsFile
    Set-EnvironmentVariables "ASPNETCORE_HOSTINGSTARTUPASSEMBLIES" "OpenTelemetry.AutoInstrumentation.AspNetCoreBootstrapper"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_TRACES_INSTRUMENTATION_ENABLED" "1"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_METRICS_INSTRUMENTATION_ENABLED" "1"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_TRACES_ENABLED_INSTRUMENTATIONS" "AspNet,HttpClient,SqlClient"
    Set-EnvironmentVariables "OTEL_DOTNET_AUTO_HOME" $InstallDir
    Set-EnvironmentVariables "OTEL_RESOURCE_ATTRIBUTES" $ResourceAttributes
    Set-EnvironmentVariables "OTEL_EXPORTER_OTLP_ENDPOINT" $otelEndpoint  
    Register-OpenTelemetryForIIS
}
Write-Output "Installation complete..."
Exit 0 

