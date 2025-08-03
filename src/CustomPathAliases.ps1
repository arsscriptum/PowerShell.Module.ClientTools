#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   CustomPathAliases.ps1                                                        ║
#║   Generated PowerShell Script with function to move in custom path             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝
New-Alias documents -Value "Push-MyDocuments" -Description "Push-location $env:MyDocuments" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias dejatools -Value "Push-DejaToolsRootDirectory" -Description "Push-location $env:DejaToolsRootDirectory" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias dev -Value "Push-DevelopmentRoot" -Description "Push-location $env:DevelopmentRoot" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias scripts -Value "Push-ScriptsRoot" -Description "Push-location $env:ScriptsRoot" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias tools -Value "Push-ToolsRoot" -Description "Push-location $env:ToolsRoot" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias www -Value "Push-wwwroot" -Description "Push-location $env:wwwroot" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias www2 -Value "Push-wwwroot2" -Description "Push-location $env:wwwroot2" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias site -Value "Push-siteroot" -Description "Push-location $env:siteroot" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias redditsupport -Value "Push-RedditSupport" -Description "Push-location $env:RedditSupport" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias moddev -Value "Push-moddev" -Description "Push-location $env:moddev" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias code -Value "Push-MyCode" -Description "Push-location $env:MyCode" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias profilepath -Value "Push-ProfilePath" -Description "Push-location $env:ProfilePath" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias sb -Value "Push-Sandbox" -Description "Push-location $env:Sandbox" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias pssb -Value "Push-PowerShellSandbox" -Description "Push-location $env:PowerShellSandbox" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias scriptssb -Value "Push-ScriptsSandbox" -Description "Push-location $env:ScriptsSandbox" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias codesb -Value "Push-CodeSandbox" -Description "Push-location $env:CodeSandbox" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias winsb -Value "Push-WinSandbox" -Description "Push-location $env:WinSandbox" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias codetpl -Value "Push-CodeTemplates" -Description "Push-location $env:CodeTemplates" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
New-Alias tpl -Value "Push-Templates" -Description "Push-location $env:Templates" -Scope Global -Force -ErrorAction Stop -Option ReadOnly, AllScope
