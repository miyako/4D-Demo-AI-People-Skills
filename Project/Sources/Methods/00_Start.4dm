//%attributes = {"invisible":true,"preemptive":"incapable"}
#DECLARE($options : Object)

var $i; $window : Integer

Case of 
	: (Count parameters=0)
		$options:={title: "Tool calling\rwith 4D AI Kit"}
		
		ARRAY LONGINT($windows; 0)
		WINDOW LIST($windows)
		
		For ($i; 1; Size of array($windows))
			$window:=$windows{$i}
			If (0=Compare strings(Get window title($window); $options.title; sk strict))
				CALL FORM($window; Formula(Form.activateWindow()))
				return 
			End if 
		End for 
		
		CALL WORKER(1; Formula(00_Start); $options)
		
	Else 
		
		SET MENU BAR(1)
		$window:=Open form window("HDI"; Shift down ? Plain form window : Plain form window no title; Horizontally centered; Vertically centered)
		SET WINDOW TITLE($options.title; $window)
		DIALOG("HDI"; *)
		
End case 