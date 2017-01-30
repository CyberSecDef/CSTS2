[CmdletBinding()]param()
begin{
	Class Packages{
		
		[void] Poll(){
		
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnPackageManager').add_click( { $global:csts.controllers.Packages.showPackageManagerUI() } ) | out-null	
		}
	
		[void] showPackageManagerUI(){
			if($global:csts.objs.PackageManager -eq $null){
				$global:csts.objs.Add('PackageManager', ( [PackageManager]::new()) )
			}
			$global:csts.objs.PackageManager.Initialize()
		}
		
		
		
		
	}
}
Process{
	
}
End{

}