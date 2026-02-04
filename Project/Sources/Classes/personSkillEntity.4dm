Class extends Entity

Function get levelStr() : Text
	
	Case of 
		: (True)
			Case of 
				: (This.level<=3)
					return "基本的な知識を学習した程度"
				: (This.level<=6)
					return "基本的な知識を有しており少しの実務経験がある"
				: (This.level<=8)
					return "基本以上の知識と実務経験がある"
				: (This.level<=9)
					return "かなり高度な知識と豊富な実務経験がある"
				: (This.level<=10)
					return "かなり高度な知識と豊富な実務経験があり他の人を指導できる"
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
	