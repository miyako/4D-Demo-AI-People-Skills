property model : Text
property provider : Text
property AIClient : cs.AIKit.OpenAI

Class constructor()
	
	This.model:=""
	This.provider:=""
	
Function setAgent($providerName : Text; $model : Text; $reset : Boolean)
	
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	
	$provider:=ds.providerSettings.query("name = :1"; $providerName).first()
	
	If ($provider=Null)
		throw(999; "Provider is not set in settings")
		return 
	End if 
	
	This.provider:=$providerName
	This.model:=$model
	
	var $key : Text
	$key:=cs.RemoteLLM.me.getAccessToken($provider.name)
	This.AIClient:=cs.AIKit.OpenAI.new($key#Null ? $key : "")
	
	Case of 
		: ($providerName="Claude")
			This.AIClient.customHeaders:={}
			This.AIClient.customHeaders["x-api-key"]:=$key
			This.AIClient.customHeaders["anthropic-version"]:="2023-06-01"
	End case 
	
	If ($provider.url#"")
		This.AIClient.baseURL:=$provider.url
	End if 
	
Function body() : Object
	//%W-550.26
	return {\
		top_k: This.top_k; \
		top_p: This.top_p; \
		max_tokens: This.max_tokens; \
		repetition_penalty: This.repetition_penalty; \
		temperature: This.temperature; \
		n: This.n; \
		response_format: This.response_format; \
		stream: This.stream}
	//%W+550.26
	
Function body_cohere() : Object
	//%W-550.26
	return {\
		top_k: This.top_k; \
		top_p: This.top_p; \
		max_tokens: This.max_tokens; \
		repetition_penalty: This.repetition_penalty; \
		temperature: This.temperature; \
		response_format: This.response_format; \
		stream: This.stream}
	//%W+550.26