Class constructor
	
Function use($name : Text)
	
	var $baseURL : Text
	
	Case of 
		: ($name="Azure")  //💰 (⚠️models unavailable)
			$baseURL:="https://4d.openai.azure.com/openai/v1"
			This.register($name; $baseURL)
		: ($name="Claude")  //💰5
			$baseURL:="https://api.anthropic.com/v1"
			This.register($name; $baseURL)
		: ($name="Cohere")  //🆓 (⚠️models unavailable)
			$baseURL:="https://api.cohere.ai/compatibility/v1"
			This.register($name; $baseURL)
		: ($name="DeepInfra")  //💰5
			$baseURL:="https://api.deepinfra.com/v1/openai"
			This.register($name; $baseURL)
		: ($name="DeepSeek")  //💰insufficient balance
			$baseURL:="https://api.deepseek.com/v1"
			This.register($name; $baseURL)
		: ($name="FireWorks")  //🆓
			$baseURL:="https://api.fireworks.ai/inference/v1/"
			This.register($name; $baseURL)
		: ($name="Gemini")  //🆓
			$baseURL:="https://generativelanguage.googleapis.com/v1beta/openai"
			This.register($name; $baseURL)
		: ($name="Groq")  //🆓
			$baseURL:="https://api.groq.com/openai/v1/"
			This.register($name; $baseURL)
		: ($name="HuggingFace")  //🆓
			$baseURL:="https://router.huggingface.co/v1"
			This.register($name; $baseURL)
		: ($name="Mistral")  //⚠️free for experimentation and prototyping
			$baseURL:="https://api.mistral.ai/v1"
			This.register($name; $baseURL)
		: ($name="Moonshot")  //💰
			$baseURL:="https://api.moonshot.ai/v1"
			This.register($name; $baseURL)
		: ($name="NVIDIA")  //🆓
			$baseURL:="https://integrate.api.nvidia.com/v1"
			This.register($name; $baseURL)
		: ($name="OpenRouter")  //🆓
			$baseURL:="https://openrouter.ai/api/v1"
			This.register($name; $baseURL)
		: ($name="Perplexity")  //💰3 no "models" api
			$baseURL:="https://api.perplexity.ai"
			This.register($name; $baseURL)
		: ($name="xAI")  //💰5
			$baseURL:="https://api.x.ai/v1"
			This.register($name; $baseURL)
	End case 
	
Function register($name : Text; $baseURL : Text)
	
	var $providerSettings : cs.providerSettingsEntity
	$providerSettings:=ds.providerSettings.query("name == :1"; $name).first()
	
	If ($providerSettings=Null)
		$providerSettings:=ds.providerSettings.new()
	End if 
	
	$providerSettings.key:=This.getAccessToken($name)
	$providerSettings.name:=$name
	$providerSettings.url:=$baseURL
	$providerSettings.save()
	
Function resolve($item : Object) : Object
	
	return OB Class($item).new($item.platformPath; fk platform path)
	
Function getAccessToken($provider : Text) : Text
	
	var $file : 4D.File
	$file:=This.resolve(Folder("/PROJECT/")).parent.file($provider+".token")
	
	If ($file.exists)
		return $file.getText()
	End if 
	