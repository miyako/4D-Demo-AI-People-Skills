Class extends DataClass

Function resolve($item : Object) : Object
	
	return OB Class($item).new($item.platformPath; fk platform path)
	
Function getAccessToken($provider : Text) : Text
	
	var $file : 4D.File
	$file:=This.resolve(Folder("/PROJECT/")).parent.file($provider+".token")
	
	If ($file.exists)
		return $file.getText()
	End if 
	
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
	
	$providers:=This.all()
	
	For each ($provider; $providers)
		$provider.key:=This.getAccessToken($provider.name)
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
			If ($provider.modelsToKeep=Null) || ($provider.modelsToKeep.values.length=0)
				$modelsToKeep:=["@"]
			Else 
				$modelsToKeep:=$provider.modelsToKeep.values.copy()
			End if 
			
			If ($provider.modelsToRemove=Null)
				$modelsToRemove:=[]
			Else 
				$modelsToRemove:=$provider.modelsToRemove.values.copy()
			End if 
			
			$models:=$models.query("model in :1 and not (model in :2)"; $modelsToKeep; $modelsToRemove)
			$models:=$models.orderBy("model asc").distinct()
			$provider.models:={values: $models}
		Else 
			$provider.models:={values: []}
		End if 
		
		If ($provider.defaults=Null) || ($provider.key="")
			$provider.defaults:={embedding: Null; reasoning: Null}
		End if 
		
		If ($provider.models.values.length>0) && ($provider.defaults.embedding=Null)
			If ($provider.models.values.query("model = :1"; $provider.defaults.embedding).length=0)
				$defaultModel:=$provider.models.values.query("model in :1"; ["@embed@"; "@-onnx"; "@-ct2-@"]).first()
				$provider.defaults.embedding:=($defaultModel#Null) ? $defaultModel.model : "No embedding model detected"
			End if 
			
			If ($provider.models.values.query("model = :1"; $provider.defaults.reasoning).length=0) && ($provider.defaults.reasoning=Null)
				$defaultModel:=$provider.models.values.query("not(model in :1)"; ["@embed@"; "@-onnx"; "@-ct2-@"]).first()
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
			return This.query("hasReasoningModels = true")
		Else 
			return This.query("hasModels = true")
	End case 
	
	