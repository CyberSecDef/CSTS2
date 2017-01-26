[CmdletBinding()]param()
begin{
	Class Scans{
	
		[void] Poll(){
			
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnScanToPoam').add_click( { $global:csts.controllers.Scans.showScansToPoamUI(); } ) | out-null
		}
		
		[void] showScansToPoamUI(){
			[GUI]::Get().ShowContent("/views/scans/scansToPoam.xaml") | out-null
			if($global:csts.objs.scansToPoam -eq $null){
				$global:csts.objs.Add('scansToPoam', ( [ScansToPoam]::new()) )
			}
			
			[GUI]::Get().window.findName('UC').findName('btnExecuteScansToPoam').add_click( {
				$global:csts.objs.scansToPoam.InvokeScansToPoam()
				$global:csts.controllers.scans.updateScansToPoamUI() 
			} ) | out-null
			
			
			[GUI]::Get().window.findName('UC').findName('btnScansToPoamBrowse').add_click( {
				$folder = ( new-object -com Shell.Application ).BrowseForFolder(0, "Select Location of Scans:", 0x0001C2D1, 0)
				if ($folder.Self.Path -ne "") {
					[GUI]::Get().window.findName('UC').findName('txtScanLocation').Text = $folder.self.path
				}
			} ) | out-null
			
			[GUI]::Get().window.findName('UC').findName('txtScanLocation').add_TextChanged( {
				$this.text = $_.OriginalSource.text
			} )
			
			$global:csts.objs.scansToPoam.Initialize()
		}
		
		[void] updateScansToPoamUI(){
			if( [GUI]::Get().window.findName('UC').findName('dgScansToPoam') -ne $null){
				[GUI]::Get().window.findName('UC').findName('dgScansToPoam').Items.Clear()
				$global:csts.objs.scansToPoam.data | ? { $_.rawRisk -ne 'IV' } | sort { $_.raw, $_.control} | % {
					[GUI]::Get().window.findName('UC').findName('dgScansToPoam').Items.add($_)
				}
				[GUI]::Get().window.findName('UC').findName('dgScansToPoam').Items.Refresh()
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
			}
		}
	
	}
}
Process{
	
}
End{

}