[CmdletBinding()]param()
begin{
	Class Net{
		
		Net( ){
			
		}
		
		[object[]] static Ping( $hostname ){
			return Get-WmiObject -Class win32_pingstatus -Filter "address='$($hostname.trim())'"
		}
		
		
	}
}
Process{
	$global:csts.libs.add('NET', ([Net]::new()) ) | out-null
}
End{

}