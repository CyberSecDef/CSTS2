[CmdletBinding()]param()
begin{
	Class Application{
		$data = $null;
		
		[void] registerEvents(){
			$global:csts.findName('btnHome').add_click( { $global:csts.controllers.application.showHome() } ) | out-null
			
		}
		
		[void] showHome(){
			[GUI]::Get().ShowContent("/views/home.xaml") | out-null
		}
		
	}
}
Process{
	return [Application]::new()
}
End{

}