property menu : Object
property actions : Object

Class extends form

Class constructor()
	
	Super()
	
	This.menu:={}
	This.menu.values:=["Intro"; "Data Gen & Embeddings 🪄"; "Semantic search"; "Question me with tools 🪄"]
	This.menu.index:=0
	
	This.actions:={}
	
Function tabMenuEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			Case of 
				: (This.menu.currentValue="Intro")
					FORM GOTO PAGE(1)
				: (This.menu.currentValue="Data Gen & Embeddings 🪄")
					FORM GOTO PAGE(2)
				: (This.menu.currentValue="Question me with tools 🪄")
					FORM GOTO PAGE(4)
				: (This.menu.currentValue="Semantic search")
					FORM GOTO PAGE(3)
			End case 
	End case 
	
Function setActions($actions : Object)
	
	var $action : Text
	For each ($action; $actions)
		This.actions[$action]:=$actions[$action]
	End for each 
	
Function setupModelsGen($providers : cs.providerSettingsSelection; $providersGen : Object; $modelsGen : Object)
	
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	$providersGen.values:=[]
	$providersGen.index:=0
	$modelsGen.values:=[]
	$modelsGen.index:=0
	
	If ($providers.length>0)
		$providersGen.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.reasoningModels.models
		$modelsGen.values:=$models.extract("model").orderBy()
		$modelsGen.index:=$modelsGen.values.findIndex(Formula($1.value=$provider.defaults.reasoning))
	End if 
	
Function setupModelsEmb($providers : cs.providerSettingsSelection; $providersEmb : Object; $modelsEmb : Object)
	
	var $provider : cs.providerSettingsEntity
	var $models : Collection
	
	$providersEmb.values:=[]
	$providersEmb.index:=0
	$modelsEmb.values:=[]
	$modelsEmb.index:=0
	
	If ($providers.length>0)
		$providersEmb.values:=$providers.extract("name")
		$provider:=$providers.first()
		$models:=$provider.embeddingModels.models
		$modelsEmb.values:=$models.extract("model").orderBy()
		$modelsEmb.index:=$modelsEmb.values.findIndex(Formula($1.value=$provider.defaults.embedding))
	End if 