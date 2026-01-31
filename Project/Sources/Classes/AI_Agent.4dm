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
	