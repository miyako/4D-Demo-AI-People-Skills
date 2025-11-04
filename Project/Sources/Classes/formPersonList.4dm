property personList : cs.personSelection
property searchText : Text
property requestedQuantity : Integer
property exportResult : Object



Class constructor()
	
	This.searchText:=""
	This.personList:=Null
	This.requestedQuantity:=100
	This.exportResult:=Null
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			// Load all persons on form load
			This.personList:=ds.person.all().orderBy("lastname, firstname")
			
	End case 
	
	
Function btnSearchEventHandler($formEventCode : Integer)
	var $person : cs.personEntity
	var $searchResult : Object
	var $tempCollection : Collection
	
	Case of 
		: ($formEventCode=On Clicked)
			If (This.searchText="")
				// If search text is empty, show all persons
				This.personList:=ds.person.all().orderBy("lastname, firstname")
			Else 
				// Use semantic search to find persons
				$searchResult:=ds.person.personSearchByVector(This.searchText; This.requestedQuantity)
				If ($searchResult.success)
					This.personList:=$searchResult.peopleFound
				Else 
					This.personList:=ds.person.query("firstname = :1 OR lastname = :1 OR email = :1"; "@"+This.searchText+"@").orderBy("lastname, firstname")
				End if 
			End if 
	End case 
	

Function btnExportEventHandler($formEventCode : Integer)
	var $exportData : Collection
	var $person : cs.personEntity
	var $personObj : Object
	var $jsonText : Text
	var $file : 4D.File
	var $timestamp : Text
	
	Case of 
		: ($formEventCode=On Clicked)
			// Create export collection
			$exportData:=[]
			
			If (This.personList#Null)
				For each ($person; This.personList)
					$personObj:={\
						ID: $person.ID; \
						firstname: $person.firstname; \
						lastname: $person.lastname; \
						fullname: $person.fullname; \
						email: $person.email; \
						phone: $person.phone; \
						birthDate: $person.birthDate; \
						gender: $person.gender; \
						jobTitle: ($person.jobDetail#Null) ? $person.jobDetail.jobTitle : ""; \
						hireDate: ($person.jobDetail#Null) ? $person.jobDetail.hireDate : !00-00-00!; \
						billingRate: ($person.jobDetail#Null) ? $person.jobDetail.billingRate : 0; \
						city: ($person.address#Null) ? $person.address.city : ""; \
						country: ($person.address#Null) ? $person.address.country : ""; \
						skills: $person.personSkills.extract("skill.name")\
						}
					$exportData.push($personObj)
				End for each 
			End if 
			
			// Convert to JSON
			$jsonText:=JSON Stringify($exportData; *)
			
			// Create file with timestamp
			$timestamp:=String(Current date; ISO date; Current time)
			$timestamp:=Replace string($timestamp; ":"; "-")
			$timestamp:=Replace string($timestamp; " "; "_")
			
			$file:=File("/PACKAGE/persons_export_"+$timestamp+".json"; fk platform path)
			$file.setText($jsonText)
			
			// Show confirmation
			This.exportResult:={success: True; message: "Exported "+String($exportData.length)+" persons to "+$file.platformPath; count: $exportData.length}
			
			ALERT("Export successful!\\r\\r"+String($exportData.length)+" persons exported to:\\r"+$file.platformPath)
			
	End case 
	

