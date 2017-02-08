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
			$this.viewModel | add-member -memberType NoteProperty -name 'pkgHardware' -value @()
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
			$this.viewModel.pkgHardware = @();
			$this.viewModel.pkgHardware += [psCustomObject]@{ 
				Id = 1;
				Hostname = 'Test'.ToUpper();
				IP = '127.0.0.1';
				deviceType = 'Server';
				OS = 'RHEL 5';
				Vendor = 'Dell';
				Model = 'Test-123';
				Firmware = '1A';
				Location = '';
				Description = 'Test System with a really long description that should wrap';
			}
			
			
			$this.viewModel.pkgHardware += [psCustomObject]@{ 
				Id = 2;
				Hostname = 'AnotherHost'.ToUpper();
				IP = '127.0.0.1';
				deviceType = 'Work Station';
				OS = 'Windows 10';
				Vendor = 'HP';
				Model = 'NMCI-123';
				Firmware = '2A';
				Location = '';
				Description = 'Another Test System';
			}
			
			
			$query = @"
				select 
					a.id, 
					a.model, 
					a.firmware, 
					a.hostname, 
					a.ip, 
					a.description, 
					a.osKey, 
					a.location, 
					(select name from operatingSystems where id = a.operatingSystemId) as operatingSystem,
					(select name from deviceTypes where id = a.deviceTypeId) as deviceType,
					(select name from vendors where id = a.vendorId) as Vendor
				from 
					assets a
"@
			$assets = [SQL]::Get( 'packages.dat' ).query( $query ).execAssoc()
			
			$assets | %{
				$this.viewModel.pkgHardware += [psCustomObject]@{ 
					Id = $_.id;
					Hostname = $_.hostname.ToUpper();
					IP = $_.ip;
					deviceType = $_.deviceType;
					OS = $_.operatingSystem;
					Vendor = $_.vendor;
					Model = $_.model;
					Firmware = $_.firmware;
					Location = $_.location;
					Description = "$($_.description)";
				}
			}
			
			
			$this.updateViewModel()
			[GUI]::Get().ShowContent("/views/scans/packageManager/Hardware.xaml", $this.viewModel) | out-null
			$this.addMenu();
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				if($this.selectedItem.id -ne $null){
					$global:csts.controllers.Packages.viewModel.pkgSelItem = $($this.selectedItem.Id)
				}
			} ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.Packages.showPkgMgrDashBoard(); } );
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.viewModel.pkgSelItem )
			
			[GUI]::Get().window.findName('UC').findName('btnImportFromAd').add_Click( { $global:csts.objs.PackageManager.importHosts() } )
			
			
			
		}
		
		[void] showAddNewPackage(){
			$this.updateViewModel()
			[GUI]::Get().ShowContent("/views/scans/packageManager/AddPackage.xaml", $this.viewModel) | out-null
			$this.addMenu();
			
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
			$uc.findName('mnuHardware').add_Click({ $global:csts.controllers.Packages.showHardware() })
			
			
			
			
		}
		
	}
}
Process{
	
}
End{

}