property peopleWithSimilarities : Collection
property selectedPerson : Object
property selectedSimilarPerson : Object
property similarPeople : Collection
property actions : Object

Class constructor()
	This.similarPeople:=[]
	This.actions:={\
		searchingSimilarities: {running: 0; progress: {value: 0; message: ""}; similarityLevel: 90; timing: 0}\
		}
	
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearch@"; False)
	End case 
	
Function btnDropEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			If (This.selectedSimilarPerson#Null)
				This.selectedPerson.entity.deleteMe()
			End if 
	End case 
	
Function btnSearchSimilaritiesEventHandler($formEventCode : Integer)
	var $startMillisecond; $timing : Integer
	var $person; $similarPerson : Object
	
	Case of 
		: ($formEventCode=On Clicked)
			
			
			Form.peopleWithSimilarities:=[]
			Form.similarPeople:=[]
			
			This.actions.searchingSimilarities.running:=1
			This.actions.searchingSimilarities.timing:=0
			This.actions.searchingSimilarities.progress.message:="Searching similar people"
			
			$startMillisecond:=Milliseconds
			Form.peopleWithSimilarities:=ds.person.peopleWithSimilarities($formObject.actions.searchingSimilarities.similarityLevel/100)
			Form.actions.searchingSimilarities.timing:=Milliseconds-$startMillisecond
			
			For each ($person; Form.peopleWithSimilarities)
				$person.entity:=ds.person.get($person.personID)
				For each ($similarPerson; $person.similarities)
					$similarPerson.entity:=ds.person.get($similarPerson.personID)
				End for each 
			End for each 
			
			
			
	End case 
	
Function listBoxPeopleEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Selection Change)
			If (Form.selectedPerson=Null)
				Form.similarPeople:=[]
			Else 
				Form.similarPeople:=Form.selectedPerson.similarities
			End if 
	End case 
	
Function rulerSimilarityEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			OBJECT SET TITLE(*; "btnSearchSimilarities"; "Search similarities ("+String(This.actions.searchingSimilarities.similarityLevel/100)+")")
			OBJECT SET VISIBLE(*; "similaritiesSearchMessage"; False)
	End case 
	
	
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateSearchAllSimilarPeople($peopleWithSimilarities : Collection; $timing : Integer)
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.terminateSearchAllSimilarPeople($1; $2)); *; $peopleWithSimilarities; $timing)
	Else 
		var $person; $similarPerson : Object
		
		For each ($person; $peopleWithSimilarities)
			$person.entity:=ds.person.get($person.personID)
			For each ($similarPerson; $person.similarities)
				$similarPerson.entity:=ds.person.get($similarPerson.personID)
			End for each 
		End for each 
		
		OBJECT SET VISIBLE(*; "similaritiesSearchSpinner"; False)
		Form.peopleWithSimilarities:=$peopleWithSimilarities
		Form.actions.searchingSimilarities.timing:=$timing
		Form.actions.searchingSimilarities.progress.message:=String($peopleWithSimilarities.length)+" "+\
			(($peopleWithSimilarities.length<=1) ? "person" : "people")+" with similarities found in "+String($timing)+" ms"
	End if 