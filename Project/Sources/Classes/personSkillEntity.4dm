Class extends Entity

Function get levelStr() : Text
	
	Case of 
		: (True)
			Case of 
				: (This.level<=3)
					return "基本"
				: (This.level<=6)
					return "中級者"
				: (This.level<=8)
					return "上級者"
				: (This.level<=9)
					return "師範"
				: (This.level<=10)
					return "神"
				Else 
					return "不明"
			End case 
		Else 
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
	End case 
	