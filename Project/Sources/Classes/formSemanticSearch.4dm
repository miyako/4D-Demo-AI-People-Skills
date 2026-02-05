property identity : Object
property jobDetails : Object
property skills : Object
property address : Object
property textToSearch : Text
property result : Collection
property requestedQuantity : Integer
property threshold : Real
property searchFilePath : Object

Class extends formVectorize

Class constructor()
	
	Super()
	
	This.searchFilePath:={en: "Prompts/search-en.txt"; ja: "Prompts/search-ja.txt"}
	This.textToSearch:=This.getText(This.searchFilePath[Macintosh command down ? "en" : "ja"])
	This.result:=Null
	This.requestedQuantity:=100
	This.threshold:=0.7
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	Super.formEventHandler($formEventCode)
	
	If (This.menu.index=2)
		Case of 
			: ($formEventCode=On Double Clicked) && (FORM Event.objectName="Input")
				
				$textToSearch:=This.searchFilePath[Macintosh command down ? "en" : "ja"]
				OBJECT SET VALUE(FORM Event.objectName; This.getText($textToSearch))
				GOTO OBJECT(*; "")
				
			: ($formEventCode=On Clicked) && (Contextual click)
				var $dataFiles : Collection
				$dataFiles:=Folder("/PACKAGE/Data").files(fk ignore invisible | fk recursive).query("extension in :1"; [".4dd"; ".data"]).orderBy("parent.name asc")
				If ($dataFiles.length#0)
					$menu:=Create menu
					var $dataFile : 4D.File
					For each ($dataFile; $dataFiles)
						APPEND MENU ITEM($menu; $dataFile.parent.fullName)
						SET MENU ITEM PARAMETER($menu; -1; $dataFile.platformPath)
					End for each 
					$parameter:=Dynamic pop up menu($menu)
					RELEASE MENU($menu)
					If ($parameter#"")
						OPEN DATA FILE($parameter)
					End if 
				End if 
		End case 
	End if 
	
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