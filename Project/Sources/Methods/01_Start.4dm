//%attributes = {"preemptive":"incapable"}
#DECLARE($options : Object)

var $i; $window : Integer

Case of 
	: (Count parameters=0)
		$options:={title: "AI Tool calling with 4D"}
		
		ARRAY LONGINT($windows; 0)
		WINDOW LIST($windows)
		
		For ($i; 1; Size of array($windows))
			$window:=$windows{$i}
			If (0=Compare strings(Get window title($window); $options.title; sk strict))
				CALL FORM($window; Formula(Form.activateWindow()))
				return 
			End if 
		End for 
		
		CALL WORKER(1; Formula(01_Start); $options)
		
	Else 
		
		SET MENU BAR(1)
		$window:=Open form window("menu"; Plain form window; Horizontally centered; Vertically centered)
		SET WINDOW TITLE($options.title; $window)
		DIALOG("menu"; *)
		
End case 