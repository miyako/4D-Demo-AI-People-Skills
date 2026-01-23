property providers : cs.providerSettingsSelection
property providersListBox : Object
property url_openAIModels : Text
property url_installOllama : Text
property url_ollamaModels : Text
property url_AIKitProviders : Text
property url_LMStudio : Text

property providersEmb : Object
property modelsEmb : Object
property providersGen : Object
property modelsGen : Object
property providersGen4 : Object
property modelsGen4 : Object

Class extends formMenu

Class constructor
	
	Super()
	
	This.providersListBox:={currentItem: Null; currentItemPos: 0; selectedItems: Null}
	This.url_openAIModels:="https://platform.openai.com/docs/models"
	This.url_installOllama:="https://www.ollama.com/download"
	This.url_ollamaModels:="https://www.ollama.com/search"
	This.url_AIKitProviders:="https://developer.4d.com/docs/aikit/compatible-openai"
	This.url_LMStudio:="https://lmstudio.ai/"
	
	//MARK: -
	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	
	If (This.menu.index=0)  //tab#1
		Case of 
			: ($formEventCode=On Load) || ($formEventCode=On Page Change)
				This.updateProvidersListBox()
		End case 
	End if 
	
Function updateProvidersListBox()
	
	This.providers:=ds.providerSettings.all()
	LISTBOX SELECT ROW(*; "ProvidersListBox"; 1)
	
Function btnRefreshProvidersEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Clicked)
			
			ds.providerSettings.updateProviderSettings()
			This.updateProvidersListBox()
			
			This.providersGen:={}
			This.modelsGen:={}
			This.providersEmb:={}
			This.modelsEmb:={}
			
			var $providers : cs.providerSettingsSelection
			
			$providers:=ds.providerSettings.query("hasReasoningModels == :1"; True).orderBy("name asc")
			This.setupModelsGen($providers; This.providersGen; This.modelsGen)
			
			$providers:=ds.providerSettings.query("hasEmbeddingModels == :1"; True).orderBy("name asc")
			This.setupModelsEmb($providers; This.providersEmb; This.modelsEmb)
			
			This.providersGen4:={}
			This.modelsGen4:={}
			
			$providers:=ds.providerSettings.query("hasReasoningModels == :1 and hasToolCalling  == :1"; True).orderBy("name asc")
			This.setupModelsGen($providers; This.providersGen4; This.modelsGen4)
			
	End case 
	
Function genericInputEventHandler($formEventCode : Integer)
	
	Case of 
		: ($formEventCode=On Data Change)
			This.providersListBox.currentItem.save()
	End case 