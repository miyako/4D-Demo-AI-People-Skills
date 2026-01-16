property file : 4D.File
property range : Object

Class constructor
	
Function use($name : Text; $port : Integer)
	
	Case of 
		: ($name="ONNX Runtime")
			This.useONNX($name; $port)
		: ($name="CTranslate2")
			This.useCTranslate2($name; $port)
	End case 
	
Function useCTranslate2($name : Text; $port : Integer)
	
	var $CTranslate2 : cs.CTranslate2.CTranslate2
	
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".CTranslate2")
	var $file : 4D.File
	var $URL : Text
	
	var $event : cs.event.event
	$event:=cs.event.event.new()
	$event.onError:=This.onError
	$event.onSuccess:=This.onSuccess
	$event.onData:=This.onData
	$event.onResponse:=This.onResponse
	$event.onTerminate:=This.onTerminate
	
	var $options : Object
	$options:={pooling: "cls"}
	var $huggingfaces : cs.event.huggingfaces
	
	var $folder : 4D.Folder
	$folder:=$homeFolder.folder("bge-m3-ct2-int8_float16")
	var $path : Text
	$path:="keisuke-miyako/bge-m3-ct2-int8_float16"
	$URL:="keisuke-miyako/bge-m3-ct2-int8_float16"
	var $embeddings : cs.event.huggingface
	$embeddings:=cs.event.huggingface.new($folder; $URL; $path; "embedding")
	$huggingfaces:=cs.event.huggingfaces.new([$embeddings])
	
	$CTranslate2:=cs.CTranslate2.CTranslate2.new($port; $huggingfaces; $homeFolder; $options; $event)
	
	This.register($name; $port)
	
Function useONNX($name : Text; $port : Integer)
	
	var $ONNX : cs.ONNX.ONNX
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".ONNX")
	var $file : 4D.File
	var $URL : Text
	
	var $event : cs.event.event
	$event:=cs.event.event.new()
	$event.onError:=This.onError
	$event.onSuccess:=This.onSuccess
	$event.onData:=This.onData
	$event.onResponse:=This.onResponse
	$event.onTerminate:=This.onTerminate
	
	var $options : Object
	$options:={}
	var $huggingfaces : cs.event.huggingfaces
	
	var $chat_template : Text
	var $folder : 4D.Folder
	var $path : Text
	
	Case of 
		: (True)
			$chat_template:="{% set loop_messages = messages %}{% for message in loop_messages %}{% set content = '<|start_header_id|>' + message['role'] + '<|end_header_id|>\n\n'+ message['content'] | trim + '<|eot_id|>' %}{% if loop.index0 == 0 %}{% set content = bos_token + cont"+"ent %}{% endif %}{{ content }}{% endfor %}{% if add_generation_prompt %}{{ '<|start_header_id|>assistant<|end_header_id|>\n\n' }}{% endif %}"
			$folder:=$homeFolder.folder("Llama-3-ELYZA-JP-8B-onnx-int4-cpu")
			$path:="keisuke-miyako/Llama-3-ELYZA-JP-8B-onnx-int4-cpu"
			$URL:="keisuke-miyako/Llama-3-ELYZA-JP-8B-onnx-int4-cpu"
		: (False)
			$chat_template:="{%- if messages[0]['role'] == 'system' -%}\n    {{- messages[0]['content'] + '\\n' -}}\n    {%- set loop_messages = messages[1:] -%}\n{%- else -%}\n    {{- 'A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful"+", detailed, and polite answers to the user\\'s questions.\\n' -}}\n    {%- set loop_messages = messages -%}\n{%- endif -%}\n\n{%- for message in loop_messages -%}\n    {%- if message['role'] == 'user' -%}\n        {{- 'USER: ' + message['content'] + '\\n' -}}\n"+"    {%- elif message['role'] == 'assistant' -%}\n        {{- 'ASSISTANT: ' + message['content'] + eos_token + '\\n' -}}\n    {%- endif -%}\n{%- endfor -%}\n\n{%- if add_generation_prompt -%}\n    {{- 'ASSISTANT:' -}} \n{%- endif -%}"
			$folder:=$homeFolder.folder("RakutenAI-7B-instruct-onnx-int4-cpu")
			$path:="keisuke-miyako/RakutenAI-7B-instruct-onnx-int4-cpu"
			$URL:="keisuke-miyako/RakutenAI-7B-instruct-onnx-int4-cpu"
	End case 
	
	var $chat : cs.event.huggingface
	$chat:=cs.event.huggingface.new($folder; $URL; $path; "chat.completion")
	$huggingfaces:=cs.event.huggingfaces.new([$chat])
	
	Case of 
		: (True)
			$folder:=$homeFolder.folder("amber-large-onnx")
			$path:="keisuke-miyako/amber-large-onnx"
			$URL:="keisuke-miyako/amber-large-onnx"
		: (False)
			$folder:=$homeFolder.folder("multilingual-e5-large-onnx")
			$path:="keisuke-miyako/multilingual-e5-large-onnx"
			$URL:="keisuke-miyako/multilingual-e5-large-onnx"
		: (False)
			$folder:=$homeFolder.folder("sarashina-embedding-v2-1b-onnx")
			$path:="keisuke-miyako/sarashina-embedding-v2-1b-onnx"
			$URL:="keisuke-miyako/sarashina-embedding-v2-1b-onnx"
		: (False)
			$folder:=$homeFolder.folder("ruri-v3-310m-onnx")
			$path:="keisuke-miyako/ruri-v3-310m-onnx"
			$URL:="keisuke-miyako/ruri-v3-310m-onnx"
	End case 
	
	var $embeddings : cs.event.huggingface
	$embeddings:=cs.event.huggingface.new($folder; $URL; $path; "embedding"; "model_quantized.onnx")
	$huggingfaces:=cs.event.huggingfaces.new([$chat; $embeddings])
	
	$options:={chat_template: $chat_template; pooling: "mean"}
	$ONNX:=cs.ONNX.ONNX.new($port; $huggingfaces; $homeFolder; $options; $event)
	
	This.register($name; $port)
	
Function register($name : Text; $port : Integer)
	
	var $providerSettings : cs.providerSettingsEntity
	$providerSettings:=ds.providerSettings.query("name == :1"; $name).first()
	
	If ($providerSettings=Null)
		$providerSettings:=ds.providerSettings.new()
	End if 
	
	$providerSettings.name:=$name
	$providerSettings.url:="http://127.0.0.1:"+String($port)+"/v1"
	$providerSettings.save()
	
Function onError($params : Object; $error : cs.event.error)
	ALERT($error.message)
	
Function onSuccess($params : Object; $models : cs.event.models)
	ALERT($models.models.extract("name").join(",")+" loaded!")
	
Function onData($request : 4D.HTTPRequest; $event : Object)
	LOG EVENT(Into 4D debug message; This.file.fullName+":"+String((This.range.end/This.range.length)*100; "###.00%"))
	
Function onResponse($request : 4D.HTTPRequest; $event : Object)
	LOG EVENT(Into 4D debug message; This.file.fullName+":download complete")
	
Function onTerminate($worker : 4D.SystemWorker; $params : Object)
	LOG EVENT(Into 4D debug message; (["process"; $1.pid; "terminated!"].join(" ")))
	