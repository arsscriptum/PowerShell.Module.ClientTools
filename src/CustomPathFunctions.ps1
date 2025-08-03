#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   CustomPathFunctions.ps1                                                      ║
#║   Generated PowerShell Script with function to move in custom path             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝
function Push-MyDocuments { Write-Host "Pushd => $env:MyDocuments"; Push-location $env:MyDocuments; }
function Push-DejaToolsRootDirectory { Write-Host "Pushd => $env:DejaToolsRootDirectory"; Push-location $env:DejaToolsRootDirectory; }
function Push-DevelopmentRoot { Write-Host "Pushd => $env:DevelopmentRoot"; Push-location $env:DevelopmentRoot; }
function Push-ScriptsRoot { Write-Host "Pushd => $env:ScriptsRoot"; Push-location $env:ScriptsRoot; }
function Push-ToolsRoot { Write-Host "Pushd => $env:ToolsRoot"; Push-location $env:ToolsRoot; }
function Push-wwwroot { Write-Host "Pushd => $env:wwwroot"; Push-location $env:wwwroot; }
function Push-wwwroot2 { Write-Host "Pushd => $env:wwwroot2"; Push-location $env:wwwroot2; }
function Push-siteroot { Write-Host "Pushd => $env:siteroot"; Push-location $env:siteroot; }
function Push-RedditSupport { Write-Host "Pushd => $env:RedditSupport"; Push-location $env:RedditSupport; }
function Push-moddev { Write-Host "Pushd => $env:moddev"; Push-location $env:moddev; }
function Push-MyCode { Write-Host "Pushd => $env:MyCode"; Push-location $env:MyCode; }
function Push-ProfilePath { Write-Host "Pushd => $env:ProfilePath"; Push-location $env:ProfilePath; }
function Push-Sandbox { Write-Host "Pushd => $env:Sandbox"; Push-location $env:Sandbox; }
function Push-PowerShellSandbox { Write-Host "Pushd => $env:PowerShellSandbox"; Push-location $env:PowerShellSandbox; }
function Push-ScriptsSandbox { Write-Host "Pushd => $env:ScriptsSandbox"; Push-location $env:ScriptsSandbox; }
function Push-CodeSandbox { Write-Host "Pushd => $env:CodeSandbox"; Push-location $env:CodeSandbox; }
function Push-WinSandbox { Write-Host "Pushd => $env:WinSandbox"; Push-location $env:WinSandbox; }
function Push-CodeTemplates { Write-Host "Pushd => $env:CodeTemplates"; Push-location $env:CodeTemplates; }
function Push-Templates { Write-Host "Pushd => $env:Templates"; Push-location $env:Templates; }
