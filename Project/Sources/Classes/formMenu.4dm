property menu : Object

Class constructor()
	
	This.menu:={}
	This.menu.values:=["Intro"; "Data Gen & Embeddings 🪄"; "Semantic search"; "Question me with tools 🪄"]
	This.menu.index:=0
	
Function tabMenuEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			Case of 
				: (This.menu.currentValue="Intro")
					FORM GOTO PAGE(1)
				: (This.menu.currentValue="Data Gen & Embeddings 🪄")
					FORM GOTO PAGE(2)
					//OBJECT SET SUBFORM(*; "Subform"; "vectorize")
				: (This.menu.currentValue="Question me with tools 🪄")
					FORM GOTO PAGE(3)
					//OBJECT SET SUBFORM(*; "Subform"; "questionMeTools")
				: (This.menu.currentValue="Semantic search")
					FORM GOTO PAGE(4)
					//OBJECT SET SUBFORM(*; "Subform"; "semanticSearch")
			End case 
	End case 