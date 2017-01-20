[CmdletBinding()]param()
begin{
	Class ScapStig{
	
		[void] registerEvents(){
			$global:csts.findName('btnDiacapControls').add_click( { $global:csts.controllers.ScapStig.showDiacap() } ) | out-null
			$global:csts.findName('btnRmfControls').add_click( { $global:csts.controllers.ScapStig.showRMF() } ) | out-null
			$global:csts.findName('rGalSTIG').add_SelectionChanged( { $global:csts.controllers.ScapStig.showSTIG() } ) | out-null
			$global:csts.findName('rGalSCAP').add_SelectionChanged( { $global:csts.controllers.ScapStig.showSCAP() } ) | out-null
		}
		
		[void] showRMF(){
			$global:csts.findName('rGalSCAP').SelectedItem = $null;
			$global:csts.findName('rGalSTIG').SelectedItem = $null;
			$html = $global:csts.libs.Utils::processXslt( "$($global:csts.execPath)\stigs\80053controls.xml","$($global:csts.execPath)\views\xslt\stigs\80053_controls_unclass.xsl",$null)
			$web = new-object "System.Windows.Controls.WebBrowser"
			$web.navigateToString( $html )
			[GUI]::Get().window.FindName('contentContainer').addChild($web)
		}
		
		[void] showDiacap(){
			$global:csts.findName('rGalSCAP').SelectedItem = $null;
			$global:csts.findName('rGalSTIG').SelectedItem = $null;
			$html = $global:csts.libs.Utils::processXslt( "$($global:csts.execPath)\stigs\8500controls.xml","$($global:csts.execPath)\views\xslt\stigs\8500_controls_unclass.xsl",$null)
			$web = new-object "System.Windows.Controls.WebBrowser"
			$web.navigateToString( $html )
			[GUI]::Get().window.FindName('contentContainer').addChild($web)
		}
		
		[void] showSTIG(){
			$global:csts.findName('rGalSCAP').SelectedItem = $null
			$html = $global:csts.libs.Utils::processXslt( "$($global:csts.execPath)\stigs\$($global:csts.findName('rGalSTIG').SelectedItem)","$($global:csts.execPath)\views\xslt\stigs\STIG_unclass.xsl",$null)
			$web = new-object "System.Windows.Controls.WebBrowser"
			$web.navigateToString( $html )
			[GUI]::Get().window.FindName('contentContainer').addChild($web)
		}
		
		[void] showSCAP(){
			$global:csts.findName('rGalSTIG').SelectedItem = $null
			$html = $global:csts.libs.Utils::processXslt( "$($global:csts.execPath)\stigs\$($global:csts.findName('rGalSCAP').SelectedItem)","$($global:csts.execPath)\views\xslt\stigs\STIG_unclass.xsl",$null)
			$web = new-object "System.Windows.Controls.WebBrowser"
			$web.navigateToString( $html )
			[GUI]::Get().window.FindName('contentContainer').addChild($web)
		}
	}
}
Process{
	
}
End{

}