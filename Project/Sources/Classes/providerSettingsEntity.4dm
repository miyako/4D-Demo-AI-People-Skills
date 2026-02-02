Class extends Entity

Function get keyHidden() : Text
	return ((This.key=Null) || (This.key="")) ? "" : "******"
	
Function set keyHidden($value : Text)
	If ($value#"******")
		This.key:=$value
	End if 
	
Function get embeddingModels() : Object
	var $models : Collection
	
	If (This.models=Null)
		return {models: []}
	End if 
	
	$models:=This.models.values.query("model in :1"; ["@e5@"; "@gte@"; "BAAI@"; "sentence-transformers@"; "text-@"; "@embed@"; "@bge@"; "all-minilm"; "paraphrase-multilingual"; "@-ct2-@"; "@-onnx"])
	return {models: $models}
	
Function set embeddingModels()
	
Function get hasEmbeddingModels() : Boolean
	return (This.embeddingModels.models.length>0)
	
Function get hasToolCalling() : Boolean
	return ["Groq"; "LongCat"; "NVIDIA"; "OpenAI"; "xAI"; "ModelArk"; "swama"; "ONNX Runtime"; "xAI"; "DeepInfra"; "Gemini"; "Azure"; "Moonshot"; "Claude"; "FireWorks"; "llama.cpp.chat.completions"].includes(This.name)
	
Function set hasEmbeddingModels()
	
Function get reasoningModels() : Object
	var $models : Collection
	
	If (This.models=Null)
		return {models: []}
	End if 
	
	$models:=This.models.values.query("not(model in :1)"; \
		["@e5@"; "@gte@"; "BAAI@"; "sentence-transformers@"; "text-@"; "@embed@"; "@bge@"; "all-minilm"; "paraphrase-multilingual"; "@-ct2-@"; "@-onnx"]).combine\
		(This.models.values.query("model in :1"; ["@reasoning@"; "@instruct@"; "@thinking@"])).distinct()
	return {models: $models}
	
Function set reasoningModels()
	
Function get hasReasoningModels() : Boolean
	return (This.reasoningModels.models.length>0)
	
Function set hasReasoningModels()
	
	
Function get allModels() : Object
	return {models: This.models.values}
	
Function set allModels()
	
Function get hasModels() : Boolean
	return (This.models.values.length>0)
	
Function set hasModels()
	
	