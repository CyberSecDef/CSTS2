[CmdletBinding()]param()
begin{
	Class Accounts{
	
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
	
		[void] showFindDormant(){
			$webVars = @{}
			$webVars['mainContent'] = gc "$($pwd)\views\accounts\findDormant.tpl"
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
				$global:GUI.renderTpl("default.tpl", $webVars)
			)
			
			$this.getLocalAccounts('localhost') | ft | out-string | write-host
			
		}
	}
}
Process{
	return [Accounts]::new()
}
End{

}