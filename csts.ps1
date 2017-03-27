[CmdletBinding()]param(
	[switch]$safe
)

begin{
	clear
	$error.clear()
	#this initializes everything that can't be done via the new Powershell Classes
	. "$($PSScriptRoot)\init.ps1"
	
	#define main class
	Class CSTS{
		[String] $execPath;
		[HashTable]$controllers = @{};
		[HashTable]$vms = @{};
		[HashTable]$libs = @{};
		$timer = (New-Object System.Windows.Forms.Timer);
		$self;
		$db = "csts.dat";
		$role = (@('User','Admin')[ ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ]);
		$ad = ""
		$activeModule = $null;
		$isActive = $true;
		$safe = (Get-Variable -Name 'safe' -ErrorAction SilentlyContinue).value;
				
		CSTS(){
			$this.execPath = $PSScriptRoot;
			$this.self = $this
		}
		
		[object] findName($name){
			return ( iex '[GUI]::Get().window.findName($name)' )
		}
		
		[void] exportXls(){
			if($global:csts.activeModule -ne $null -and ( $global:csts.activeModule | gm | ? { $_.name -eq 'ExportData' }) -ne $null ){
				$global:csts.activeModule.ExportData( "XLSX" )
			}
			
		}
		
		[void] init(){
			iex '[GUI]::Get().window.findName("btnXls").add_click( { $global:csts.exportXls() } ) | out-null'
		
			if ((gwmi win32_computersystem).partofdomain -eq $true) {
				$global:csts.vms.add('AD', (Get-Object('ActiveDirectory')))
				$global:csts.vms.AD.buildAdTree()
				
				# should this be a deselected Item?
				$global:csts.findName('treeAD').add_MouseUp({
					
					if($this.selectedItem -eq $global:csts.ad){
					
						$item = ($global:csts.findName('treeAD').selectedItem)
						$item.IsSelected = $false
						
					}
					
					$global:csts.ad = $global:csts.findName('treeAD').selectedItem
				})
				
				# load next nodes on select
				$global:csts.findName('treeAD').add_SelectedItemChanged({
					if($this.selectedItem){
						$global:csts.vms.AD.loadLevel($this.selectedItem)
					}
				})
				
				# load next nodes on node expand
				$global:csts.findName('treeAD').items.add_Expanded({
					param($e, $s)
					$global:csts.vms.AD.loadLevel($s.originalSource)
				})
			}
	
			#load mine field select boxes in ribbon
			@(10,20,30,40,50) | % {
				$global:csts.findName('rGCatMineLength').Items.Add($_)
				$global:csts.findName('rGCatMines').Items.Add($_)
			}
			
			#load stig select boxes in ribbon
			ls "$($global:csts.execPath)\stigs\" -filter "*manual*" | ? { $_.name -notlike '*benchmark*' } | % {
				$global:csts.findName('rGCatSTIG').Items.Add($_)
			}
			
			ls "$($global:csts.execPath)\stigs" -filter "*benchmark*" | % {
				$global:csts.findName('rGCatSCAP').Items.Add($_)
			}
			
			ls "$($global:csts.execPath)\views\themes\" | % {
				$global:csts.findName('rGalCatTheme').Items.Add( $_ )
			}
			
			#set up heart beat
			$global:csts.timer.Interval = 1000
			$global:csts.timer.Enabled = $true
			$global:csts.timer.start() | out-null
			$global:csts.timer.add_Tick( { $global:csts.Poll() } )
			
			iex "[GUI]::Get().changeTheme('dark.xaml')"
		}
		
		#this heartbeat event will occur every second.
		[void] Poll(){
			
			#only poll if the tool suite has focus
			$active = (iex "[GUI]::Get().window.isActive")
			if($active){
			
				#dont poll if the a textbox has keyboard focus
				$focused = $false
				if(  (iex "[System.Windows.Input.Keyboard]::FocusedElement") -ne $null ){
					$focused = ( (iex "(([System.Windows.Input.Keyboard]::FocusedElement).GetType()).Name ") -eq "TextBox")
				}
				
				if(! ([bool]$focused) ){
					#run through all the controllers poll methods
					$global:csts.controllers.keys | %{
						if( ($global:csts.controllers[$_] | gm | select -expand Name) -contains 'Poll' ){
							$global:csts.controllers[$_].Poll()
						}	
					}
				}
			}
		
			iex "[GUI]::Get().GetColors();"
		}
		
		[void] Dispose(){
			$global:csts.timer.stop()		
		}
	}
}
process{
	#create new CSTS object (global so all sub controllers can find it)
	$global:csts = [CSTS]::new()
	
	
	# load any libraries
	(gci "$($global:csts.execPath)\lib") | % { . "$($_.FullName)" }
	
	# load any model definitions
	(gci "$($global:csts.execPath)\models") | % { . "$($_.FullName)" }
	
	# load any object definitions
	(gci "$($global:csts.execPath)\viewModels") | % { . "$($_.FullName)" }
	
	# load all the controllers
	(gci "$($global:csts.execPath)\controllers") | % { 
		. "$($_.FullName)" | out-null
		$global:csts.controllers.add("$($_.BaseName)", (Get-Object("$($_.BaseName)")) ) | out-null
		$global:csts.controllers[$($_.BaseName)].registerEvents() | out-null
	}
	
	$global:csts.init() | out-null
	
	#show the form.  This is a dialog, so after this all actions must be event calls or based off the heart beat.
	[GUI]::Get().ShowContent("/views/home.xaml") | out-null
	[GUI]::Get().ShowDialog() | out-null
}
end{
	$global:csts.IsActive = $false;
	
	gci "$($global:csts.execPath)\db\*.dat" | %{
		[SQL]::Get( $_.name ).Close() | out-null
	}
	
	[Log]::Get().save();
	$global:csts.Dispose();
	[System.GC]::Collect() | out-null
	$error;
}