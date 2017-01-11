[CmdletBinding()]param()
begin{
	Class Systems{
	
		[void] registerEvents(){
			$global:csts.window('btnApplyPolicies').add_click( { $global:csts.controllers.systems.showApplyPolicies() } ) | out-null
		}
	
		[void] showApplyPolicies(){
			write-host "test"
		}
	}
}
Process{
	return [Systems]::new()
}
End{

}