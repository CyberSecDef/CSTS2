Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Windows.Controls.Ribbon, WindowsFormsIntegration


if ([System.IntPtr]::Size -eq 4) { 
	[void][System.Reflection.Assembly]::LoadFrom("$($PSScriptRoot)\bin\SQLite\x32\System.Data.SQLite.dll")
} else { 
	[void][System.Reflection.Assembly]::LoadFrom("$($PSScriptRoot)\bin\SQLite\x64\System.Data.SQLite.dll")
}

if( !( test-path "$($PSScriptRoot)\bin\GridViewSort.dll") ){
	Add-Type -Language CSharpVersion3 -TypeDefinition ([System.IO.File]::ReadAllText("$($PSScriptRoot)\types\GridViewSort.cs")) -ErrorAction Stop -OutputAssembly "$($PSScriptRoot)\bin\GridViewSort.dll" -outputType Library -ReferencedAssemblies @("WindowsBase","PresentationFramework","System", "PresentationCore", "System.Xaml")
}
if (!("Wpf.Util.GridViewSort" -as [type])) {
	Add-Type -path "$($PSScriptRoot)\bin\GridViewSort.dll"
}

if(!(test-path "$($PSScriptRoot)\bin\pixelData.dll")){
	Add-Type -Language CSharpVersion3 -TypeDefinition ([System.IO.File]::ReadAllText("$($PSScriptRoot)\types\pixelData.cs")) -ReferencedAssemblies @("System.Drawing","WindowsBase","System.Windows.Forms") -ErrorAction Stop -OutputAssembly "$($PSScriptRoot)\bin\pixelData.dll" -outputType Library
}
if (!("cyberToolSuite.pixelDataObj" -as [type])) {
	Add-Type -path "$($PSScriptRoot)\bin\pixelData.dll"
}

#functions to get around Classes in PS not being able to load Dot Net items
function Get-XAML( $content ){ ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $content ))); }
function Get-Object( $object ){ return  new-object "$object" }
function Get-PlusMinus(){ return [System.Windows.Forms.TreeViewHitTestLocations]::PlusMinus }

#enums are defined here
. "$($PSScriptRoot)\types\enums.ps1"