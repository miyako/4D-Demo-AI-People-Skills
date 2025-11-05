Class extends DataClass


Function openProviderFile($path : Text) : Collection
	var $jsonText : Text
	
	$jsonText:=File($path).getText()
	return JSON Parse($jsonText; Is collection)
	
Function loadDefaults()
	var $providersFilePath:="/RESOURCES/AIProviders.json"
	var $jsonContent : Collection
	
	$jsonContent:=This.openProviderFile($providersFilePath)
	This.fromCollection($jsonContent)
	
Function updateProviderSettings()
	var $providers : cs.providerSettingsSelection
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	var $modelsList : cs.AIKit.OpenAIModelListResult
	var $f : 4D.Function
	var $models : Collection
	var $modelsToKeep : Collection
	var $modelsToRemove : Collection
	var $defaultModel : Object
	
	If (This.all().length=0)
		This.loadDefaults()
	End if 
	
	$providers:=This.all()
	
	For each ($provider; $providers)
		$AIClient:=cs.AIKit.OpenAI.new($provider.key)
		$AIClient.baseURL:=($provider.url#"") ? $provider.url : $AIClient.baseURL
		$modelsList:=$AIClient.models.list()
		If ($modelsList.success)
			If ($provider.url="")
/**
* In case OpenAI provider was removed and then added back
* Set back models to keep and remove
**/
				If (($provider.modelsToKeep=Null) || ($provider.modelsToKeep.values=Null) || ($provider.modelsToKeep.values.length=0))
					$provider.modelsToKeep:={values: ["gpt-@"; "text-embedding@"; "chatgpt-@"; "o1-@"; "o3-@"; "o4-@"; "computer-@"]}
				End if 
				If (($provider.modelsToRemove=Null) || ($provider.modelsToRemove.values=Null) || ($provider.modelsToRemove.values.length=0))
					$provider.modelsToRemove:={values: ["gpt-image@"; "@audio@"; "@transcribe@"; "@tts@"; "@search@"; "@realtime@"]}
				End if 
				
			End if 
			
			$f:=Formula(New object("model"; $1.value.id))
			$models:=$modelsList.models.map($f)
			$modelsToKeep:=($provider.modelsToKeep.values.length=0) ? ["@"] : $provider.modelsToKeep.values.copy()
			$modelsToRemove:=$provider.modelsToRemove.values.copy()
			$models:=$models.query("model in :1 and not (model in :2)"; $modelsToKeep; $modelsToRemove)
			$models:=$models.orderBy("model asc")
			$provider.models:={values: $models}
		Else 
			$provider.models:={values: []}
		End if 
		
		If ($provider.models.values.length>0)
			If ($provider.models.values.query("model = :1"; $provider.defaults.embedding).length=0)
				$defaultModel:=$provider.models.values.query("model = :1"; "@embed@").first()
				$provider.defaults.embedding:=($defaultModel#Null) ? $defaultModel.model : "No embedding model detected"
			End if 
			
			If ($provider.models.values.query("model = :1"; $provider.defaults.reasoning).length=0)
				$defaultModel:=$provider.models.values.query("model # :1"; "@embed@").first()
				$provider.defaults.reasoning:=($defaultModel#Null) ? $defaultModel.model : "No reasoning model detected"
			End if 
		End if 
		$provider.save()
		
	End for each 
	
	
Function add()
	var $newProvider : cs.providerSettingsEntity
	
	$newProvider:=ds.providerSettings.new()
	$newProvider.name:=""
	$newProvider.url:=""
	$newProvider.key:=""
	$newProvider.models:={values: []}
	$newProvider.modelsToKeep:={values: []}
	$newProvider.modelsToRemove:={values: []}
	$newProvider.defaults:={embedding: ""; reasoning: ""}
	$newProvider.save()
	
Function providersAvailable($kind : Text) : cs.providerSettingsSelection
	Case of 
		: ($kind="embedding")
			return This.query("hasEmbeddingModels = true")
		: ($kind="reasoning")
			return This.query("hasreasoningModels = true")
		Else 
			return This.query("hasModels = true")
	End case 
	
	
	
	
	
	