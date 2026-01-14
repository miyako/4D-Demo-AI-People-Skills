//%attributes = {"invisible":true,"preemptive":"incapable"}
#DECLARE($options : Object)

var $process; $window : Integer

Case of 
	: (Count parameters=0)
		$options:={}
		$options.title:="Tool calling\rwith 4D AI Kit"
		$options.blog:="blog.4d.com"
		$options.info:="4D AI Kit"
		$options.minimumVersion:="2100"
		$process:=New process(Current method name; 0; Current method name; $options; *)
	Else 
		
		SET MENU BAR(1)
		$window:=Open form window("HDI"; Shift down ? Plain form window : Plain form window no title; Horizontally centered; Vertically centered)
		DIALOG("HDI"; $options)
		CLOSE WINDOW($window)
		
		If ($options.quit=True)
			QUIT 4D
		Else 
			$window:=Open form window("Menu"; Plain form window; Horizontally centered; Vertically centered)
			DIALOG("Menu")
			CLOSE WINDOW($window)
		End if 
End case 