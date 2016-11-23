[CmdletBinding()]param()
begin{
	Class Systems{
	
		[void] showApplyPolicies(){
			$webVars = @{}
			$webVars['mainContent'] = gc "$($global:csts.execPath)\views\systems\applyPolicies.tpl"
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