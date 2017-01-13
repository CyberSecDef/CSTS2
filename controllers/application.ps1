[CmdletBinding()]param()
begin{
	Class Application{
	
		[void] registerEvents(){
			$global:csts.findName('btnHome').add_click( { $global:csts.controllers.application.showHome() } ) | out-null
			$global:csts.findName('btnXls').add_click( { $global:csts.controllers.application.exportXls() } ) | out-null
		}
		
		[void] exportXls(){
			write-host 'exportXls'
		}
		
		[void] showHome(){
			$global:csts.libs.GUI.ShowContent("/views/home.xaml") | out-null
		}
	
	}
}
Process{
	return [Application]::new()
}
End{

}