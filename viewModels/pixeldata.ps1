[CmdletBinding()]param()
begin{
	if(!(test-path "$($global:csts.ExecPath)\bin\pixelData.dll")){
		Add-Type -Language CSharpVersion3 -TypeDefinition ([System.IO.File]::ReadAllText("$($global:csts.ExecPath)\types\pixelData.cs")) -ReferencedAssemblies @("System.Drawing","WindowsBase","System.Windows.Forms") -ErrorAction Stop -OutputAssembly "$($global:csts.ExecPath)\bin\pixelData.dll" -outputType Library
	}
	if (!("cyberToolSuite.pixelDataObj" -as [type])) {
		Add-Type -path "$($global:csts.ExecPath)\bin\pixelData.dll"
	}
	
	Class PixelData{
		$pixelGrabber;
		$pollData;
		
		PixelData(){
			$this.pixelGrabber = new-object cyberToolSuite.pixelDataObj
		}
		
		Poll(){
			$color = $this.pixelGrabber.Get()
			$this.PollData = @{ "R" = $color.R; "G" = $color.G; "B" = $color.B; "A" = $color.A; }
		}
		
		[Hashtable] Get(){return $this.PollData}
	}
}
Process{
	
}
End{

}