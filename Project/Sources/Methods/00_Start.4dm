//%attributes = {}
var $ps; $win : Integer
var $options : Object
var $cr : Text

Case of 
	: (Count parameters=0)
		//This is for DOT NOTATION only. Do NOT change 16R5 !!! See below for more info
		//Modify $option variable (below) for minimal version
		If (Application version<"1650")  // 16R5
			ALERT("Sorry, this \"How do I\" (HDI) example must be used with a newer version of 4D (v16 R6 and above)"; "Quit")
			QUIT 4D
		Else 
			$ps:=New process(Current method name; 0; Current method name; 0)
		End if 
		
	Else 
		
		$cr:=Char(Carriage return)
		
		If (Shift down)  //  for debug purpose only
			$win:=Open form window("HDI"; Plain form window; Horizontally centered; Vertically centered)
		Else 
			$win:=Open form window("HDI"; Plain form window no title; Horizontally centered; Vertically centered)
		End if 
		
		$options:={}
		$options.title:="Tool calling"+$cr+"with 4D AI Kit"
		$options.blog:="blog.4d.com"
		$options.info:="4D AI Kit"  //ex : "4D View Pro feature"
		$options.minimumVersion:="2100"  // 1660 means 16R6   1601 means 16.1 (do not use !)
		//$options.license:=4D Write license  // IF ANY NEEDED
		
		// THE BACKGROUND PICTURE IS IN THE RESOURCES : Resources/Images/HDIabout.png
		// the picture size is 724 * 364
		// these 3 commented lines can be removed when done !
		
		DIALOG("HDI"; $options)
		CLOSE WINDOW
		
		If ($options.quit=True)
			QUIT 4D
		Else 
			$win:=Open form window("Menu"; Plain form window; Horizontally centered; Vertically centered)
			DIALOG("Menu")
			CLOSE WINDOW
		End if 
End case 