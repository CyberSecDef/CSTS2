[CmdletBinding()]param()
begin{
	Class Accounts{
		
		[void] Poll(){
			if($global:csts.objs.FindDormant -ne $null){
				$global:csts.objs.FindDormant.pollEvents()
				if($global:csts.objs.FindDormant.IsChanged -eq $true){
					$global:csts.controllers.accounts.updateFindDormantUI()
				}
			}
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnFindDormantAccounts').add_click( { $global:csts.controllers.Accounts.showFindDormantUI(); } ) | out-null
			[GUI]::Get().window.findName('btnManageLocalAdmins').add_click( { $global:csts.controllers.accounts.showManageLocalAdmins() } ) | out-null
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
			
		[void] showFindDormantUI(){
			[GUI]::Get().ShowContent("/views/accounts/findDormant.xaml") | out-null
			if($global:csts.objs.FindDormant -eq $null){
				$global:csts.objs.Add('FindDormant', ( [FindDormant]::new()) )
			}
			
			
			[GUI]::Get().window.findName('UC').findName('txtNumOfDays').add_TextChanged( {
				$this.text = $_.OriginalSource.text
			} )
			
			[GUI]::Get().window.findName('UC').findName('btnExecFindDormant').add_click( {
				$global:csts.objs.FindDormant.InvokeFindDormant()
				$global:csts.controllers.accounts.updateFindDormantUI() 
			} ) | out-null
			
			
			$global:csts.objs.FindDormant.Initialize()
			# $global:csts.objs.FindDormant.__('test',@{test=1;})
		}
		
		[void] updateFindDormantUI(){
			if( [GUI]::Get().window.findName('UC').findName('dgFindDormantHosts') -ne $null){
				[GUI]::Get().window.findName('UC').findName('dgFindDormantHosts').Items.Clear()
				$global:csts.objs.FindDormant.data | sort { $_.hostname} | % {
					[GUI]::Get().window.findName('UC').findName('dgFindDormantHosts').Items.add($_)
				}
				[GUI]::Get().window.findName('UC').findName('dgFindDormantHosts').Items.Refresh()
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
			}
		}
		
	}
}
Process{
	return [Accounts]::new()
}
End{

}