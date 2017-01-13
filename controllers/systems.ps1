[CmdletBinding()]param()
begin{

	Class PortScanner{

		[void] registerEvents(){
		
		}
	
		PortScanner(){
			
		}
		
		[void]Poll(){
		
		}
		
		[void]Test(){
			write-host 'in test'
		}
		
		[void]Load(){
		
		}
	}
	
	
	Class Systems{
	
		[void] registerEvents(){
			$global:csts.findName('btnApplyPolicies').add_click( { $global:csts.controllers.systems.showApplyPolicies() } ) | out-null
			$global:csts.findName('btnPreventSleep').add_click( { $global:csts.controllers.systems.showPreventSleep() } ) | out-null
		}
	
		[void] showApplyPolicies(){
			write-host "test"
		}
		
		[void] sortClick(){
		
			write-host 'test'
		}
		
		[void] prepPrevSleep(){
			write-host 'prepPrevSleep'
			$hosts = $global:csts.libs.hosts.Get()
			$global:csts.libs.gui.window.findName('UC').findName('dgPreventSleepHosts').Items.Clear()
			$hosts.keys | sort | % {
				$global:csts.libs.gui.window.findName('UC').findName('dgPreventSleepHosts').Items.add(
					([pscustomobject]@{'Hostname'=$_;IP= "$($hosts.$($_).IP)" ;Results="___"})
				)
			}
		}
		
		[void] showPreventSleep(){
			write-host "Prevent Sleep"
			$global:csts.libs.GUI.ShowContent("/views/systems/preventSleep.xaml") | out-null
			$global:csts.libs.gui.window.findName('UC').findName('btnPrepPrevSleep').add_click( { $global:csts.controllers.systems.prepPrevSleep() } ) | out-null
		}
	}
}
Process{
	return [Systems]::new()
}
End{

}