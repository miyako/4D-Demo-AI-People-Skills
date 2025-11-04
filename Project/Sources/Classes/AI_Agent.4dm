property model : Text
property provider : Text
property AIClient : cs.AIKit.OpenAI


Class constructor()
	This.model:=""
	This.provider:=""
	
	
Function setAgent($providerName : Text; $model : Text; $reset : Boolean)
	var $provider : cs.providerSettingsEntity
	var $AIClient : cs.AIKit.OpenAI
	
	//Fixme: checkif provider still exists
	
	If ($reset || (This.provider#$providerName) || (This.model#$model))
		$provider:=ds.providerSettings.query("name = :1"; $providerName).first()
		
		If ($provider=Null)
			throw(999; "Provider is not set in settings")
			return 
		End if 
		
		This.provider:=$providerName
		This.model:=$model
		This.AIClient:=cs.AIKit.OpenAI.new($provider.key)
		If ($provider.url#"")
			This.AIClient.baseURL:=$provider.url
		End if 
	End if 
	
	