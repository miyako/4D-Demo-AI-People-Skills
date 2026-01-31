var $version; $maintext; $subtext : Text
var $r : Text
var $format : Text
var $width; $height; $shift : Integer

Case of 
	: (Form event code=On Unload)
		
		Case of 
			: (Form.quit)
				QUIT 4D
			: (OBJECT Get value("BtnDemo")=1)
				01_Start
		End case 
		
	: (Form event code=On Load)
		
		Form.title:=Get window title(Current form window)
		Form.quit:=False
		
		If (Form.info=Null)
			OBJECT SET VISIBLE(*; "labelInfo"; False)
			OBJECT SET VISIBLE(*; "txtInfo"; False)
		End if 
		
		If (Form.blog=Null)
			OBJECT SET VISIBLE(*; "labelBlog"; False)
			OBJECT SET VISIBLE(*; "txtBlog"; False)
		End if 
		
		If (Form.title=Null)
			OBJECT SET VISIBLE(*; "txtTitle"; False)
		Else 
			OBJECT SET TITLE(*; "txtTitle"; Form.title)
		End if 
		
		If (Form.minimumVersion=Null)
			OBJECT SET VISIBLE(*; "labelVersion"; False)
			OBJECT SET VISIBLE(*; "txtVersion"; False)
		Else 
			$version:="4D "+Substring(Form.minimumVersion; 1; 2)
			If (Length(Form.minimumVersion)>2)
				$r:=String(Formula from string("0x"+Substring(Form.minimumVersion; 3; 1)).call())
				If ($r#"0")
					$version:=$version+" R"+$r
					$format:=OBJECT Get format(*; "Icon4D")
					$format:=Replace string($format; "4D.png"; "4DR.png")
					OBJECT SET FORMAT(*; "Icon4D"; $format)
				End if 
			End if 
			$maintext:=OBJECT Get title(*; "TxtVersion")
			$maintext:=Replace string($maintext; "{version}"; $version)
			OBJECT SET TITLE(*; "TxtVersion"; $maintext)
			If (Application version<Form.minimumVersion)
				Form.quit:=True
				OBJECT SET TITLE(*; "BtnDemo"; "Quit 4D")
				$maintext:=OBJECT Get title(*; "ErrorMainText")
				$maintext:=Replace string($maintext; "{version}"; $version)
				OBJECT SET TITLE(*; "ErrorMainText"; $maintext)
				OBJECT SET VISIBLE(*; "ErrorMainText"; True)
				OBJECT SET VISIBLE(*; "ErrorSubText"; True)
				OBJECT SET VISIBLE(*; "White90"; True)
			End if 
		End if 
		If (Form.quit)
			OBJECT SET TITLE(*; "BtnDemo"; "Quit 4D")
			OBJECT SET TITLE(*; "ErrorMainText"; $maintext)
			OBJECT SET TITLE(*; "ErrorSubText"; $subtext)
			OBJECT SET VISIBLE(*; "ErrorMainText"; True)
			OBJECT SET VISIBLE(*; "ErrorSubText"; True)
			OBJECT SET VISIBLE(*; "White90"; True)
		End if 
End case 