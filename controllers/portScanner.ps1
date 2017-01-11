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
}
process{

	
}
end{
	[System.GC]::Collect() | out-null
}