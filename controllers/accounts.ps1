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
	
		[void] showManageLocalAdmins(){
				$webVars = @{}
				
				$webVars['users'] = "";
				$userIndex = 0;
				#specified hosts
				foreach($currentHostName in ( $global:Hosts.Get().keys ) ){
					write-host $currentHostName
					$pingResult = Get-WmiObject -Class win32_pingstatus -Filter "address='$($currentHostName)'"
					if( $pingResult ){
						write-host 'ping'
						if($currentHostName -ne $null -and $currentHostName -ne ''   ){
							write-host 'notnull'
							( gwmi  -Class Win32_Group  -Filter "LocalAccount='$true'"  -ComputerName $currentHostName  | ? { $_.Name -like 'Admin*' -or $_.Name -like 'Priv*' } ) | % {
								$_.GetRelated("Win32_Account","Win32_GroupUser","","", "PartComponent","GroupComponent",$FALSE,$NULL) | ? {
									($_.Domain -eq $currentHostname -and $currentHostname.indexOf(".") -eq -1)  -or ($currentHostName.indexOf(".") -gt 0 -and $_.Domain -eq $currentHostName.substring(0, $currentHostName.indexOf(".") ) )
								} | %{
									write-host 'in here'
									$userIndex++
									$webVars['users'] += @"
	<tr>
		<td>$($userIndex)</td>
		<td>
			<button class="btn btn-default">Manage</button>
		</td>
		<td>$($_.domain)</td>
		<td>$($_.PSComputerName)</td>
		<td>$($_.name)</td>
		<td>$($_.FullName)</td>
		<td><span class="label label-primary">$($_.status)</span></td>
		<td><span class="label label-primary">$($_.disabled)</span></td>
		<td><span class="label label-primary">$($_.lockout)</span></td>
		<td><span class="label label-primary">$($_.passwordExpires)</span></td>
		<td><span class="label label-primary">$($_.passwordChangeable)</span></td>
		<td><span class="label label-primary">$($_.passwordRequired)</span></td>
	</tr>
"@
								}
							}
						}
					}
				}
				
				$webVars['mainContent'] = gc "$($global:csts.execPath)\views\systems\manageLocalAdmins.tpl"
				$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
					$global:GUI.renderTpl("default.tpl", $webVars)
				)
			}
			
			
		[void] showFindDormant(){
			$webVars = @{}
			$webVars['mainContent'] = gc "$($global:csts.execPath)\views\accounts\findDormant.tpl"
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
				$global:GUI.renderTpl("default.tpl", $webVars)
			)
			
			# $this.getLocalAccounts('localhost') | ft | out-string | write-host
			# $global:Hosts.Get() | ft | out-string | write-host
		}
	}
}
Process{
	return [Accounts]::new()
}
End{

}