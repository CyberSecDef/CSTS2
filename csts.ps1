[CmdletBinding()]param()
begin{
	clear
	$error.clear()
	Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Windows.Controls.Ribbon

	if ([System.IntPtr]::Size -eq 4) { 
		[void][System.Reflection.Assembly]::LoadFrom("$pwd\bin\SQLite\x32\System.Data.SQLite.dll")
	} else { 
		[void][System.Reflection.Assembly]::LoadFrom("$pwd\bin\SQLite\x64\System.Data.SQLite.dll")
	}
			
	#load any libraries
	(gci "$($PSScriptRoot)\lib") | % { . "$($_.FullName)" }
	
	#functions to get around Classes in PS not being able to load Dot Net items
	function Get-XAML( $content ){
		([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $content )));
	}
	
	function Get-Object( $object ){
		return  new-object "$object"
	}
	
	function Get-PlusMinus(){
		return [System.Windows.Forms.TreeViewHitTestLocations]::PlusMinus
	}
	
	function TreeViewItem_Expanded{
		param($s, $e);
		$s | ft | out-string | write-host		
		$s | gm | ft | out-string | write-host
	}

	#define main
	Class CSTS{

		[String] $execPath;
		[xml]$xaml;
		[HashTable]$objects = @{}
		$window
		$timer = (New-Object System.Windows.Forms.Timer);
		$self;
		$db = "csts.dat"
		
		CSTS(){
			$this.execPath = $PSScriptRoot;
			$this.xaml =  ( iex ('@"' + "`n" + ( (gc "$($this.execPath)/views/layouts/csts.xaml" ) -replace "{{{pwd}}}",$this.execPath ) + "`n" + '"@') )
			$this.self = $this
			
			#make the window
			$this.window = Get-XAML( $this.xaml );
			$this.xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $this.window.FindName($_.Name) -Scope Script }
				
			$this.window.FindName('btnHostExpand').add_Click({
				$global:csts.expandHost();
			})
						
			#load AD Tree
			if ((gwmi win32_computersystem).partofdomain -eq $true) {
				$this.builtAdTree()
				
				#load next nodes on select
				$this.window.FindName('treeAD').add_SelectedItemChanged({
					$global:csts.adLoadLevel($this.selectedItem)
				})
				#load next nodes on node expand
				$this.window.FindName('treeAD').items.add_Expanded({
					param($e, $s)
					$global:csts.adLoadLevel($s.originalSource)
				})
			}
		
			#load mine field select boxes in ribbon
			@(10,20,30,40,50) | % {
				$this.window.FindName('rGCatMineLength').Items.Add($_)
				$this.window.FindName('rGCatMines').Items.Add($_)
			}
			
			#load stig select boxes in ribbon
			ls "$($pwd)\views\stigs" -filter "*manual*" | ? { $_.name -notlike '*benchmark*' } | % {
				$this.window.FindName('rGCatSTIG').Items.Add($_)
			}
			
			ls "$($pwd)\views\stigs" -filter "*benchmark*" | % {
				$this.window.FindName('rGCatSCAP').Items.Add($_)
			}
			
			
			#set up heart beat
			$this.timer.Interval = 500
			$this.timer.Enabled = $true
			$this.timer.start() | out-null
			$this.timer.add_Tick( { $global:csts.Poll() } )
		}
		
		[void] adLoadLevel($selNode){
			#get rid of the null node
			$selNode.items.clear()
			$adNode = new-object directoryservices.directoryentry "LDAP://$($selNode.tag)"
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $adNode
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*//OU=*'}
			
			$ous | sort { $_.Path } | % {
				$this.addNode($selNode,$_)
			}
		}
			
		[bool] adNodeHasChildren($node){
			
			$adNode = new-object directoryservices.directoryentry $node.path
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $adNode
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*OU=*'}
			
			if($ous.length -gt 0){
				return $true
			}else{
				return $false
			}
		}
		
		[void] addNode($RootNode, $obj){ 	        
	        $newNode = new-object System.Windows.Controls.TreeViewItem
			
		    $newNode.Tag = $obj.properties['distinguishedname'][0]
		    $newNode.Header = $obj.properties['name'][0]
			
			If ($this.adNodeHasChildren($obj)){
				$newNode.Items.Add('') | Out-Null
			}
			
	        $RootNode.Items.Add($newNode) | Out-Null 
		}
	
		[void] builtAdTree(){
			$currentDomain = ([ADSI]"LDAP://RootDSE").Get("rootDomainNamingContext") -replace 'DC=','' -replace ',','.'
			$rootNode = $this.window.FindName('treeAD').Items[0]
			$rootNode.header = $currentDomain
			
			#add children under root node
			$prefix = "LDAP://"
			$query = "$($prefix)$($currentDomain)"
			$root = new-object directoryservices.directoryentry $query
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $root
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*OU=*'}
            $ous | sort { $_.Path } | % {
				$this.addNode($rootNode,$_)
			}

			$this.window.FindName('treeAD').Items[0].IsExpanded = $true;
		}
					
		#this event will occur every half a second.
		[void] Poll(){
			#run through all the objects poll methods
			$this.objects.keys | %{
				if( ($this.objects[$_] | gm | select -expand Name) -contains 'Poll' ){
					$this.objects[$_].Poll()
				}
			}
			#this class has the pixel data stuff, so load it.
			$this.GetColors();
		}
		
		[void] Display(){
			$global:csts.createEvents() | out-null
			$global:csts.showHome() | out-null			
			$this.window.ShowDialog() | out-null
		}
		
		[void] showHome(){
			$webVars = @{}
			$webVars['mainContent'] = gc "$($pwd)\views\home.tpl"
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString(
				$global:GUI.renderTpl("default.tpl", $webVars)
			)
		}
		
		#this is here to update the CSTS GUI using the PixelData output.  The CSTS class is responsible for all updates to the CSTS Form
		[void] GetColors(){
			if($this.objects['PixelData'] -ne $null){
				$c = $this.objects['PixelData'].Get()			
				$this.window.FindName("Color").Background = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
				$this.window.FindName('lblHtml').Text = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
			}
		}
		
		[void] expandHost(){
			$windowWidth = ($this.window.width)
			if( ($this.window.findName('gridContent').ColumnDefinitions[2].width.value) -lt 200){				
				$this.window.findName('gridContent').ColumnDefinitions[2].width = 200;
				$this.window.findName('btnHostExpand').Content = '>>>'
			}else{
				$this.window.findName('gridContent').ColumnDefinitions[2].width = 25;
				$this.window.findName('btnHostExpand').Content = '<<<'
			}
		}
		
		[void] createEvents(){
			$this.window.findName('btnHome').add_click( { $global:csts.showHome() } ) | out-null
			$this.window.findName('btnFindDormantAccounts').add_click( { $global:csts.objects.Accounts.showFindDormant(); } ) | out-null
			$this.window.findName('btnXls').add_click( { $global:csts.btnXls_Click() } ) | out-null
			$this.window.findName('btnApplyPolicies').add_click( { $global:csts.objects.systems.showApplyPolicies() } ) | out-null
			
			$this.window.findName('btnManageLocalAdmins').add_click( { $global:csts.objects.systems.showManageLocalAdmins() } ) | out-null
			
			$this.window.findName('btnDiacapControls').add_click( {
				$global:csts.window.findName('rGalSCAP').SelectedItem = $null;
				$global:csts.window.findName('rGalSTIG').SelectedItem = $null;
				$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString( ( (gc "$pwd\views\stigs\8500controls.html") -join "`r`n") ) 
			} ) | out-null
			
			$this.window.findName('btnRmfControls').add_click( { 
				$global:csts.window.findName('rGalSCAP').SelectedItem = $null;
				$global:csts.window.findName('rGalSTIG').SelectedItem = $null;
				$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString( ( (gc "$pwd\views\stigs\80053controls.html") -join "`r`n") ) 
			} ) | out-null

			$this.window.findName('rGalSTIG').add_SelectionChanged( { 
				$global:csts.window.findName('rGalSCAP').SelectedItem = $null
				$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString( ( (gc "$pwd\views\stigs\$($global:csts.window.findName('rGalSTIG').SelectedItem)") -join "`r`n") ) 
			} ) | out-null

			$this.window.findName('rGalSCAP').add_SelectionChanged( { 
				$global:csts.window.findName('rGalSTIG').SelectedItem = $null
				$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString( ( (gc "$pwd\views\stigs\$($global:csts.window.findName('rGalSCAP').SelectedItem)") -join "`r`n") ) 
			} ) | out-null
			
			
			
			$this.window.findName('rGalMines').add_SelectionChanged( { write-host $global:csts.window.findName('rGalMines').SelectedItem } ) | out-null
			$this.window.findName('rGalMineLength').add_SelectionChanged( { write-host $global:csts.window.findName('rGalMineLength').SelectedItem } ) | out-null
		}
		
		#the events (ribbon button clicks) are all defined below here for csts only events.  Other controllers are linked in the createEvents function
		[void] btnXls_Click(){
			$global:csts.window.FindName('contentContainer').children[0].content[0].NavigateToString( $global:GUI.renderTpl('default.tpl',@{'title' = "Export to XLS"}) )
		}
		
		[void] Dispose(){
			$this.timer.stop()		
		}
	}
}
process{
	#new CSTS object (global so all sub objects can find it)
	$global:csts = [CSTS]::new()
	
	#load all the controllers/objects
	(gci "$($PSScriptRoot)\controllers") | % { 
		. "$($_.FullName)" | out-null
		$global:csts.objects.add("$($_.BaseName)", (Get-Object("$($_.BaseName)")) ) | out-null
	}
	
	
	#this tests the sql installation
	# $test = [SQL]::Get( $global:csts.db ).query("SELECT name FROM sqlite_master WHERE type='table' AND name='test2'").execAssoc()
	# if($test -eq $null){
		# [SQL]::Get( $global:csts.db ).query("create table test2( id integer primary key, name text not null)").execNonQuery()
		# [SQL]::Get( $global:csts.db ).query("insert into test2(name) values ('test') ").execNonQuery()
	# }else{
		# [SQL]::Get( $global:csts.db ).query("insert into test2(name) values ('test') ").execNonQuery()
	# }
	# [SQL]::Get( $global:csts.db ).query("SELECT * FROM test2").execAssoc().ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize

	
	
	#show the form.  This is a dialog, so after this all actions must be event calls or based off the heart beat.
	$global:csts.Display()
}
end{
	# [SQL]::Get( $global:csts.db ).Close() | out-null
	$global:csts.Dispose();
	[System.GC]::Collect() | out-null
}