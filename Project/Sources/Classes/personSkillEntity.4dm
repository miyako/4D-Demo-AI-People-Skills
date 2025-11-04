Class extends Entity

Function get levelStr() : Text
	Case of 
		: (This.level<=3)
			return "beginner"
		: (This.level<=6)
			return "intermediate"
		: (This.level<=8)
			return "expert"
		: (This.level<=9)
			return "master"
		: (This.level<=10)
			return "absolute master"
		Else 
			return "unknown"
	End case 