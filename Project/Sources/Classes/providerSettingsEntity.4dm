Class extends Entity

Function get keyHidden() : Text
	return (This.key="") ? "" : "******"
	
Function set keyHidden($value : Text)
	If ($value#"******")
		This.key:=$value
	End if 
	
	
	
Function get embeddingModels() : Object
	var $models : Collection
	
	$models:=This.models.values.query("model in :1"; ["@embed@"; "@bge@"; "all-minilm"; "paraphrase-multilingual"])
	return {models: $models}
	
Function set embeddingModels()
	
Function get hasEmbeddingModels() : Boolean
	return (This.embeddingModels.models.length>0)
	
Function set hasEmbeddingModels()
	
	
	
Function get reasoningModels() : Object
	var $models : Collection
	
	$models:=This.models.values.query("not(model in :1)"; ["@embed@"; "@bge@"; "all-minilm"; "paraphrase-multilingual"])
	//$models:=This.models.values.minus(This.embeddingModels.values)
	return {models: $models}
	
Function set reasoningModels()
	
Function get hasreasoningModels() : Boolean
	return (This.reasoningModels.models.length>0)
	
Function set hasreasoningModels()
	
	
Function get allModels() : Object
	return {models: This.models.values}
	
Function set allModels()
	
Function get hasModels() : Boolean
	return (This.models.values.length>0)
	
Function set hasModels()
	
	