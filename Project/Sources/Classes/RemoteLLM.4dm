property endpoints : Object

shared singleton Class constructor
	
	This.endpoints:=OB Copy({\
		Azure: "https://4d.openai.azure.com/openai/v1"; \
		Claude: "https://api.anthropic.com/v1"; \
		Cohere: "https://api.cohere.ai/compatibility/v1"; \
		DeepInfra: "https://api.deepinfra.com/v1/openai"; \
		DeepSeek: "https://api.deepseek.com/v1"; \
		FireWorks: "https://api.fireworks.ai/inference/v1/"; \
		Gemini: "https://generativelanguage.googleapis.com/v1beta/openai"; \
		Groq: "https://api.groq.com/openai/v1/"; \
		HuggingFace: "https://router.huggingface.co/v1"; \
		LongCat: "https://api.longcat.chat/openai/v1/"; \
		ModelArk: "https://ark.ap-southeast.bytepluses.com/api/v3"; \
		Mistral: "https://api.mistral.ai/v1"; \
		Moonshot: "https://api.moonshot.ai/v1"; \
		NVIDIA: "https://integrate.api.nvidia.com/v1"; \
		OpenAI: ""; \
		OpenRouter: "https://openrouter.ai/api/v1"; \
		Perplexity: "https://api.perplexity.ai"; \
		xAI: "https://api.x.ai/v1"}; ck shared)
	
Function use($name : Text) : cs.RemoteLLM
	
	If (Not(OB Is defined(This.endpoints; $name)))
		return 
	End if 
	
	This._register($name)
	
	return This
	
Function _register($name : Text)
	
	var $baseURL : Text
	$baseURL:=This.endpoints[$name]
	
	var $providerSettings : cs.providerSettingsEntity
	$providerSettings:=ds.providerSettings.query("name == :1"; $name).first()
	
	If ($providerSettings=Null)
		$providerSettings:=ds.providerSettings.new()
	End if 
	
	$providerSettings.name:=$name
	$providerSettings.url:=$baseURL
	$providerSettings.save()
	
Function _resolvePath($item : Object) : Object
	
	return OB Class($item).new($item.platformPath; fk platform path)
	
Function getAccessToken($name : Text) : Text
	
	var $file : 4D.File
	$file:=This._resolvePath(Folder("/PROJECT/")).parent.folder("Secrets").file($name+".token")
	
	If ($file.exists)
		return $file.getText()
	End if 
	
Function getRule($name : Text) : Object
	
	var $file : 4D.File
	$file:=This._resolvePath(Folder("/PROJECT/")).parent.folder("Rules").file($name+".json")
	
	If (Not($file.exists))
		var $rule : Object
		$rule:={modelsToKeep: {values: []}; modelsToRemove: {values: []}; defaults: {reasoning: Null; embedding: Null}}
		$file.setText(JSON Stringify($rule; *))
		return $rule
	End if 
	
	return JSON Parse($file.getText(); Is object)
	
Function configure($name : Text)
	
	var $rule : Object
	$rule:=This.getRule($name)
	
	var $providerSettings : cs.providerSettingsEntity
	$providerSettings:=ds.providerSettings.query("name == :1"; $name).first()
	If ($providerSettings=Null)
		return 
	End if 
	
	var $property : Text
	For each ($property; $rule)
		$providerSettings[$property]:=$rule[$property]
	End for each 
	
	$providerSettings.save()