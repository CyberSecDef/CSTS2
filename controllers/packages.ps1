[CmdletBinding()]param()
begin{
	Class Packages{
		$selPkg = ""
		
		[void] Poll(){
		
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnPackageManager').add_click( { $global:csts.controllers.Packages.showPkgMgrDashBoard() } ) | out-null	
		}
	
		[void] showPkgMgrDashBoard(){
			
			if($global:csts.objs.PackageManager -eq $null){
				$global:csts.objs.Add('PackageManager', ( [PackageManager]::new()) )
			}
			$global:csts.objs.PackageManager.Initialize()
			
			$viewModel = [psCustomObject]@{}
			$viewModel | add-member -memberType NoteProperty -name 'packageSummaries' -value @()
			$viewModel | add-member -memberType NoteProperty -name 'cboPkgs' -value @()
			$viewModel | add-member -memberType NoteProperty -name 'pkgSelItem' -value @{}
			
			
			$i = 0
			$global:csts.objs.PackageManager.getPackageDashboard() | % {
				$i++
				$viewModel.cboPkgs += [psCustomObject]@{ 
					Id = $($_.id);
					Name = $($_.name);
					Acronym = $($_.acronym);
				}
				
				$viewModel.packageSummaries += [psCustomObject]@{ 
					Number        = $i; 
					Acronym       = $($_.Acronym); 
					Hardware      = $($_.Hardware); 
					Software      = $($_.Software); 
					ACAS          = "ACAS $($_.ACAS)"; 
					CKL           = "CKL $($_.CKL)"; 
					SCAP          = "SCAP $($_.SCAP)"; 
					Open          = "O: $($_.Open)"; 
					NotReviewed   = "NR: $($_.NotReviewed)"; 
					Completed     = "C: $($_.Completed)"; 
					NotApplicable = "NA: $($_.NotApplicable)"; }
			}
			
			[GUI]::Get().ShowContent("/views/scans/pkgMgrDashBoard.xaml", $viewModel) | out-null
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				
			} ) | out-null
			
			[GUI]::Get().window.findName('UC').findName('btnAddNewPackage').add_Click( {
				# [GUI]::Get().window.findName('UC').findName('cboPkgs').selectedIndex = 2

				$global:csts.controllers.Packages.showAddNewPackage();
				
			} ) | out-null
			
		}
		
		[void] showAddNewPackage(){
			[GUI]::Get().ShowContent("/views/scans/pkgMgrAddPkg.xaml") | out-null
		}
		
		
		
	}
}
Process{
	
}
End{

}