[CmdletBinding()]param()
begin{
	Class Packages{
		$viewModel = [psCustomObject]@{}
		$viewPage = ''
		
		Packages(){
			if($global:csts.objs.PackageManager -eq $null){
				$global:csts.objs.Add('PackageManager', ( [PackageManager]::new()) )
			}
			$global:csts.objs.PackageManager.Initialize()
			
			$this.viewModel | add-member -memberType NoteProperty -name 'cboPkgs' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'packageSummaries' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'pkgSelItem' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'pkgHardware' -value @()
			$this.viewModel | add-member -memberType NoteProperty -name 'assetSelItem' -value @()
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
					Tag			  = $($_.id);
					Number        = $i; 
					Acronym       = $($_.Acronym); 
					Hardware      = $($_.Hardware); 
					Software      = $($_.Software); 
					ACAS          = $($_.ACAS); 
					CKL           = $($_.CKL); 
					SCAP          = $($_.SCAP); 
					Open          = $($_.Open); 
					NotReviewed   = $($_.NotReviewed); 
					Completed     = $($_.Completed); 
					NotApplicable = $($_.NotApplicable); 
				}
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
			
			([GUI]::Get().window.findName('UC').findName('pkgAvailable').findName('pkgContext').Items | ? { $_.header -eq 'Delete' } ).add_Click({
				$global:csts.objs.PackageManager.pkgDelete(
					[GUI]::Get().window.findName('UC').findName('pkgAvailable').selectedItem.Tag
				)
			})
			
			([GUI]::Get().window.findName('UC').findName('pkgAvailable').findName('pkgContext').Items | ? { $_.header -eq 'Show Hardware' } ).add_Click({
				$global:csts.controllers.Packages.showHardware()
			})
			
			[GUI]::Get().window.findName('UC').findName('pkgAvailable').add_SelectionChanged( {
				if($_.addedItems.Tag -ne $null){
					[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'), $_.addedItems.Tag )
				}
			} );
		
		}
		
		[void] showHardware(){
			$this.viewPage = 'showHardware'
			$this.viewModel.pkgHardware = @();
			
			if(![Utils]::IsBlank($this.viewModel.pkgSelItem)){			
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
					where
						a.id in (select assetId from xPackagesAssets where packageId = @PackageId)
					order by 
						trim(lower(a.hostname))
"@
				$params = @{
					"@PackageId" = $this.viewModel.pkgSelItem
				}
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execAssoc() | %{

					$this.viewModel.pkgHardware += [psCustomObject]@{ 
						Id = $_.id;
						Hostname = "$($_.hostname)".ToUpper();
						IP = $_.ip;
						deviceType = $_.deviceType;
						OS = $_.operatingSystem;
						Vendor = $_.vendor;
						Model = $_.model;
						Firmware = $_.firmware;
						Location = $_.location;
						Description = ( [System.Text.Encoding]::Ascii.GetString($_.description) );
					}
				}
			}
			
			
			$this.updateViewModel()
			[GUI]::Get().ShowContent("/views/scans/packageManager/Hardware.xaml", $this.viewModel) | out-null
			$this.addMenu();
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Reload Metadata' } ).add_Click({ $global:csts.objs.PackageManager.reloadMetadata() })
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Remove' } ).add_Click({
				$query = "Delete from assets where id = @id"
				$params = @{ "@id" = [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItem.Id}
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery()

				$global:csts.controllers.Packages.showHardware()
				[GUI]::Get().hideModal()
			})
			
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Edit' } ).add_Click({
				$query = @"
Select 
	a.id, 
	a.model, 
	a.firmware, 
	a.hostname, 
	a.ip, 
	a.description, 
	a.osKey, 
	a.location, 
	a.operatingSystemId, 
	a.deviceTypeId,
	a.vendorId,
	(select name from operatingSystems where id = a.operatingSystemId) as operatingSystem,
	(select name from deviceTypes where id = a.deviceTypeId) as deviceType,
	(select name from vendors where id = a.vendorId) as Vendor
from 
	assets a
where 
	a.id = @id
"@
				$params = @{
					"@id" = [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItem.Id
				}
				$selAsset = ( [SQL]::Get( 'packages.dat' ).query( $query, $params ).execSingle() )
				
				$desc = ""
				if( [Utils]::IsBlank( $selAsset.Description ) -eq $false){
					$desc = "$( [System.Text.Encoding]::Ascii.GetString( $selAsset.Description ) )"
				}
				
				$fields = @( 
					[pscustomobject]@{Type = "Textbox";Label = "Hostname";Text = $selAsset.hostname; Name = "Hostname";}
					[pscustomobject]@{Type = "Textbox";Label = "IP Address";Text = $selAsset.IP; Name = "IP";}
					
					[pscustomobject]@{Type = "ComboBox";Label = "Device Type"; Name = "deviceType"; Values = @( [SQL]::Get('packages.dat').query("SELECT id, Name from deviceTypes order by Name").execAssoc() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.deviceTypeId}
					
					[pscustomobject]@{Type = "ComboBox";Label = "Manufacturer"; Name = "Manufacturer"; Values = @( [SQL]::Get('packages.dat').query("SELECT id, Name from Vendors order by Name").execAssoc() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.vendorId}
					
					[pscustomobject]@{Type = "Textbox";Label = "Model";Text = $selAsset.Model; Name = "Model";},
					[pscustomobject]@{Type = "Textbox";Label = "Firmware";Text = $selAsset.Firmware; Name = "Firmware";}
					[pscustomobject]@{Type = "Textbox";Label = "Location";Text = $selAsset.Location; Name = "Location";}
					
					
					[pscustomobject]@{Type = "Textbox";Label = "Description";Text = $desc ; Name = "Description";}
					
					[pscustomobject]@{Type = "ComboBox";Label = "Operating System"; Name = "OS"; Values = @( [SQL]::Get('packages.dat').query("SELECT id, Name from operatingSystems order by Name").execAssoc() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.operatingSystemId; "ReadOnly" = $true}
					[pscustomobject]@{Type = "Textbox";Label = "OS Key";Text = $selAsset.osKey; Name = "osKey";}
					
					[pscustomobject]@{Type = "Actions"; Execute = { $global:csts.controllers.Packages.updateAssetData() } }
					
				)
				
				[GUI]::Get().showModal( $fields, "Edit Asset" )
			})
			
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( {
				if($this.selectedItem.id -ne $null){
					$global:csts.controllers.Packages.viewModel.pkgSelItem = $($this.selectedItem.Id)	
				}
			} ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.Packages.showPkgMgrDashBoard(); } );
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.viewModel.pkgSelItem )
			
			[GUI]::Get().window.findName('UC').findName('btnImportFromAd').add_Click( { $global:csts.objs.PackageManager.importHosts() } )
			[GUI]::Get().window.findName('UC').findName('btnRemoveHosts').add_Click( { $global:csts.objs.PackageManager.removeHosts() } )
			[GUI]::Get().window.findName('UC').findName('btnReloadMetadata').add_Click( { $global:csts.objs.PackageManager.reloadMetadata() } )
			
		}
		
		[void] updateAssetData(){
			
			$children = [GUI]::Get().findChildren( [GUI]::Get().window.findName('modalPanel') )			
			$children = $children | ? { [Utils]::IsBlank( $_.name) -eq $false } | select Name, Text, @{Name='Tag';Expression={ $_.SelectedValue.Tag }}  

			#if deviceTypeTag is blank...that means a new one was added....add it to the db
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'deviceType').Tag) -eq $true){
				$query = "insert into deviceTypes (name) values (@name);"
				$params = @{ "@name" = [Utils]::ObjHash($children,'deviceType').Text }
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery() 
				
				$query = "select id from deviceTypes where name = @name"
				$params = @{ "@name" = [Utils]::ObjHash($children,'deviceType').Text}
				[Utils]::ObjHash($children,'deviceType').Tag = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
			}
			
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'Manufacturer').Tag) -eq $true){
				$query = "insert into vendors (name) values (@name);"
				$params = @{ "@name" = [Utils]::ObjHash($children,'Manufacturer').Text }
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery() 
				
				$query = "select id from vendors where name = @name"
				$params = @{ "@name" = [Utils]::ObjHash($children,'Manufacturer').Text}
				[Utils]::ObjHash($children,'Manufacturer').Tag = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
			}
			
			$query = @"
update assets
	set 
		model = @model,
		firmware = @firmware,
		hostname = @hostname,
		ip = @ip,
		description = @description,
		osKey = @osKey,
		location = @location,
		operatingSystemId = @operatingSystemId,
		deviceTypeId = @deviceTypeId,
		vendorId = @vendorId
	where
		id = @assetId
"@
			$params = @{
				"@model" = ([Utils]::ObjHash($children,'Model').Text);
				"@firmware" = ([Utils]::ObjHash($children,'Firmware').Text);
				"@hostname" = ([Utils]::ObjHash($children,'Hostname').Text);
				"ip" = ([Utils]::ObjHash($children,'IP').Text);
				"@description" = ([Utils]::ObjHash($children,'Description').Text);
				"@osKey" = ([Utils]::ObjHash($children,'osKey').Text);
				"@location" = ([Utils]::ObjHash($children,'Location').Text);
				"@operatingSystemId" = ([Utils]::ObjHash($children,'OS').Tag);
				"@deviceTypeId" = ([Utils]::ObjHash($children,'deviceType').Tag);
				"@vendorId" = ([Utils]::ObjHash($children,'Manufacturer').Tag);
				"@assetId" = $this.viewModel.assetSelItem.Id;
			}
			
			if([Utils]::IsBlank($this.viewModel.assetSelItem.Id) -ne $true){
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery()
			}
			
			$global:csts.controllers.Packages.showHardware()
			[GUI]::Get().hideModal()
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