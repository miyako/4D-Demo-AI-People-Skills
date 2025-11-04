property providers : cs.providerSettingsSelection
property providersListBox : Object
property url_openAIModels : Text
property url_installOllama : Text
property url_ollamaModels : Text
property url_AIKitProviders : Text
property url_LMStudio : Text


Class constructor
	This.providers:=ds.providerSettings.all()
	This.providersListBox:={}
	This.url_openAIModels:="https://platform.openai.com/docs/models"
	This.url_installOllama:="https://www.ollama.com/download"
	This.url_ollamaModels:="https://www.ollama.com/search"
	This.url_AIKitProviders:="https://developer.4d.com/docs/aikit/compatible-openai"
	This.url_LMStudio:="https://lmstudio.ai/"
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			LISTBOX SELECT ROW(*; "ProvidersListBox"; 1)
	End case 
	
Function btnAddProviderEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			ds.providerSettings.add()
			This.providers:=ds.providerSettings.all()
			LISTBOX SELECT ROW(*; "ProvidersListBox"; Form.providers.length)
	End case 
	
Function btnDeleteProviderEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			If (This.providersListBox.currentItem#Null)
				This.providersListBox.currentItem.drop()
				This.providers:=ds.providerSettings.all()
				LISTBOX SELECT ROW(*; "ProvidersListBox"; 1)
			End if 
	End case 
	
Function btnRefreshProvidersEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Clicked)
			ds.providerSettings.updateProviderSettings()
			Form.providers:=ds.providerSettings.all()
	End case 
	
Function genericInputEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Data Change)
			This.providersListBox.currentItem.save()
	End case 