property providersEmb : Object
property modelsEmb : Object
property providersGen : Object
property modelsGen : Object
property actions : Object
property AIText : Text
property window : Integer

Class constructor()
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	var $embeddingStatusOK : Boolean
	
	This.AIText:=""
	This.providersEmb:={values: []; index: 0}
	This.modelsEmb:={values: []; index: 0}
	This.providersGen:={values: []; index: 0}
	This.modelsGen:={values: []; index: 0}
	
	This.actions:={\
		embedding: {running: 0; progress: {value: 0; message: ""}; recomputeAll: False}; \
		generatingPeople: {running: 0; progress: {value: 0; message: ""}; quantity: 30; quantityBy: 10; specificRequest: ""}\
		}
	
	$embeddingStatusOK:=ds.embeddingInfo.embeddingStatus()
	If ($embeddingStatusOK)
		This.actions.embedding.status:="Done"
		This.actions.embedding.info:=ds.embeddingInfo.info()
	Else 
		This.actions.embedding.status:="Missing"
	End if 
	
	$providers:=ds.providerSettings.providersAvailable("embedding")
	If ($providers.length>0)
		This.providersEmb.values:=$providers.extract("name")
		
		//Set embedding provider to the last one successfully used, or select the first one
		$provider:=($embeddingStatusOK) ? $providers.query("name = :1"; This.actions.embedding.info.provider).first() : $providers.first()
		If ($provider=Null)
			$provider:=$providers.first()  //in case provider does not exist any more
		End if 
		This.providersEmb.index:=This.providersEmb.values.findIndex(Formula($1.value=$provider.name))
		
		//Set embedding model to the last one successfully used, or select the default one
		$models:=$provider.embeddingModels.models
		This.modelsEmb.values:=$models.extract("model")
		This.modelsEmb.index:=($embeddingStatusOK) ? This.modelsEmb.values.findIndex(Formula($1.value=ds.embeddingInfo.info().model)) : This.modelsEmb.values.findIndex(Formula($1.value=$provider.defaults.embedding))
		
	End if 
	
	$providers:=ds.providerSettings.providersAvailable("reasoning")
	If ($providers.length>0)
		This.providersGen.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.reasoningModels.models
		This.modelsGen.values:=$models.extract("model")
		This.modelsGen.index:=This.modelsGen.values.findIndex(Formula($1.value=$provider.defaults.reasoning))
	End if 
	
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			OBJECT SET VISIBLE(*; "peopleGen@"; False)
			OBJECT SET VISIBLE(*; "embedding@"; False)
	End case 
	
Function providersGenListEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This.modelsGen:=This.setModelList(This.providersGen; "reasoning")
	End case 
	
Function providersEmbListEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This.modelsEmb:=This.setModelList(This.providersEmb; "embedding")
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
			$recomputeAll:=This.actions.embedding.recomputeAll
			
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
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.terminateGeneratePeople()); *)
	Else 
		OBJECT SET VISIBLE(*; "peopleGen@"; False)
		OBJECT SET VISIBLE(*; "btnGeneratePeople"; True)
	End if 
	
Function progressGeneratePeople($input : Object)
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.progressGeneratePeople($1; $2)); *; $input)
	Else 
		
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
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.terminateVectorizing()); *)
	Else 
		OBJECT SET VISIBLE(*; "embedding@"; False)
		OBJECT SET VISIBLE(*; "btnVectorize"; True)
		
		If (ds.embeddingInfo.embeddingStatus())
			Form.actions.embedding.status:="Done"
			Form.actions.embedding.info:=ds.embeddingInfo.info()
		Else 
			Form.actions.embedding.status:="Missing"
		End if 
	End if 
	
Function progressVectorizing($progress : Object)
	If (Current form name="menu")
		EXECUTE METHOD IN SUBFORM("Subform"; Formula(Form.progressVectorizing($1)); *; $progress)
	Else 
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
			$defaultModel:=$provider.defaults.reasoning
		: ($kind="embedding")
			$models:=$provider.embeddingModels.models
			$defaultModel:=$provider.defaults.embedding
	End case 
	$list.values:=$models.extract("model")
	$list.index:=$list.values.findIndex(Formula($1.value=$defaultModel))
	
	return $list
	
	//MARK: -
	//MARK: Computed properties
	
Function get embeddingDateTime() : Text
	return String(This.actions.embedding.info.embeddingDate; "dd/MM/yyyy")+" "+String(Time(This.actions.embedding.info.embeddingTime); "HH:mm:ss")
	
	
	
	