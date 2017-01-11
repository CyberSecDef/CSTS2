[CmdletBinding()]param()
begin{
	clear
	$error.clear()
	Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Windows.Controls.Ribbon
	if ([System.IntPtr]::Size -eq 4) { 
		[void][System.Reflection.Assembly]::LoadFrom("$($PSScriptRoot)\bin\SQLite\x32\System.Data.SQLite.dll")
	} else { 
		[void][System.Reflection.Assembly]::LoadFrom("$($PSScriptRoot)\bin\SQLite\x64\System.Data.SQLite.dll")
	}
	
	#functions to get around Classes in PS not being able to load Dot Net items
	function Get-XAML( $content ){ ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $content ))); }
	function Get-Object( $object ){ return  new-object "$object" }
	function Get-PlusMinus(){ return [System.Windows.Forms.TreeViewHitTestLocations]::PlusMinus }

	#define main class
	Class CSTS{
		[String] $execPath;
		[HashTable]$controllers = @{};
		[HashTable]$libs = @{};
		$timer = (New-Object System.Windows.Forms.Timer);
		$self;
		$db = "csts.dat"
		
		CSTS(){
			$this.execPath = $PSScriptRoot;
			$this.self = $this
		}
		
		[object] window($name){
			return ( $global:csts.libs.gui.window.findName($name) )
		}
		
		[void] init(){
			if ((gwmi win32_computersystem).partofdomain -eq $true) {
				$global:csts.libs.ad.builtAdTree()
				
				# load next nodes on select
				$global:csts.libs.gui.window.FindName('treeAD').add_SelectedItemChanged({
					$global:csts.libs.ad.adLoadLevel($this.selectedItem)
				})
				# load next nodes on node expand
				$global:csts.libs.gui.window.FindName('treeAD').items.add_Expanded({
					param($e, $s)
					$global:csts.libs.ad.adLoadLevel($s.originalSource)
				})
			}
	
			#load mine field select boxes in ribbon
			@(10,20,30,40,50) | % {
				$global:csts.libs.gui.window.FindName('rGCatMineLength').Items.Add($_)
				$global:csts.libs.gui.window.FindName('rGCatMines').Items.Add($_)
			}
			
			#load stig select boxes in ribbon
			ls "$($global:csts.execPath)\stigs\" -filter "*manual*" | ? { $_.name -notlike '*benchmark*' } | % {
				$global:csts.libs.gui.window.FindName('rGCatSTIG').Items.Add($_)
			}
			
			ls "$($global:csts.execPath)\stigs" -filter "*benchmark*" | % {
				$global:csts.libs.gui.window.FindName('rGCatSCAP').Items.Add($_)
			}
			
			#set up heart beat
			$this.timer.Interval = 1000
			$this.timer.Enabled = $true
			$this.timer.start() | out-null
			$this.timer.add_Tick( { $global:csts.Poll() } )
			
			$this.libs.gui.window.findName('btnHome').add_click( { $global:csts.showHome() } ) | out-null
			$this.libs.gui.window.findName('btnXls').add_click( { $global:csts.btnXls_Click() } ) | out-null
			
			$this.libs.gui.window.findName('btnDiacapControls').add_click( {
				$global:csts.libs.gui.window.findName('rGalSCAP').SelectedItem = $null;
				$global:csts.libs.gui.window.findName('rGalSTIG').SelectedItem = $null;
				$html = $global:Utils::processXslt( "$($global:csts.execPath)\stigs\8500controls.xml","$($global:csts.execPath)\views\xslt\stigs\8500_controls_unclass.xsl",$null)
				$global:csts.libs.gui.window.FindName('contentContainer').children[0].content[0].NavigateToString( $html )
			} ) | out-null
			
			$this.libs.gui.window.findName('btnRmfControls').add_click( { 
				$global:csts.libs.gui.window.findName('rGalSCAP').SelectedItem = $null;
				$global:csts.libs.gui.window.findName('rGalSTIG').SelectedItem = $null;
				
				$html = $global:Utils::processXslt( "$($global:csts.execPath)\stigs\80053controls.xml","$($global:csts.execPath)\views\xslt\stigs\80053_controls_unclass.xsl",$null)
				$global:csts.libs.gui.window.FindName('contentContainer').children[0].content[0].NavigateToString( $html )
				
			} ) | out-null

			$this.libs.gui.window.findName('rGalSTIG').add_SelectionChanged( { 
				$global:csts.libs.gui.window.findName('rGalSCAP').SelectedItem = $null
				
				$html = $global:Utils::processXslt( "$($global:csts.execPath)\stigs\$($global:csts.libs.gui.window.findName('rGalSTIG').SelectedItem)","$($global:csts.execPath)\views\xslt\stigs\STIG_unclass.xsl",$null)
				$global:csts.libs.gui.window.FindName('contentContainer').children[0].content[0].NavigateToString( $html )
			} ) | out-null

			$this.libs.gui.window.findName('rGalSCAP').add_SelectionChanged( { 
				$global:csts.libs.gui.window.findName('rGalSTIG').SelectedItem = $null
				$html = $global:Utils::processXslt( "$($global:csts.execPath)\stigs\$($global:csts.libs.gui.window.findName('rGalSCAP').SelectedItem)","$($global:csts.execPath)\views\xslt\stigs\STIG_unclass.xsl",$null)
				$global:csts.libs.gui.window.FindName('contentContainer').children[0].content[0].NavigateToString( $html )
			} ) | out-null
			
			$this.libs.gui.window.findName('rGalMines').add_SelectionChanged( { write-host $global:csts.libs.gui.window.findName('rGalMines').SelectedItem } ) | out-null
			$this.libs.gui.window.findName('rGalMineLength').add_SelectionChanged( { write-host $global:csts.libs.gui.window.findName('rGalMineLength').SelectedItem } ) | out-null
		}
					
		#this event will occur every second.
		[void] Poll(){
			#run through all the controllers poll methods
			$this.controllers.keys | %{
				if( ($this.controllers[$_] | gm | select -expand Name) -contains 'Poll' ){
					$this.controllers[$_].Poll()
				}
			}
			#this class has the pixel data stuff, so load it.
			$this.libs.gui.GetColors();
		}
		
		[void] Display(){
			$global:csts.libs.GUI.ShowContent("/views/home.xaml") | out-null
			$global:csts.libs.GUI.ShowDialog() | out-null
		}
		
		[void] Dispose(){
			$this.timer.stop()		
		}
	}
}
process{
	#create new CSTS object (global so all sub controllers can find it)
	$global:csts = [CSTS]::new()
	
	#load any libraries
	(gci "$($PSScriptRoot)\lib") | % { . "$($_.FullName)" }
	
	#load all the controllers/objects
	(gci "$($global:csts.execPath)\controllers") | % { 
		. "$($_.FullName)" | out-null
		$global:csts.controllers.add("$($_.BaseName)", (Get-Object("$($_.BaseName)")) ) | out-null
		$global:csts.controllers[$($_.BaseName)].registerEvents() | out-null
	}
	
	$global:csts.init() | out-null
	
	#this tests the sql installation
	# $test = [SQL]::Get( $global:csts.db ).query("SELECT name FROM sqlite_master WHERE type='table' AND name='test2'").execAssoc()
	# if($test -eq $null){
		# [SQL]::Get( $global:csts.db ).query("create table test2( id integer primary key, name text not null)").execNonQuery()
		# [SQL]::Get( $global:csts.db ).query("insert into test2(name) values ('test') ").execNonQuery()
	# }else{
		# [SQL]::Get( $global:csts.db ).query("insert into test2(name) values ('test') ").execNonQuery()
	# }
	[SQL]::Get( $global:csts.db ).query("SELECT * FROM test2").execAssoc().ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize

	#show the form.  This is a dialog, so after this all actions must be event calls or based off the heart beat.
	$global:csts.Display()
}
end{
	[SQL]::Get( $global:csts.db ).Close() | out-null
	$global:csts.Dispose();
	[System.GC]::Collect() | out-null
}