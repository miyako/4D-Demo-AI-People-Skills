property AIText : Text
property window : Integer

Class extends formIntro

Class constructor()
	
	Super()
	
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	var $embeddingStatusOK : Boolean
	
	This.AIText:=""
	
	This.providersGen:={}
	This.modelsGen:={}
	This.providersEmb:={}
	This.modelsEmb:={}
	
	This.setActions({\
		embedding: {running: 0; progress: {value: 0; message: ""}; recomputeAll: False}; \
		generatingPeople: {running: 0; progress: {value: 0; message: ""}; quantity: 9; quantityBy: 3; specificRequest: ""}\
		})
	
	$providers:=ds.providerSettings.query("hasReasoningModels == :1"; True).orderBy("name asc")
	This.setupModelsGen($providers; This.providersGen; This.modelsGen)
	
	$providers:=ds.providerSettings.query("hasEmbeddingModels == :1"; True).orderBy("name asc")
	This.setupModelsEmb($providers; This.providersEmb; This.modelsEmb)
	
	This.updateEmbeddingStatus()
	
Function updateEmbeddingStatus()
	
	If (ds.embeddingInfo.embeddingStatus())
		This.actions.embedding.status:="Done"
		This.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		This.actions.embedding.status:="Missing"
	End if 
	This.actions.embedding.running:=0
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	Super.formEventHandler($formEventCode)
	
	If (This.menu.currentValue="Data Gen & Embeddings 🪄")
		Case of 
			: ($formEventCode=On Load) || ($formEventCode=On Page Change)
				OBJECT SET VISIBLE(*; "peopleGen@"; False)
				OBJECT SET VISIBLE(*; "embedding@"; False)
				If (This.actions.embedding.running=1)
					OBJECT SET VISIBLE(*; "embedding@"; True)
					OBJECT SET VISIBLE(*; "btnVectorize"; False)
				End if 
				If (This.actions.generatingPeople.running=1)
					OBJECT SET VISIBLE(*; "peopleGen@"; True)
					OBJECT SET VISIBLE(*; "btnGeneratePeople"; False)
				End if 
		End case 
	End if 
	
Function providersGenListEventHandler($formEventCode : Integer) : Object
	
	Case of 
		: ($formEventCode=On Data Change)
			return This.setModelList(OBJECT Get value(FORM Event.objectName); "reasoning")
	End case 
	
Function providersEmbListEventHandler($formEventCode : Integer) : Object
	
	Case of 
		: ($formEventCode=On Data Change)
			return This.setModelList(This.providersEmb; "embedding")
	End case 
	
Function btnGeneratePeopleEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Clicked)
			If (This.modelsGen.currentValue="")
				ALERT("Please select a model first")
				return 
			End if 
			
			This.actions.generatingPeople.running:=1
			This.actions.generatingPeople.progress:={value: 0; message: "Generating people"}
			
			OBJECT SET VISIBLE(*; "peopleGen@"; True)
			OBJECT SET VISIBLE(*; "btnGeneratePeople"; False)
			
			Form.AIText:=""
			cs.AI_PeopleGenerator.me.setAgent(This.providersGen.currentValue; This.modelsGen.currentValue; True)
			cs.AI_PeopleGenerator.me.generatePeopleAsync(This.actions.generatingPeople.quantity; This.actions.generatingPeople.quantityBy; This.actions.generatingPeople.specificRequest; Form)
			
	End case 
	
Function btnVectorizeEventHandler($formEventCode : Integer)
	
	var $provider; $model : Text
	var $recomputeAll : Boolean
	
	Case of 
		: ($formEventCode=On Clicked)
			
			If (This.modelsEmb.currentValue="")
				ALERT("Please select a model first")
				return 
			End if 
			
			This.actions.embedding.running:=1
			This.actions.embedding.status:="In progress"
			This.actions.embedding.embeddingInfo:=ds.embeddingInfo.dummyInfo()
			This.actions.embedding.progress:={value: 0; message: "Generating embeddings"}
			
			OBJECT SET VISIBLE(*; "embedding@"; True)
			OBJECT SET VISIBLE(*; "btnVectorize"; False)
			
			Form.window:=Current form window
			
			$provider:=This.providersEmb.currentValue
			$model:=This.modelsEmb.currentValue
			$recomputeAll:=Bool(This.actions.embedding.recomputeAll)
			
			CALL WORKER(String(Session.id)+"-embedding"; Formula(cs.AI_PersonVectorizer.me.vectorizePeople($1; $2; $3; $4)); $provider; $model; $recomputeAll; Form)
			
	End case 
	
Function btnDropDataEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Clicked)
			ds.person.all().drop()
			ds.address.all().drop()
			ds.jobDetail.all().drop()
			ds.embeddingInfo.all().drop()
			ds.skill.all().drop()
			ds.skillCategory.all().drop()
			ds.personSkill.all().drop()
			This.actions.embedding:={running: 0; progress: {value: 0; message: ""}; status: "Missing"}
			cs.initData.me.importSkills()
	End case 
	
	//MARK: -
	//MARK: Form actions callback functions
	
Function terminateGeneratePeople()
	
	If (Form#Null)
		OBJECT SET VISIBLE(*; "peopleGen@"; False)
		OBJECT SET VISIBLE(*; "btnGeneratePeople"; True)
		Form.actions.generatingPeople.running:=0
	End if 
	
Function progressGeneratePeople($input : Object)
	
	If (Form#Null)
		If (Not(Undefined($input.AIText)))
			Form.AIText+=$input.AIText
			//scroll down
			HIGHLIGHT TEXT(*; "InputAIText"; Length(Form.AIText); Length(Form.AIText))
			GOTO OBJECT(*; "InputAIText")
		End if 
		
		If (Not(Undefined($input.progress)))
			Form.actions.generatingPeople.progress.message:=(Undefined($input.progress.message) ? Form.actions.generatingPeople.progress.message : $input.progress.message)
			Form.actions.generatingPeople.progress.value:=(Undefined($input.progress.value) ? Form.actions.generatingPeople.progress.value : $input.progress.value)
		End if 
	End if 
	
Function terminateVectorizing()
	
	If (Form#Null)
		OBJECT SET VISIBLE(*; "embedding@"; False)
		OBJECT SET VISIBLE(*; "btnVectorize"; True)
		Form.updateEmbeddingStatus()
	End if 
	
Function progressVectorizing($progress : Object)
	
	If (Form#Null)
		Form.actions.embedding.progress.value:=$progress.value
		Form.actions.embedding.progress.message:=$progress.message
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
			$defaultModel:=$provider.defaults.reasoning#"No reasoning model detected" ? $provider.defaults.reasoning : $models.first().model
		: ($kind="embedding")
			$models:=$provider.embeddingModels.models
			$defaultModel:=$provider.defaults.embedding#"No embedding model detected" ? $provider.defaults.embedding : $models.first().model
	End case 
	$list.values:=$models.extract("model").orderBy()
	$list.index:=$list.values.findIndex(Formula($1.value=$defaultModel))
	
	return $list
	
	//MARK: -
	//MARK: Computed properties
	
Function get embeddingDateTime() : Text
	
	return String(This.actions.embedding.info.embeddingDate; "yyyy-MM-dd")+" "+String(Time(This.actions.embedding.info.embeddingTime); "HH:mm:ss")