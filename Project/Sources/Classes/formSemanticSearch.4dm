property identity : Object
property jobDetails : Object
property skills : Object
property address : Object
property textToSearch : Text
property result : Collection
property requestedQuantity : Integer
property threshold : Real

Class extends formVectorize

Class constructor()
	
	Super()
	
	This.textToSearch:=""
	This.result:=Null
	This.requestedQuantity:=100
	This.threshold:=0.25
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	Super.formEventHandler($formEventCode)
	
Function formBtnSearchEventHandler($formEventCode : Integer)
	
	var $person : cs.personEntity
	var $searchResult : Object
	This.result:=[]
	Case of 
		: ($formEventCode=On Clicked)
			$searchResult:=ds.person.personSearchByVector(This.textToSearch; This.requestedQuantity; This.threshold)
			If ($searchResult.success)
				For each ($person; $searchResult.peopleFound)
					This.result.push({person: $person; score: $person.embedding.cosineSimilarity($searchResult.vectorUsed)})
				End for each 
			End if 
	End case 