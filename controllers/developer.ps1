[CmdletBinding()]param()
begin{
	Class PixelData{
		$gui
		$grabber
		$pollData
		
		[void] registerEvents(){
		
		}
		
		PixelData(){
			$this.grabber = new-object cyberToolSuite.pixelDataObj
		}
		
		[Hashtable] Get(){
			return $this.PollData
		}
		
		Poll(){
			$color = $this.grabber.Get()
			
			$this.PollData = @{
				"R" = $color.R;
				"G" = $color.G;
				"B" = $color.B;
				"A" = $color.A;
			}
		}
	}
	
	Class Developer{
		$pixelData;
		
		[void] registerEvents(){
			$global:csts.findName('rGalMines').add_SelectionChanged( { write-host $global:csts.findName('rGalMines').SelectedItem } ) | out-null
			$global:csts.findName('rGalMineLength').add_SelectionChanged( { write-host $global:csts.findName('rGalMineLength').SelectedItem } ) | out-null	
			
			$global:csts.findName('rGalTheme').add_SelectionChanged( { [GUI]::Get().ChangeTheme( $global:csts.findName('rGalTheme').SelectedItem ) } )  | out-null	
		}
		
		Developer(){
			$this.pixelData = new-object PixelData
		}
		
		Poll(){
			$this.pixelData.Poll()
		}
	}
}
Process{
	
}
End{

}