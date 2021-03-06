
[CmdletBinding()]param()
begin{
	$Null = [Reflection.Assembly]::LoadWithPartialName("WindowsBase")
	
	Class Export{
		[bool] $HeaderWritten = $false;
		$worksheet = $null;
		
		Export( ){
			
		}
		
		[void] Excel( $inputObject, $Path, $Append, $WorkSheetName, $widths = $null){
			if($inputObject -ne $null){
				If((Test-Path $Path) -and $Append ) {
					$this.WorkSheet = $this.addXLSXWorkSheet($Path, $WorkSheetName)
				} Else {
					$Null = $this.newXLSXWorkBook($Path)
					$this.WorkSheet = $this.addXLSXWorkSheet($path, $WorkSheetName)
				}
				$this.HeaderWritten = $False
				$this.exportWorkSheet( $InputObject, $Path, $widths )
			}
		}
				
		exportWorkSheet(
			[Object[]]$InputObject,
			[String]$Path,
			$widths = $null
		){
			$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Open)
			$WorkSheetPart = $exPkg.GetPart($this.Worksheet.Uri)
			$WorkSheetXmlDoc = New-Object System.Xml.XmlDocument
			$WorkSheetXmlDoc.Load($WorkSheetPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))
			$this.HeaderWritten = $False
			$headers = ($InputObject[0].psobject.properties | select -expand Name)

			If($InputObject.GetType().Name -match 'byte|short|int32|long|sbyte|ushort|uint32|ulong|float|double|decimal|string') {
				Add-Member -InputObject $InputObject -MemberType NoteProperty -Name ($InputObject.GetType().Name) -Value $InputObject
			}
			
			If((-not $this.HeaderWritten) ){
				
				$RowNode = $WorkSheetXmlDoc.CreateElement('row', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
			
			
				ForEach($Prop in $headers ) {
					
					$CellNode = $WorkSheetXmlDoc.CreateElement('c', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.SetAttribute('t',"inlineStr")
					$Null = $CellNode.SetAttribute('s',"1")
					$Null = $RowNode.AppendChild($CellNode)
					
					$CellNodeIs = $WorkSheetXmlDoc.CreateElement('is', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.AppendChild($CellNodeIs)
					
					$CellNodeIsT = $WorkSheetXmlDoc.CreateElement('t', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$CellNodeIsT.InnerText = [String]$Prop
					$Null = $CellNodeIs.AppendChild($CellNodeIsT)
					
					$Null = $WorkSheetXmlDoc.DocumentElement.Item("sheetData").AppendChild($RowNode)	
				}
				
				$this.HeaderWritten = $True
			}

			foreach($row in $inputObject.GetEnumerator() ){
				$RowNode = $WorkSheetXmlDoc.CreateElement('row', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
				ForEach($Prop in $headers ) {

					$CellNode = $WorkSheetXmlDoc.CreateElement('c', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.SetAttribute('t',"inlineStr")
					
					# if( ( ( [String]$row.$($prop) ) -split "`n").count -gt 1){
						$Null = $CellNode.SetAttribute('s',"1")
					# }
					
					$Null = $RowNode.AppendChild($CellNode)
					
					$CellNodeIs = $WorkSheetXmlDoc.CreateElement('is', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.AppendChild($CellNodeIs)
					
					$CellNodeIsT = $WorkSheetXmlDoc.CreateElement('t', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					
					#make sure the cell content isn't too long for excel to handle
					$innerText = [String]$row.$($prop)
					if($innerText.length -gt 32000){
						$innerText = $innerText.substring(0,32000)
					}
					
					$CellNodeIsT.InnerText = $innerText
					
					$Null = $CellNodeIs.AppendChild($CellNodeIsT)
					
					$Null = $WorkSheetXmlDoc.DocumentElement.Item("sheetData").AppendChild($RowNode)
				}
			}
			
			if($widths -ne $null){
				$cols = $WorkSheetXmlDoc.CreateElement('cols', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI )
				$i = 0
				$widths | % {
					$i++
					$col = $WorkSheetXmlDoc.CreateElement('col', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$col.SetAttribute('width', $_)
					$col.SetAttribute('min', $i)
					$col.SetAttribute('max', $i)
					$col.SetAttribute('customWidth', 1)
					$cols.appendChild($col)
				}
				$Null = $WorkSheetXmlDoc.DocumentElement.InsertBefore($cols, $WorkSheetXmlDoc.DocumentElement.Item("sheetData"))
				
			}
			
			
			$WorkSheetXmlDoc.Save($WorkSheetPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Write))
			$exPkg.Close()
		}
		
		
		[object] addXLSXWorkSheet(
			[String]$Path,
			[String]$Name
		){
			
			$New_Worksheet_xml = New-Object System.Xml.XmlDocument

			$XmlDeclaration = $New_Worksheet_xml.CreateXmlDeclaration("1.0", "UTF-8", "yes")
			$Null = $New_Worksheet_xml.InsertBefore($XmlDeclaration, $New_Worksheet_xml.DocumentElement)

			$workSheetElement = $New_Worksheet_xml.CreateElement("worksheet")

			$Null = $workSheetElement.SetAttribute("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
			$Null = $workSheetElement.SetAttribute("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
			$Null = $New_Worksheet_xml.AppendChild($workSheetElement)

			$Null = $New_Worksheet_xml.DocumentElement.AppendChild($New_Worksheet_xml.CreateElement("sheetData"))
			
			Try {
				$Null = Get-Item -Path $Path -ErrorAction stop
			} Catch {
				$Error.RemoveAt(0)
				$NewError = New-Object System.Management.Automation.ErrorRecord -ArgumentList $_.Exception,$_.FullyQualifiedErrorId,$_.CategoryInfo.Category,$_.TargetObject
				$PSCmdlet.WriteError($NewError)
				Return $false
			}

			Try {				
				$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Open)
			} catch {
				$_
				Return $false
			}

			$WorkBookPart = $null
			ForEach ($Part in $exPkg.GetParts()) {
				If($Part.ContentType -eq "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" -or $Part.Uri.OriginalString -eq "/xl/workbook.xml") {
					$WorkBookPart = $Part
					break
				}
			}
			
			If(-not $WorkBookPart) {
				Write-Error "Excel Workbook not found in : $Path"
				$exPkg.Close()
				return $false
			}
			
			$WorkBookRels = $WorkBookPart.GetRelationships()
			$WorkBookRelIds = [System.Collections.ArrayList]@()
			$WorkSheetPartNames = [System.Collections.ArrayList]@()
			ForEach($Rel in $WorkBookRels) {
				$Null = $WorkBookRelIds.Add($Rel.ID)
				If($Rel.RelationshipType -like '*worksheet*' ) {
					$WorkSheetName = Split-Path $Rel.TargetUri.ToString() -Leaf
					$Null = $WorkSheetPartNames.Add($WorkSheetName)
				}
			}
			
			$IdCounter = 0 # counter for relationship IDs
			$NewWorkBookRelId = '' # Variable to hold the new found relationship ID
			Do{
				$IdCounter++
				If(-not ($WorkBookRelIds -contains "rId$IdCounter")){
					$NewWorkBookRelId = "rId$IdCounter"
				}
			} while($NewWorkBookRelId -eq '')

			$WorksheetCounter = 0 # counter for worksheet numbers
			$NewWorkSheetPartName = '' # Variable to hold the new found worksheet name
			Do{
				$WorksheetCounter++
				If(-not ($WorkSheetPartNames -contains "sheet$WorksheetCounter.xml")){
					$NewWorkSheetPartName = "sheet$WorksheetCounter.xml"
				}
			} while($NewWorkSheetPartName -eq '')

			$WorkbookWorksheetNames = [System.Collections.ArrayList]@()

			$WorkBookXmlDoc = New-Object System.Xml.XmlDocument
			$WorkBookXmlDoc.Load($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))

			ForEach ($Element in $WorkBookXmlDoc.documentElement.Item("sheets").get_ChildNodes()) {
				$Null = $WorkbookWorksheetNames.Add($Element.Name)
			}
			
			$DuplicateName = ''
			If(-not [String]::IsNullOrEmpty($Name)){
				If($WorkbookWorksheetNames -Contains $Name) {
					$DuplicateName = $Name
					$Name = ''
				}
			} 
			
			If([String]::IsNullOrEmpty($Name)){
				$WorkSheetNameCounter = 0
				$Name = "Table$WorkSheetNameCounter"
				While($WorkbookWorksheetNames -Contains $Name) {
					$WorkSheetNameCounter++
					$Name = "Table$WorkSheetNameCounter"
				}
				If(-not [String]::IsNullOrEmpty($DuplicateName)){
					Write-Warning "Worksheetname '$DuplicateName' allready exist!`nUsing automatically generated name: $Name"
				}
			}

			$Uri_xl_worksheets_sheet_xml = New-Object System.Uri -ArgumentList ("/xl/worksheets/$NewWorkSheetPartName", [System.UriKind]::Relative)
			$Part_xl_worksheets_sheet_xml = $exPkg.CreatePart($Uri_xl_worksheets_sheet_xml, "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml")
			$dest = $part_xl_worksheets_sheet_xml.GetStream([System.IO.FileMode]::Create,[System.IO.FileAccess]::Write)
			$New_Worksheet_xml.Save($dest)
			
			$Null = $WorkBookPart.CreateRelationship($Uri_xl_worksheets_sheet_xml, [System.IO.Packaging.TargetMode]::Internal, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet", $NewWorkBookRelId)


			if( ( $WorkBookPart.GetRelationships() | ? { $_.TargetUri -eq "/xl/styles.xml" } ) -eq $null){
				$Uri_xl_styles_xml = New-Object System.Uri -ArgumentList ("/xl/styles.xml", [System.UriKind]::Relative)
				$Null = $WorkBookPart.CreateRelationship($Uri_xl_styles_xml, [System.IO.Packaging.TargetMode]::Internal, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles", 'rId999')
			}

			$WorkBookXmlDoc = New-Object System.Xml.XmlDocument

			$WorkBookXmlDoc.Load($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))
					
			$WorkBookXmlSheetNode = $WorkBookXmlDoc.CreateElement('sheet', $WorkBookXmlDoc.DocumentElement.NamespaceURI)
			$Null = $WorkBookXmlSheetNode.SetAttribute('name',$Name)
			$Null = $WorkBookXmlSheetNode.SetAttribute('sheetId',$IdCounter)
			$NamespaceR = $WorkBookXmlDoc.DocumentElement.GetNamespaceOfPrefix("r")
			If($NamespaceR) {
				$Null = $WorkBookXmlSheetNode.SetAttribute('id',$NamespaceR,$NewWorkBookRelId)
			} Else {
				$Null = $WorkBookXmlSheetNode.SetAttribute('id',$NewWorkBookRelId)
			}

			$Null = $WorkBookXmlDoc.DocumentElement.Item("sheets").AppendChild($WorkBookXmlSheetNode)

			$WorkBookXmlDoc.Save($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Write))

			$exPkg.Close()

			return (New-Object -TypeName PsObject -Property @{
				Uri = $Uri_xl_worksheets_sheet_xml;
				WorkbookRelationID = $NewWorkBookRelId;
				Name = $Name;
				WorkbookPath = $Path
			})
		}
		
		
		[string] newXLSXWorkBook(
			[String]$Path
		){
		
			$xl_Workbook_xml = New-Object System.Xml.XmlDocument

			$XmlDeclaration = $xl_Workbook_xml.CreateXmlDeclaration("1.0", "UTF-8", "yes")
			$Null = $xl_Workbook_xml.InsertBefore($XmlDeclaration, $xl_Workbook_xml.DocumentElement)

			$workBookElement = $xl_Workbook_xml.CreateElement("workbook")
			$Null = $workBookElement.SetAttribute("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
			$Null = $workBookElement.SetAttribute("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
			$Null = $xl_Workbook_xml.AppendChild($workBookElement)

			$Null = $xl_Workbook_xml.DocumentElement.AppendChild($xl_Workbook_xml.CreateElement("sheets"))
		
			$Path = [System.IO.Path]::ChangeExtension($Path,'xlsx')
			
			Try {
				$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Create)
			} Catch {
				$_
				return ""
			}
			
			$Uri_xl_workbook_xml = New-Object System.Uri -ArgumentList ("/xl/workbook.xml", [System.UriKind]::Relative)
			$Part_xl_workbook_xml = $exPkg.CreatePart($Uri_xl_workbook_xml, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml")
			$dest = $part_xl_workbook_xml.GetStream([System.IO.FileMode]::Create,[System.IO.FileAccess]::Write)
			$xl_workbook_xml.Save($dest)
			$Null = $exPkg.CreateRelationship($Uri_xl_workbook_xml, [System.IO.Packaging.TargetMode]::Internal, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", "rId1")
			
			
			$style_xml = [xml]@"
<?xml version="1.0" encoding="utf-16" standalone="yes"?> <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"> <fonts count="1"> <font> <sz val="8"/> <name val="Calibri"/> <family val="2"/> </font> </fonts> <fills count="1"> <fill /> </fills> <borders count="1"> <border /> </borders> <cellStyleXfs count="1"> <xf /> </cellStyleXfs> <cellXfs count="2" > <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" /> <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyAlignment="1" > <alignment wrapText="1" /> </xf> </cellXfs> </styleSheet>
"@
			$Uri_xl_styles_xml = New-Object System.Uri -ArgumentList ("/xl/styles.xml", [System.UriKind]::Relative)
			$Part_xl_styles_xml = $exPkg.CreatePart($Uri_xl_styles_xml, "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml")
			$styleDest = $Part_xl_styles_xml.GetStream([System.IO.FileMode]::Create,[System.IO.FileAccess]::Write)
			$style_xml.Save($styleDest)
			
			$exPkg.Close()
			Return (Get-Item $Path)
		}
		
		
	}
}
Process{
	$global:csts.libs.add('Export', ([Export]::new()) ) | out-null
}
End{

}