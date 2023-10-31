# InstallOpenTelemetry_IIS
Repository contianing the PowerShell script to install OpenTelemetry onto a Windows machine with IIS.

This is a quickstart for the installation of the OpenTelemetry-Instrumentation scriipts.   I've attempted to utilize the scripts from OpenTelemetry many times, and have had failure after failure when using with IIS.

This PowerShell script will populate at a Machine level what is needed to instrument your DotNet applications and have telemetry streaming through the OTEL exporter to the given endpoint.


There are 2 functions that this script implements.   

Install

The format of the command is InstallOpenTelemetry.ps1 {installpath} -CollectorURL {collector url} -Platform {Platform} -ServiceNamespace {namespace}


The Plarform and ServiceNamespace options will configure the ENV variable OTEL_RESOURCE_ATTRIBUTES.
The CollectorURL should be in the form of "http://host.com"
The install path should be in drive format; it will also import the $env:OTEL_DOTNET_AUTO_HOME



