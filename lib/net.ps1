[CmdletBinding()]param()
begin{
	Class Net{
		
		Net( ){
			
		}
		
		[object[]] static Ping( $hostname ){
			return Get-WmiObject -Class win32_pingstatus -Filter "address='$($hostname.trim())'"
		}
		
		[String] static getIP( $h ){
			try{
				$hostAddr = [System.Net.Dns]::GetHostAddresses($h);
				try{
					$ip = $hostAddr[0].IPAddressToString;
				}catch{
					$ip = ""
				}
				
			}catch{
				$ip = ""
			}
			return $ip
		}
		
		[String] static getHostName( $h ){
			if( $_ -match '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'){
				$hostname = ([System.Net.Dns]::gethostentry($h)).hostName;
			}else{
				$hostname = $h
			}
			return $hostname
		}
		
	}
}
Process{
	$global:csts.libs.add('NET', ([Net]::new()) ) | out-null
}
End{

}