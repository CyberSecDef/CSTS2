[CmdletBinding()]param()
begin{
	Class PackageManager{
		$dataContext = [psCustomObject]@{}
		$viewPage = ''
		
		PackageManager(){
			if($global:csts.vms.ViewModel_PackageManager -eq $null){
				$global:csts.vms.Add('ViewModel_PackageManager', ( [ViewModel_PackageManager]::new()) )
			}
			$global:csts.vms.ViewModel_PackageManager.Initialize()
			
			$this.dataContext | add-member -memberType NoteProperty -name 'cboPkgs' -value @()
			$this.dataContext | add-member -memberType NoteProperty -name 'packageSummaries' -value @()
			$this.dataContext | add-member -memberType NoteProperty -name 'pkgSelItem' -value @()
			$this.dataContext | add-member -memberType NoteProperty -name 'pkgHardware' -value @()
			$this.dataContext | add-member -memberType NoteProperty -name 'assetSelItem' -value @()
			$this.dataContext | add-member -memberType NoteProperty -name 'pkgSoftware' -value @()

		}
		
		[void] Poll(){
		
		}
		
		[void] registerEvents(){
			[GUI]::Get().window.findName('btnPackageManager').add_click( { $global:csts.controllers.PackageManager.showPkgMgrDashBoard() } ) | out-null	
		}
	
		[void]updateDataContext(){
			$i = 0
			$this.dataContext.cboPkgs = @();
			$this.dataContext.packageSummaries = @();
			
			$global:csts.vms.ViewModel_PackageManager.getPackageInfo() | % {
				$i++
				$this.dataContext.cboPkgs += [psCustomObject]@{ 
					Id = $($_.id);
					Name = $($_.name);
					Acronym = $($_.acronym);
				}
				
				$this.dataContext.packageSummaries += [psCustomObject]@{ 
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
			$this.updateDataContext()
			
			[GUI]::Get().ShowContent("/views/scans/packageManager/Dashboard.xaml", $this.dataContext) | out-null
			$this.showMenu();

			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( { if($this.selectedItem.id -ne $null){ $global:csts.controllers.PackageManager.dataContext.pkgSelItem = $($this.selectedItem.Id) } } ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.PackageManager.showPkgMgrDashBoard(); } );
			[GUI]::Get().window.findName('UC').findName('btnAddNewPackage').add_Click( { $global:csts.controllers.PackageManager.showAddNewPackage(); } ) | out-null
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.dataContext.pkgSelItem )
			([GUI]::Get().window.findName('UC').findName('pkgAvailable').findName('pkgContext').Items | ? { $_.header -eq 'Delete' } ).add_Click({ $global:csts.vms.ViewModel_PackageManager.deletePkg( [GUI]::Get().window.findName('UC').findName('pkgAvailable').selectedItem.Tag ) }) 
			([GUI]::Get().window.findName('UC').findName('pkgAvailable').findName('pkgContext').Items | ? { $_.header -eq 'Show Hardware' } ).add_Click({ $global:csts.controllers.PackageManager.showHardware() })

			([GUI]::Get().window.findName('UC').findName('pkgAvailable').findName('pkgContext').Items | ? { $_.header -eq 'Show Software' } ).add_Click({ $global:csts.controllers.PackageManager.showSoftware() })


			
			[GUI]::Get().window.findName('UC').findName('pkgAvailable').add_SelectionChanged( { if($_.addedItems.Tag -ne $null){ [GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'), $_.addedItems.Tag ) } } ); 		
		}
		
		[void] showSoftware(){
			$this.viewPage = 'showSoftware'
			$this.dataContext.pkgSoftware = @();
			
			$global:csts.vms.ViewModel_PackageManager.getPackageSoftware( $this.dataContext.pkgSelItem ) | % {
				$this.dataContext.pkgSoftware += [psCustomObject]@{ 
					Id = $_.id;
					Name = $_.name;
					Version = $_.version;
					Vendor = $_.Vendor;
					Hosts = ( [Model_XAssetsApplications]::Get().Hosts( ($global:csts.controllers.PackageManager.dataContext.pkgSelItem), $_.id ) | % { $_.hostname } ) -join ','
				}
			}
			
			$this.updateDataContext()
			[GUI]::Get().ShowContent("/views/scans/packageManager/Software.xaml", $this.dataContext) | out-null
			$this.showMenu();
		}
			
			
			
		[void] showHardware(){
			$this.viewPage = 'showHardware'
			$this.dataContext.pkgHardware = @();
			
			$global:csts.vms.ViewModel_PackageManager.getPackageHardware( $this.dataContext.pkgSelItem ) | % {
				$this.dataContext.pkgHardware += [psCustomObject]@{ 
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
			
			$this.updateDataContext()
			[GUI]::Get().ShowContent("/views/scans/packageManager/Hardware.xaml", $this.dataContext) | out-null
			$this.showMenu();
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Reload Metadata' } ).add_Click({ $global:csts.vms.ViewModel_PackageManager.reloadMetadata( ( [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItems ) ) })
			
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Remove' } ).add_Click({
				$global:csts.vms.ViewModel_PackageManager.removeHost( $global:csts.controllers.PackageManager.dataContext.pkgSelItem, [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItem.Id)
				$global:csts.controllers.PackageManager.showHardware()
			})
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Reload Software' } ).add_Click({
				$global:csts.vms.ViewModel_PackageManager.getHostSoftware( $global:csts.controllers.PackageManager.dataContext.pkgSelItem, [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItem.Id)
			})
			
			
			([GUI]::Get().window.findName('UC').findName('pkgHwList').findName('pkgHardwareContext').Items | ? { $_.header -eq 'Edit' } ).add_Click({
				$selAsset = $global:csts.vms.ViewModel_PackageManager.getHostInfo( $global:csts.controllers.PackageManager.dataContext.pkgSelItem, [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItem.Id)	
				$desc = ""
				if( [Utils]::IsBlank( $selAsset.Description ) -eq $false){
					$desc = "$( [System.Text.Encoding]::Ascii.GetString( $selAsset.Description ) )"
				}

				$fields = @( 
					[pscustomobject]@{Type = "Textbox";Label = "Hostname";Text = $selAsset.hostname; Name = "Hostname";}
					[pscustomobject]@{Type = "Textbox";Label = "IP Address";Text = $selAsset.IP; Name = "IP";}
					[pscustomobject]@{Type = "ComboBox";Label = "Device Type"; Name = "deviceType"; Values = @( [Model_DeviceTypes]::Get().table() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.deviceTypeId}
					[pscustomobject]@{Type = "ComboBox";Label = "Manufacturer"; Name = "Manufacturer"; Values = @( [Model_Vendors]::Get().table() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.vendorId}
					[pscustomobject]@{Type = "Textbox";Label = "Model";Text = $selAsset.Model; Name = "Model";},
					[pscustomobject]@{Type = "Textbox";Label = "Firmware";Text = $selAsset.Firmware; Name = "Firmware";}
					[pscustomobject]@{Type = "Textbox";Label = "Location";Text = $selAsset.Location; Name = "Location";}
					[pscustomobject]@{Type = "Textbox";Label = "Description";Text = $desc ; Name = "Description";}
					[pscustomobject]@{Type = "ComboBox";Label = "Operating System"; Name = "OS"; Values = @( [Model_OperatingSystems]::Get().table() | ? { [UTILS]::IsBlank($_.name) -eq $false} | %{ [psCustomObject]@{Text=$_.Name;Value = $_.id} } ) ; Selected = $selAsset.operatingSystemId; "ReadOnly" = $true}
					[pscustomobject]@{Type = "Textbox";Label = "OS Key";Text = $selAsset.osKey; Name = "osKey";}
					[pscustomobject]@{Type = "Actions"; Execute = { $global:csts.controllers.PackageManager.updateAsset() } }
				)
				
				[GUI]::Get().showModal( $fields, "Edit Asset" )
			})
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( { if($this.selectedItem.id -ne $null){ $global:csts.controllers.PackageManager.dataContext.pkgSelItem = $($this.selectedItem.Id)	 } } ) | out-null 			
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.PackageManager.showPkgMgrDashBoard(); } );
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.dataContext.pkgSelItem )
			[GUI]::Get().window.findName('UC').findName('btnImportFromAd').add_Click( { $global:csts.vms.ViewModel_PackageManager.importHosts() } )
			[GUI]::Get().window.findName('UC').findName('btnRemoveHosts').add_Click( { $global:csts.vms.ViewModel_PackageManager.removeHosts( ([GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItems) ) } )
			[GUI]::Get().window.findName('UC').findName('btnReloadMetadata').add_Click( { $global:csts.vms.ViewModel_PackageManager.reloadMetadata( ( [GUI]::Get().window.findName('UC').findName('pkgHwList').selectedItems ) ) } )
		}
		
		[void] updateAsset(){
			$children = [GUI]::Get().findChildren( [GUI]::Get().window.findName('modalPanel') )			
			$children = $children | ? { [Utils]::IsBlank( $_.name) -eq $false } | select Name, Text, @{Name='Tag';Expression={ $_.SelectedValue.Tag }}  
			$global:csts.vms.ViewModel_PackageManager.updateAssetData($children)
			$global:csts.controllers.PackageManager.showHardware()
			[GUI]::Get().hideModal()
		}
		
		[void] showAddNewPackage(){
			$this.updateDataContext()
			[GUI]::Get().ShowContent("/views/scans/packageManager/AddPackage.xaml", $this.dataContext) | out-null
			$this.showMenu();
			
			[GUI]::Get().window.findName('UC').findName('cboPkgs').add_SelectionChanged( { if($this.selectedItem.id -ne $null){ $global:csts.controllers.PackageManager.dataContext.pkgSelItem = $($this.selectedItem.Id) } } ) | out-null
			[GUI]::Get().window.findName('UC').findName('pkgMgrHome').add_MouseDown( { $global:csts.controllers.PackageManager.showPkgMgrDashBoard(); } ) | out-null;
			[GUI]::Get().window.findName('UC').findName('txtPkgName').add_TextChanged( { $this.text = $_.OriginalSource.text } ) | out-null;
			[GUI]::Get().window.findName('UC').findName('txtPkgAcronym').add_TextChanged( { $this.text = $_.OriginalSource.text } ) | out-null;
			[GUI]::Get().window.findName('UC').findName('btnAddPackage').add_Click( { $global:csts.vms.ViewModel_PackageManager.addPackage( ([GUI]::Get().window.findName('UC').findName('txtPkgName').Text), ( [GUI]::Get().window.findName('UC').findName('txtPkgAcronym').Text ) ); $global:csts.controllers.PackageManager.showPkgMgrDashBoard(); } ) | out-null
			[GUI]::Get().cboSelectItem( [GUI]::Get().window.findName('UC').findName('cboPkgs'),$this.dataContext.pkgSelItem ) | out-null;
		}
		
		[void] showMenu(){
			$uc = [GUI]::Get().parseXaml("$($global:csts.execPath)/views/scans/packageManager/submenu.xaml")
			[GUI]::Get().window.FindName('contentContainer').findName('UC').findName('pkgTopMenu').children.clear()
			[GUI]::Get().window.FindName('contentContainer').findName('UC').findName('pkgTopMenu').addChild($uc)
			$uc.findName('mnuHardware').add_Click({ $global:csts.controllers.PackageManager.showHardware() })
			$uc.findName('mnuSoftware').add_Click({ $global:csts.controllers.PackageManager.showSoftware() })			
		}	
	}
}
Process{
	
}
End{

}