[CmdletBinding()]param()
begin{

	Class Systems{
	
		[void] Poll(){
			if($global:csts.objs.PreventSleep -ne $null){
				$global:csts.objs.PreventSleep.pollEvents()
				if($global:csts.objs.PreventSleep.IsChanged -eq $true){
					$global:csts.controllers.systems.updatePreventSleepUI()
				}
			}
		}
		
		[void] registerEvents(){
			$global:csts.findName('btnPreventSleep').add_click( { $global:csts.controllers.systems.showPreventSleepUI() } ) | out-null
		}
		
		[void] showPreventSleepUI(){
			[GUI]::Get().ShowContent("/views/systems/preventSleep.xaml") | out-null
			
			[GUI]::Get().window.findName('UC').findName('btnPrepPrevSleep').add_click( {
				$global:csts.objs.PreventSleep.Initialize()
				$global:csts.controllers.systems.updatePreventSleepUI() 
			} ) | out-null
			
			[GUI]::Get().window.findName('UC').findName('btnExecPrevSleep').add_click( { 
				$global:csts.objs.PreventSleep.InvokePreventSleep()
				$global:csts.controllers.systems.updatePreventSleepUI() 
			} ) | out-null
			
			if($global:csts.objs.PreventSleep -eq $null){
				$global:csts.objs.Add('PreventSleep', ( [PreventSleep]::new()) )
			}
		}
		
		[void] updatePreventSleepUI(){
			if( [GUI]::Get().window.findName('UC').findName('dgPreventSleepHosts') -ne $null){
				[GUI]::Get().window.findName('UC').findName('dgPreventSleepHosts').Items.Clear()
				$global:csts.objs.PreventSleep.data | sort { $_.hostname} | % {
					[GUI]::Get().window.findName('UC').findName('dgPreventSleepHosts').Items.add($_)
				}
				[GUI]::Get().window.findName('UC').findName('dgPreventSleepHosts').Items.Refresh()
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
			}
		}
	}
}
Process{
	return [Systems]::new()
}
End{

}