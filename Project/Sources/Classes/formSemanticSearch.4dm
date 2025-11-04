property identity : Object
property jobDetails : Object
property skills : Object
property address : Object
property result : Collection
property textToSearch : Text
property minimumThresholds : Object
property requestedQuantity : Integer


Class constructor()
	This.textToSearch:=""
	This.result:=Null
	This.requestedQuantity:=100
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			
	End case 
	
	
Function formBtnSearchEventHandler($formEventCode : Integer)
	var $person : cs.personEntity
	var $searchResult : Object
	
	This.result:=[]
	Case of 
		: ($formEventCode=On Clicked)
			$searchResult:=ds.person.personSearchByVector(This.textToSearch; This.requestedQuantity)
			If ($searchResult.success)
				For each ($person; $searchResult.peopleFound)
					This.result.push({person: $person; score: $person.embedding.cosineSimilarity($searchResult.vectorUsed)})
				End for each 
			End if 
	End case 
	
	