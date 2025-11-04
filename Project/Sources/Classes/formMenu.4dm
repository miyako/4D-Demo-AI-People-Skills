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
					OBJECT SET SUBFORM(*; "Subform"; "intro")
				: (This.menu.currentValue="Data Gen & Embeddings 🪄")
					OBJECT SET SUBFORM(*; "Subform"; "vectorize")
				: (This.menu.currentValue="Question me with tools 🪄")
					OBJECT SET SUBFORM(*; "Subform"; "questionMeTools")
				: (This.menu.currentValue="Semantic search")
					OBJECT SET SUBFORM(*; "Subform"; "semanticSearch")
			End case 
	End case


