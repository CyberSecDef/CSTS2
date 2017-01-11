[CmdletBinding()]param()
begin{
	Class Accounts{
		
		[void] registerEvents(){
			$global:csts.libs.gui.window.findName('btnFindDormantAccounts').add_click( { $global:csts.controllers.Accounts.showFindDormant(); } ) | out-null
			$global:csts.libs.gui.window.findName('btnManageLocalAdmins').add_click( { $global:csts.controllers.accounts.showManageLocalAdmins() } ) | out-null
		}
		
		
		[Object[]] getLocalAccounts($computerName){
			$dormantUsers = @()
			$localUsers = ([ADSI]"WinNT://$computerName").Children | ? {$_.SchemaClassName -eq 'user'} | ? { $_.properties.lastlogin -lt ( ( ([System.DateTime]::Now).ToUniversalTime() ).AddDays(-1 * $private.Age) ) } | select `
				@{e={$_.name};n='DisplayName'},`
				@{e={$_.name};n='Username'},`
				@{e={$_.properties.lastlogin};n='LastLogon'},`
				@{e={if($_.properties.userFlags.ToString() -band 2){$true}else{$false} };n='Disabled'},`
				@{e={$_.path};n='Path'}, `
				@{e={'Local'};n='AccountType'}
				
			foreach($localUser in $localUsers){				
				$u = new-object -TypeName PSObject | Select AccountType, DisplayName, Username, LastLogon, Disabled, Path
				foreach($key in (($localUser | gm  -memberType 'NoteProperty' | select -expand Name ) ) ){
					 $u.$($key) = $localUser.$($key)
				}
							
				$dormantUsers += $u 
			}
			
			return $dormantUsers
		}
	
		[void] showManageLocalAdmins(){
			
		}
			
		[void] showFindDormant(){
			write-host 'this is a new test'
		}
		
		[void] testAdminStuff(){
			write-host 'this is a new test'
		}	
		
		
	}
}
Process{
	return [Accounts]::new()
}
End{

}