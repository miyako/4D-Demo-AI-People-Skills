property providersGen : Object
property modelsGen : Object
property actions : Object
property people : cs.personSelection
property selectedPerson : cs.personEntity
property webAreaInitialized : Boolean

Class extends formSemanticSearch

Class constructor()
	
	Super()
	
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	cs.AI_QuestionningTools.me.resetContext()
	
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	This.webAreaInitialized:=False
	$providers:=ds.providerSettings.providersAvailable("reasoning")
	If ($providers.length>0)
		This.providersGen.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.reasoningModels.models
		This.modelsGen.values:=$models.extract("model")
		This.modelsGen.index:=This.modelsGen.values.findIndex(Formula($1.value=$provider.defaults.reasoning))
	End if 
	
	var $actions : Object
	$actions:={\
		questionning: {running: 0; progress: {message: ""}; timingResult: ""; prompt: ""}\
		}
	
	var $action : Text
	For each ($action; $actions)
		This.actions[$action]:=$actions[$action]
	End for each 
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	Super.formEventHandler($formEventCode)
	
	If (This.menu.currentValue="Question me with tools 🪄")
		Case of 
			: ($formEventCode=On Load) || ($formEventCode=On Page Change)
				OBJECT SET VISIBLE(*; "questionning@"; False)
				OBJECT SET VISIBLE(*; "timingResult"; False)
				OBJECT SET SUBFORM(*; "personDetails"; "selectAPerson")
		End case 
	End if 
	
Function btnNewChatEventHandler($formEventCode : Integer)
	
	If (This.menu.currentValue="Question me with tools 🪄")
		cs.AI_QuestionningTools.me.resetContext()
		This.people:=Null
		This.webAreaInitialized:=False
		var $templateFilename : Text
		var $templatePath : Text
		$templateFilename:=cs.ChatHTMLRenderer.me.getInitialHTML()
		$templatePath:=Get 4D folder(Current resources folder)+$templateFilename
		OBJECT SET SUBFORM(*; "personDetails"; "selectAPerson")
		WA OPEN URL(*; "Web Area"; $templatePath)
		This.actions:={\
			questionning: {running: 0; progress: {message: ""}; timing: 0; prompt: ""}\
			}
	End if 
	
Function btnAskMeEventHandler($formEventCode : Integer)
	
	If (This.menu.currentValue="Question me with tools 🪄")
		Case of 
			: ($formEventCode=On Clicked)
				If (This.modelsGen.currentValue="")
					ALERT("Please select a model first")
					return 
				End if 
				
				This.actions.questionning.running:=1
				This.actions.questionning.timing:=0
				
				Form.people:=Null
				OBJECT SET VISIBLE(*; "questionning@"; True)
				OBJECT SET VISIBLE(*; "btn@"; False)
				OBJECT SET VISIBLE(*; "select@"; False)
				OBJECT SET VISIBLE(*; "timingResult"; False)
				
				cs.AI_QuestionningTools.me.setAgent(This.providersGen.currentValue; This.modelsGen.currentValue)
				cs.AI_QuestionningTools.me.askMe(Form.actions.questionning.prompt; Form)
				This.actions.questionning.prompt:=""
				
		End case 
	End if 
	
Function lbPeopleListboxEventHandler($formEventCode : Integer)
	
	If (This.menu.currentValue="Question me with tools 🪄")
		Case of 
			: ($formEventCode=On Selection Change)
				If (This.selectedPerson#Null)
					OBJECT SET SUBFORM(*; "personDetails"; "person")
				Else 
					OBJECT SET SUBFORM(*; "personDetails"; "selectAPerson")
				End if 
		End case 
	End if 
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateQuestionning($timing : Integer; $peopleFound : cs.personSelection)
	
	If (Form#Null)
		Form.terminateQuestionning($timing; $peopleFound)
		Form.actions.questionning.timingResult:="Answer given in "+String($timing)+" ms"
		Form.people:=$peopleFound
		OBJECT SET VISIBLE(*; "questionning@"; False)
		OBJECT SET VISIBLE(*; "btn@"; True)
		OBJECT SET VISIBLE(*; "select@"; True)
		OBJECT SET VISIBLE(*; "timingResult"; True)
	End if 
	
Function progressQuestionning($input : Object)
	
	If (Form#Null)
		
		Form.progressQuestionning($input)
		
		If (Not(Undefined($input.messages)))
			// Initialize web area with template HTML file on first use
			If (Not(This.webAreaInitialized))
				var $templateFilename : Text
				var $templatePath : Text
				$templateFilename:=cs.ChatHTMLRenderer.me.getInitialHTML()
				$templatePath:=Get 4D folder(Current resources folder)+$templateFilename
				WA OPEN URL(*; "Web Area"; $templatePath)
				This.webAreaInitialized:=True
			End if 
			
			// Update content via JavaScript without page reload
			cs.ChatHTMLRenderer.me.updateWebAreaWithJS("Web Area"; $input.messages)
		End if 
		
		If (Not(Undefined($input.progress.message)))
			Form.actions.questionning.progress.message:=$input.progress.message
		End if 
		
	End if 