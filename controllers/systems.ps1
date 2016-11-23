[CmdletBinding()]param()
begin{
	Class Systems{
	
		[void] showManageLocalAdmins(){
			$webVars = @{}
			
			$webVars['users'] = "";
			$userIndex = 0;
			#specified hosts
			foreach($currentHostName in ($global:csts.window.FindName('txtHosts').text -split ',')){
				if($currentHostName -ne $null -and $currentHostName -ne ''){
					( gwmi  -Class Win32_Group  -Filter "LocalAccount='$true'"  -ComputerName $currentHostName  | ? { $_.Name -like 'Admin*' -or $_.Name -like 'Priv*' } ) | % {
						$_.GetRelated("Win32_Account","Win32_GroupUser","","", "PartComponent","GroupComponent",$FALSE,$NULL) | ? {
							($_.Domain -eq $currentHostname -and $currentHostname.indexOf(".") -eq -1)  -or ($currentHostName.indexOf(".") -gt 0 -and $_.Domain -eq $currentHostName.substring(0, $currentHostName.indexOf(".") ) )
						} | %{
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
			
			

			
			$webVars['mainContent'] = gc "$($pwd)\views\systems\manageLocalAdmins.tpl"
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
				$global:GUI.renderTpl("default.tpl", $webVars)
			)
		}
		
	
		[void] showApplyPolicies(){
			$webVars = @{}
			$webVars['mainContent'] = gc "$($pwd)\views\systems\applyPolicies.tpl"
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
				$global:GUI.renderTpl("default.tpl", $webVars)
			)
		}
	}
}
Process{
	return [Systems]::new()
}
End{

}