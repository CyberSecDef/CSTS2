[CmdletBinding()]param()
begin{
	Class Packages{
		$viewModel = [psCustomObject]@{}
		
		Packages(){
			if($global:csts.objs.PackageManager -eq $null){
				$global:csts.objs.Add('PackageManager', ( [PackageManager]::new()) )
			}
			$global:csts.objs.PackageManager.Initialize()
			
			$this.viewModel | add-member -memberType NoteProperty -name 'cboPkgs' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'packageSummaries' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'pkgSelItem' -value @()
		}
		
		[void] Poll(){
		
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnPackageManager').add_click( { $global:csts.controllers.Packages.showPkgMgrDashBoard() } ) | out-null	
		}
	
		[void]updateViewModel(){
			$i = 0
			$this.viewModel.cboPkgs = @();
			$this.viewModel.packageSummaries = @();
			
			$global:csts.objs.PackageManager.getPackageInfo() | % {
				$i++
				$this.viewModel.cboPkgs += [psCustomObject]@{ 
					Id = $($_.id);
					Name = $($_.name);
					Acronym = $($_.acronym);
				}
				
				$this.viewModel.packageSummaries += [psCustomObject]@{ 
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
		}
		
		[void] showPkgMgrDashBoard(){
			$this.updateViewModel()
			
			[GUI]::Get().ShowContent("/views/scans/packageManager/Dashboard.xaml", $this.viewModel) | out-null
			$this.addMenu();
			$this.updateViewModel()

			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				if($this.selectedItem.id -ne $null){
					 $global:csts.controllers.Packages.viewModel.pkgSelItem = $($this.selectedItem.Id)
				}
			} ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.Packages.showPkgMgrDashBoard(); } );
			[GUI]::Get().window.findName('UC').findName('btnAddNewPackage').add_Click( { $global:csts.controllers.Packages.showAddNewPackage(); } ) | out-null
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.viewModel.pkgSelItem )
		}
		
		[void] showHardware(){
			[GUI]::Get().ShowContent("/views/scans/packageManager/Hardware.xaml", $this.viewModel) | out-null
			$this.addMenu();
			$this.updateViewModel()
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				if($this.selectedItem.id -ne $null){
					$global:csts.controllers.Packages.viewModel.pkgSelItem = $($this.selectedItem.Id)
				}
			} ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.Packages.showPkgMgrDashBoard(); } );
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.viewModel.pkgSelItem )
		}
		
		[void] showAddNewPackage(){
			[GUI]::Get().ShowContent("/views/scans/packageManager/AddPackage.xaml", $this.viewModel) | out-null
			$this.addMenu();
			$this.updateViewModel()
			$v = $this.viewModel
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				if($this.selectedItem.id -ne $null){
					 $global:csts.controllers.Packages.viewModel.pkgSelItem = $($this.selectedItem.Id)
				}
			} ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.Packages.showPkgMgrDashBoard(); } );
			
			[GUI]::Get().window.findName('UC').findName('txtPkgName').add_TextChanged( {
				$this.text = $_.OriginalSource.text
			} )
			
			[GUI]::Get().window.findName('UC').findName('txtPkgAcronym').add_TextChanged( {
				$this.text = $_.OriginalSource.text
			} )
			
			[GUI]::Get().window.findName('UC').findName('btnAddPackage').add_Click( {
				$global:csts.objs.PackageManager.addPackage() 
				$global:csts.controllers.Packages.showPkgMgrDashBoard();
			} ) | out-null
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.viewModel.pkgSelItem )
		}
		
		[void] addMenu(){
			$uc = [GUI]::Get().parseXaml("$($global:csts.execPath)/views/scans/packageManager/submenu.xaml")
			[GUI]::Get().window.FindName('contentContainer').findName('UC').findName('pkgTopMenu').children.clear()
			[GUI]::Get().window.FindName('contentContainer').findName('UC').findName('pkgTopMenu').addChild($uc)
			$uc.findName('mnuHardware').add_Click({ $global:csts.controllers.Packages.showPkgMgrDashBoard() })
			
			
			
			
		}
		
	}
}
Process{
	
}
End{

}