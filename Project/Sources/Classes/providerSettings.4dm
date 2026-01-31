Class extends DataClass

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
	var $key : Text
	
	$providers:=This.all()
	
	For each ($provider; $providers)
		$key:=cs.RemoteLLM.me.getAccessToken($provider.name)
		$AIClient:=cs.AIKit.OpenAI.new($key)
		$AIClient.baseURL:=($provider.url#"") ? $provider.url : $AIClient.baseURL
		$modelsList:=$AIClient.models.list()
		If ($modelsList.success)
			If ($provider.url="")
				cs.RemoteLLM.me.configure("OpenAI")
			Else 
				cs.RemoteLLM.me.configure($provider.name)
			End if 
			$provider.reload()
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
		
		If ($provider.defaults=Null) || ($key="")
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