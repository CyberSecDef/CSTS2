[CmdletBinding()]
param (	$action = "gendoc" )   

clear; 

switch($action){
	"gendoc" {.\bin\NatDocs\NaturalDocs.exe -p "$($pwd)\docs\conf" -o html "$($pwd)\docs"  -i "$($pwd)" -r }
}
