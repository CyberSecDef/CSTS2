[CmdletBinding()]param()
begin{
	Class Log{
		static [Log] $log = $null;
		
		Log( ){
			
		}
		
		[Log] static Get(  ){
			if( [Log]::log -eq $null){
				[Log]::log = [Log]::new( );
			}
			return [Log]::log
		}
		
		[void] Msg($msg, [CSTS_Status]$status, $caller){
			$global:csts.findName('txtLog').Text += "$(get-date -format 'HH:mm:ss') - $($caller) - $([enum]::GetValues([CSTS_Status])[$status]) - $($msg)`n" -replace "- -", "-" -replace "  "," "
		}
		
		[void] Save(){
			$global:csts.findName('txtLog').Text | set-content "$($global:csts.execPath)\logs\$( Get-Date -format yyyyMMdd-HHmmss ).txt"
		}
	}
}
Process{
	$global:csts.libs.add('LOG', ([Log]::new()) ) | out-null
}
End{

}