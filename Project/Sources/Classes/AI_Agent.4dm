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
	This.AIClient:=cs.AIKit.OpenAI.new($provider.key#Null ? $provider.key : "")
	//This.AIClient.httpAgent:=4D.HTTPAgent.new()
	
	Case of 
		: ($providerName="Claude")
			This.AIClient.customHeaders:={}
			This.AIClient.customHeaders["x-api-key"]:=$provider.key
			This.AIClient.customHeaders["anthropic-version"]:="2023-06-01"
	End case 
	
	If ($provider.url#"")
		This.AIClient.baseURL:=$provider.url
	End if 
	