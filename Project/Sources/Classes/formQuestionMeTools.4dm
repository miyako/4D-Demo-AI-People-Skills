property providersGen : Object
property modelsGen : Object
property actions : Object
property people : cs.personSelection
property selectedPerson : cs.personEntity
property webAreaInitialized : Boolean

Class constructor()
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
	
	This.actions:={\
		questionning: {running: 0; progress: {message: ""}; timingResult: ""; prompt: ""}\
		}
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			OBJECT SET VISIBLE(*; "questionning@"; False)
			OBJECT SET VISIBLE(*; "timingResult"; False)
			OBJECT SET SUBFORM(*; "personDetails"; "selectAPerson")
	End case 
	
Function providersGenListEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This.modelsGen:=This.setModelList(This.providersGen; "reasoning")
	End case 
	
	
Function btnNewChatEventHandler($formEventCode : Integer)
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
	
Function btnAskMeEventHandler($formEventCode : Integer)
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
	
Function lbPeopleListboxEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Selection Change)
			If (This.selectedPerson#Null)
				OBJECT SET SUBFORM(*; "personDetails"; "person")
			Else 
				OBJECT SET SUBFORM(*; "personDetails"; "selectAPerson")
			End if 
	End case 
	
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateQuestionning($timing : Integer; $peopleFound : cs.personSelection)
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.terminateQuestionning($1; $2)); *; $timing; $peopleFound)
	Else 
		Form.actions.questionning.timingResult:="Answer given in "+String($timing)+" ms"
		Form.people:=$peopleFound
		OBJECT SET VISIBLE(*; "questionning@"; False)
		OBJECT SET VISIBLE(*; "btn@"; True)
		OBJECT SET VISIBLE(*; "select@"; True)
		OBJECT SET VISIBLE(*; "timingResult"; True)
	End if 
	
Function progressQuestionning($input : Object)
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.progressQuestionning($1)); *; $input)
	Else 
		
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
	
	//MARK: -
	//MARK: Other functions
	
Function setModelList($providerList : Object; $kind : Text) : Object
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	var $list : Object:={}
	var $defaultModel : Text
	
	$provider:=ds.providerSettings.query("name = :1"; $providerList.currentValue).first()
	Case of 
		: ($kind="reasoning")
			$models:=$provider.reasoningModels.models
			$defaultModel:=$provider.defaults.reasoning
		: ($kind="embedding")
			$models:=$provider.embeddingModels.models
			$defaultModel:=$provider.defaults.embedding
	End case 
	$list.values:=$models.extract("model")
	$list.index:=$list.values.findIndex(Formula($1.value=$defaultModel))
	
	return $list
	
	