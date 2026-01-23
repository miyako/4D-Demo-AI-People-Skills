property file : 4D.File
property range : Object

Class constructor
	
Function use($name : Text; $port : Integer)
	
	Case of 
		: ($name="llama.cpp")
			This.useLlamaCpp("chat.completions"; $name; $port)
			This.useLlamaCpp("embeddings"; $name; $port+1)
		: ($name="ONNX Runtime")
			This.useONNX($name; $port)
		: ($name="CTranslate2")
			This.useCTranslate2($name; $port)
		: ($name="swama")
			This.useSwama($name; $port)
	End case 
	
Function useLlamaCpp($mode : Text; $name : Text; $port : Integer)
	
	var $llama : cs.llama.llama
	
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".GGUF")
	
	var $event : cs.event.event
	$event:=cs.event.event.new()
	$event.onError:=This.onError
	$event.onSuccess:=This.onSuccess
	$event.onData:=This.onData
	$event.onResponse:=This.onResponse
	$event.onTerminate:=This.onTerminate
	
	var $options : Object
	var $huggingfaces : cs.event.huggingfaces
	var $folder : 4D.Folder
	var $path : Text
	var $URL : Text
	
	Case of 
		: ($mode="embeddings")
			$folder:=$homeFolder.folder("jina-embeddings-v4-text-matching-Q4_K_M")  //where to keep the repo
			$path:="jina-embeddings-v4-text-matching-Q4_K_M.gguf"  //path to the file
			$URL:="jinaai/jina-embeddings-v4-text-matching-GGUF"  //path to the repo
			$options:={\
				embeddings: True; \
				pooling: "mean"; \
				threads: 4; \
				threads_batch: 4; \
				threads_http: 4; \
				log_disable: True; \
				n_gpu_layers: -1}
		: ($mode="chat.completions")
			Case of 
				: (False)
					$folder:=$homeFolder.folder("DeepSeek-R1-Distill-Qwen-7B-Q4_K_M")  //where to keep the repo
					$path:="DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/DeepSeek-R1-Distill-Qwen-7B-gguf-q4_k_m"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("DeepSeek-R1-0528-Qwen3-8B-Q4_K_M")  //where to keep the repo
					$path:="DeepSeek-R1-0528-Qwen3-8B-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/DeepSeek-R1-0528-Qwen3-8B-gguf-q4_k_m"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("Llama-3.2-3B-Instruct-Q4_K_M")  //where to keep the repo
					$path:="Llama-3.2-3B-Instruct-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/Llama-3.2-3B-Instruct-gguf-q4_k_m"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("gemma-3-270m-it-Q8_0")  //where to keep the repo
					$path:="gemma-3-270m-it-Q8_0.gguf"  //path to the file
					$URL:="keisuke-miyako/gemma-3-270m-it-gguf-q8_0"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("Qwen3-0.6B-Q8_0")  //where to keep the repo
					$path:="Qwen3-0.6B-Q8_0.gguf"  //path to the file
					$URL:="keisuke-miyako/Qwen3-0.6B-gguf-q8_0"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("Qwen3-1.7B-Q8_0")  //where to keep the repo
					$path:="Qwen3-1.7B-Q8_0.gguf"  //path to the file
					$URL:="keisuke-miyako/Qwen3-1.7B-gguf-q8_0"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("Phi-4-mini-instruct-Q4_K_M")  //where to keep the repo
					$path:="Phi-4-mini-instruct-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/Phi-4-mini-instruct-gguf-q4k_m"
				: (False)
					$folder:=$homeFolder.folder("functiongemma-270m-it-Q4_K_M")  //where to keep the repo
					$path:="functiongemma-270m-it-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/functiongemma-270m-it-gguf-q4_k_m"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("Gemma-2-Llama-Swallow-2b-it-v0.1-Q4_K_M")  //where to keep the repo
					$path:="Gemma-2-Llama-Swallow-2b-it-v0.1-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/Gemma-2-Llama-Swallow-2b-it-v0.1-gguf-q4_k_m"  //path to the repo
				: (True)
					$folder:=$homeFolder.folder("Qwen3-4B-Thinking-2507-Q4_K_M")  //where to keep the repo
					$path:="Qwen3-4B-Thinking-2507-Q4_K_M.gguf"  //path to the file
					$URL:="keisuke-miyako/Qwen3-4B-Thinking-2507-gguf-q4k_m"  //path to the repo
				: (False)
					$folder:=$homeFolder.folder("qwen2.5-7b-instruct-q4_k_m")  //where to keep the repo
					$path:="qwen2.5-7b-instruct-q4_k_m-@-of-00002.gguf"  //path to the file
					$URL:="Qwen/Qwen2.5-7B-Instruct-GGUF"  //path to the repo
			End case 
			
			If ($options=Null)
				$options:={\
					ctx_size: 40000; \
					batch_size: 2048; \
					threads: 4; \
					n_predict: -1; \
					threads_batch: 4; \
					threads_http: 4; \
					temp: 1; \
					top_k: 64; \
					top_p: 0.95; \
					min_p: 0; \
					log_disable: True; \
					repeat_penalty: 1; \
					n_gpu_layers: -1; \
					jinja: True}
			End if 
			
	End case 
	
	var $huggingface : cs.event.huggingface
	$huggingface:=cs.event.huggingface.new($folder; $URL; $path)
	$huggingfaces:=cs.event.huggingfaces.new([$huggingface])
	
	$llama:=cs.llama.llama.new($port; $huggingfaces; $homeFolder; $options; $event)
	
	This.register($name+"."+$mode; $port)
	
Function useCTranslate2($name : Text; $port : Integer)
	
	var $CTranslate2 : cs.CTranslate2.CTranslate2
	
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".CTranslate2")
	
	var $event : cs.event.event
	$event:=cs.event.event.new()
	$event.onError:=This.onError
	$event.onSuccess:=This.onSuccess
	$event.onData:=This.onData
	$event.onResponse:=This.onResponse
	$event.onTerminate:=This.onTerminate
	
	var $options : Object
	var $huggingfaces : cs.event.huggingfaces
	var $folder : 4D.Folder
	var $path : Text
	var $URL : Text
	
	Case of 
		: (False)  //much slower than onnx
			$folder:=$homeFolder.folder("bge-m3-ct2-int8_float16")
			$path:="keisuke-miyako/bge-m3-ct2-int8_float16"
			$URL:="keisuke-miyako/bge-m3-ct2-int8_float16"
			$options:={pooling: "cls"}
		: (True)
			$folder:=$homeFolder.folder("multilingual-e5-base-ct2-int8_float16")
			$path:="keisuke-miyako/multilingual-e5-base-ct2-int8_float16"
			$URL:="keisuke-miyako/multilingual-e5-base-ct2-int8_float16"
			$options:={pooling: "mean"}
	End case 
	
	var $embeddings : cs.event.huggingface
	$embeddings:=cs.event.huggingface.new($folder; $URL; $path; "embedding")
	$huggingfaces:=cs.event.huggingfaces.new([$embeddings])
	
	$CTranslate2:=cs.CTranslate2.CTranslate2.new($port; $huggingfaces; $homeFolder; $options; $event)
	
	This.register($name; $port)
	
Function useSwama($name : Text; $port : Integer)
	
	var $swama : cs.swama.swama
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".MLX")
	
	var $event : cs.event.event
	$event:=cs.event.event.new()
	$event.onError:=This.onError
	$event.onSuccess:=This.onSuccess
	$event.onData:=This.onData
	$event.onResponse:=This.onResponse
	$event.onTerminate:=This.onTerminate
	
	var $options : Object
	$options:={host: "127.0.0.1"}
	var $huggingfaces : cs.event.huggingfaces
	
	$folder:=$homeFolder.folder("Qwen3-4B-Instruct-2507")
	$path:="keisuke-miyako/Qwen3-4B-Instruct-2507-mlx-4bit"
	$URL:="keisuke-miyako/Qwen3-4B-Instruct-2507-mlx-4bit"
	
	$chat:=cs.event.huggingface.new($folder; $URL; $path)
	$huggingfaces:=cs.event.huggingfaces.new([$chat])
	
	$swama:=cs.swama.swama.new($port; $huggingfaces; $homeFolder; $options; $event)
	
	This.register($name; $port)
	
Function useONNX($name : Text; $port : Integer)
	
	var $ONNX : cs.ONNX.ONNX
	var $homeFolder : 4D.Folder
	$homeFolder:=Folder(fk home folder).folder(".ONNX")
	
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
	var $URL; $pooling : Text
	
	Case of 
		: (True)
			$folder:=$homeFolder.folder("gemma-3-1b-it")
			$path:="keisuke-miyako/gemma-3-1b-it-onnx-int4-cpu"
			$URL:="keisuke-miyako/gemma-3-1b-it-onnx-int4-cpu"
		: (False)
			$folder:=$homeFolder.folder("Qwen2.5-3B-Instruct")
			$path:="keisuke-miyako/Qwen2.5-3B-Instruct-onnx-int4-cpu"
			$URL:="keisuke-miyako/Qwen2.5-3B-Instruct-onnx-int4-cpu"
		: (False)
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
			$folder:=$homeFolder.folder("bge-m3-onnx")
			$path:="keisuke-miyako/bge-m3-onnx"
			$URL:="keisuke-miyako/bge-m3-onnx"
			$pooling:="cls"
		: (False)
			$folder:=$homeFolder.folder("amber-large-onnx")
			$path:="keisuke-miyako/amber-large-onnx"
			$URL:="keisuke-miyako/amber-large-onnx"
			$pooling:="mean"
		: (False)
			$folder:=$homeFolder.folder("multilingual-e5-base-onnx")
			$path:="keisuke-miyako/multilingual-e5-base-onnx"
			$URL:="keisuke-miyako/multilingual-e5-base-onnx"
			$pooling:="mean"
		: (False)
			$folder:=$homeFolder.folder("sarashina-embedding-v2-1b-onnx")
			$path:="keisuke-miyako/sarashina-embedding-v2-1b-onnx"
			$URL:="keisuke-miyako/sarashina-embedding-v2-1b-onnx"
			$pooling:="mean"
		: (False)
			$folder:=$homeFolder.folder("ruri-v3-310m-onnx")
			$path:="keisuke-miyako/ruri-v3-310m-onnx"
			$URL:="keisuke-miyako/ruri-v3-310m-onnx"
			$pooling:="mean"
	End case 
	
	var $embeddings : cs.event.huggingface
	$embeddings:=cs.event.huggingface.new($folder; $URL; $path; "embedding"; "model_quantized.onnx")
	$huggingfaces:=cs.event.huggingfaces.new([$chat; $embeddings])
	
	$options:={chat_template: $chat_template; pooling: $pooling}
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
	//ALERT($models.models.extract("name").join(",")+" loaded!")
	
Function onData($request : 4D.HTTPRequest; $event : Object)
	LOG EVENT(Into 4D debug message; This.file.fullName+":"+String((This.range.end/This.range.length)*100; "###.00%"))
	
Function onResponse($request : 4D.HTTPRequest; $event : Object)
	LOG EVENT(Into 4D debug message; This.file.fullName+":download complete")
	
Function onTerminate($worker : 4D.SystemWorker; $params : Object)
	LOG EVENT(Into 4D debug message; (["process"; $1.pid; "terminated!"].join(" ")))
	