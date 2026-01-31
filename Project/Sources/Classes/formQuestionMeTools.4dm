property people : cs.personSelection
property selectedPerson : cs.personEntity
property webAreaInitialized : Boolean
property promptFilePath : Object

Class extends formSemanticSearch

Class constructor()
	
	Super()
	
	This.promptFilePath:={en: "Prompts/en.txt"; ja: "Prompts/ja.txt"}
	
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	cs.AI_QuestionningTools.me.resetContext()
	
	This.webAreaInitialized:=False
	
	This.providersGen4:={}
	This.modelsGen4:={}
	
	$providers:=ds.providerSettings.query("hasReasoningModels == :1 and hasToolCalling  == :1"; True).orderBy("name asc")
	This.setupModelsGen($providers; This.providersGen4; This.modelsGen4)
	
	This.setActions({\
		questionning: {running: 0; progress: {message: ""}; timingResult: ""; prompt: ""}\
		})
	
	This.actions.questionning.prompt:=This.getText(This.promptFilePath[Macintosh command down ? "en" : "ja"])
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	Super.formEventHandler($formEventCode)
	
	Case of 
		: ($formEventCode=On Double Clicked)
			
			Case of 
				: (FORM Event.objectName="Input17")
					This.actions.questionning.prompt:=This.getText(This.promptFilePath[Macintosh command down ? "en" : "ja"])
					OBJECT SET ENABLED(*; "btnAskMe"; True)
			End case 
			
		: ($formEventCode=On After Edit)
			
			Case of 
				: (FORM Event.objectName="Input17")
					OBJECT SET ENABLED(*; "btnAskMe"; Get edited text#"")
			End case 
			
		: ($formEventCode=On Load) || ($formEventCode=On Page Change)
			OBJECT SET VISIBLE(*; "questionning@"; False)
			OBJECT SET VISIBLE(*; "timingResult"; False)
			If (This.actions.questionning.running=1)
				OBJECT SET VISIBLE(*; "questionning@"; True)
				OBJECT SET VISIBLE(*; "btnAskMe"; False)
				OBJECT SET VISIBLE(*; "btnNewChat"; False)
				OBJECT SET VISIBLE(*; "select@"; False)
				OBJECT SET VISIBLE(*; "timingResult"; False)
			Else 
				OBJECT SET VISIBLE(*; "questionning@"; False)
				OBJECT SET VISIBLE(*; "btnAskMe"; True)
				OBJECT SET VISIBLE(*; "btnNewChat"; True)
				OBJECT SET VISIBLE(*; "select@"; True)
				OBJECT SET VISIBLE(*; "timingResult"; True)
			End if 
			OBJECT SET ENABLED(*; "btnAskMe"; OBJECT Get value("Input17")#"")
	End case 
	
Function btnNewChatEventHandler($formEventCode : Integer)
	
	cs.AI_QuestionningTools.me.resetContext()
	This.people:=Null
	This.webAreaInitialized:=False
	var $templateFilename : Text
	var $templatePath : Text
	$templateFilename:=cs.ChatHTMLRenderer.me.getInitialHTML()
	$templatePath:=Get 4D folder(Current resources folder)+$templateFilename
	WA OPEN URL(*; "Web Area"; $templatePath)
	
	Form.setActions({\
		questionning: {running: 0; progress: {message: ""}; timingResult: ""; prompt: ""}\
		})
	
	OBJECT SET ENABLED(*; "btnAskMe"; False)
	
Function btnAskMeEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Clicked)
			
			If (This.modelsGen4.currentValue="")
				ALERT("Please select a model first")
				return 
			End if 
			
			This.actions.questionning.running:=1
			This.actions.questionning.timing:=0
			
			Form.people:=Null
			OBJECT SET VISIBLE(*; "questionning@"; True)
			OBJECT SET VISIBLE(*; "btnAskMe"; False)
			OBJECT SET VISIBLE(*; "btnNewChat"; False)
			OBJECT SET VISIBLE(*; "select@"; False)
			OBJECT SET VISIBLE(*; "timingResult"; False)
			
			cs.AI_QuestionningTools.me.setAgent(This.providersGen4.currentValue; This.modelsGen4.currentValue)
			cs.AI_QuestionningTools.me.askMe(Form.actions.questionning.prompt; Form)
			This.actions.questionning.prompt:=""
			OBJECT SET ENABLED(*; "btnAskMe"; False)
			
	End case 
	
Function lbPeopleListboxEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Selection Change)
			If (This.selectedPerson#Null)
				OBJECT SET VISIBLE(*; "answerArea_title3"; True)
			Else 
				OBJECT SET VISIBLE(*; "answerArea_title3"; False)
			End if 
	End case 
	
Function get address() : Text
	
	Case of 
		: (Form.selectedPerson=Null)
			return 
		: (Form.selectedPerson.address=Null)
			return 
	End case 
	
	Form.selectedPerson.address.formatted()
	
Function get billingRate() : Text
	
	Case of 
		: (Form.selectedPerson=Null)
			return 
		: (Form.selectedPerson.jobDetail=Null)
			return 
	End case 
	
	return String(Form.selectedPerson.jobDetail.billingRate)  //+" USD"
	
Function resolve($item : Object) : Object
	
	return OB Class($item).new($item.platformPath; fk platform path)
	
Function getText($name : Text) : Text
	
	var $file : 4D.File
	$file:=This.resolve(Folder("/PROJECT/")).parent.file($name)
	
	If ($file.exists)
		return $file.getText()
	End if 
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateQuestionning($timing : Integer; $peopleFound : cs.personSelection)
	
	If (Form#Null)
		Form.actions.questionning.timingResult:="Answer given in "+String($timing)+" ms"
		Form.people:=$peopleFound
		OBJECT SET VISIBLE(*; "questionning@"; False)
		OBJECT SET VISIBLE(*; "btnAskMe"; True)
		OBJECT SET VISIBLE(*; "btnNewChat"; True)
		OBJECT SET VISIBLE(*; "select@"; True)
		OBJECT SET VISIBLE(*; "timingResult"; True)
		This.actions.questionning.running:=0
	End if 
	
Function progressQuestionning($input : Object)
	
	If (Form#Null)
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