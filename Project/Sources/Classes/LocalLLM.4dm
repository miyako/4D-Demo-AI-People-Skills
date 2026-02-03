property endpoints : Object
property file : 4D.File
property range : Object

shared singleton Class constructor
	
	var $localLLMs : cs.providerSettingsSelection
	$localLLMs:=ds.providerSettings.query("url == :1"; "http://127.0.0.1:@")
	
	var $endpoints : Object
	$endpoints:={}
	For each ($localLLM; $localLLMs)
		$endpoints[$localLLM.name]:=$localLLM.url
	End for each 
	
	This.endpoints:=OB Copy($endpoints; ck shared)
	
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
			
			//$folder:=$homeFolder.folder("jina-embeddings-v4-text-matching")  //where to keep the repo
			//$path:="jina-embeddings-v4-text-matching-Q4_K_M.gguf"  //path to the file
			//$URL:="jinaai/jina-embeddings-v4-text-matching-GGUF"  //path to the repo
			
			//$folder:=$homeFolder.folder("sarashina-embedding-v2-1b")  //where to keep the repo
			//$path:="sarashina-embedding-v2-1b-Q4_K_M.gguf"  //path to the file
			//$URL:="keisuke-miyako/sarashina-embedding-v2-1b-gguf-q4_k_m"  //path to the repo
			
			//$folder:=$homeFolder.folder("granite-embedding-278m-multilingual")  //where to keep the repo
			//$path:="granite-embedding-278m-multilingual-Q4_k_m.gguf"  //path to the file
			//$URL:="keisuke-miyako/granite-embedding-278m-multilingual-gguf-q4_k_m"  //path to the repo
			
			//$folder:=$homeFolder.folder("multilingual-e5-base")  //where to keep the repo
			//$path:="multilingual-e5-base-Q4_k_m.gguf"  //path to the file
			//$URL:="keisuke-miyako/multilingual-e5-base-gguf-q4_k_m"  //path to the repo
			
			//$folder:=$homeFolder.folder("granite-embedding-107m-multilingual")  //where to keep the repo
			//$path:="granite-embedding-107m-multilingual-Q4_k_m.gguf"  //path to the file
			//$URL:="keisuke-miyako/granite-embedding-107m-multilingual-gguf-q4_k_m"  //path to the repo
			
			//$folder:=$homeFolder.folder("multilingual-e5-large")  //where to keep the repo
			//$path:="multilingual-e5-large-q4_k_m.gguf"  //path to the file
			//$URL:="keisuke-miyako/multilingual-e5-large-gguf-q4_k_m"  //path to the repo
			
			//$folder:=$homeFolder.folder("multilingual-e5-base")  //where to keep the repo
			//$path:="multilingual-e5-base-Q8_0.gguf"  //path to the file
			//$URL:="keisuke-miyako/multilingual-e5-base-gguf-q8_0"  //path to the repo
			
			$folder:=$homeFolder.folder("multilingual-e5-small")  //where to keep the repo
			$path:="multilingual-e5-small-Q8_0.gguf"  //path to the file
			$URL:="keisuke-miyako/multilingual-e5-small-gguf-q8_0"  //path to the repo
			
			//$folder:=$homeFolder.folder("bge-m3")  //where to keep the repo
			//$path:="bge-m3-Q4_k_m.gguf"  //path to the file
			//$URL:="keisuke-miyako/bge-m3-gguf-q4_k_m"  //path to the repo
			
			$options:={\
				embeddings: True; \
				pooling: "mean"; \
				threads: 4; \
				threads_batch: 4; \
				threads_http: 4; \
				log_disable: True; \
				n_gpu_layers: -1}
			
		: ($mode="chat.completions")
			
			$folder:=$homeFolder.folder("Qwen3-4B-Thinking-2507")  //where to keep the repo
			$path:="Qwen3-4B-Thinking-2507-Q4_K_M.gguf"  //path to the file
			$URL:="keisuke-miyako/Qwen3-4B-Thinking-2507-gguf-q4k_m"  //path to the repo
			
			$folder:=$homeFolder.folder("Hammer2.1-1.5b")  //where to keep the repo
			$path:="Hammer2.1-1.5b-Q8_0.gguf"  //path to the file
			$URL:="keisuke-miyako/Hammer2.1-1.5b-gguf-q8_0"  //path to the repo
			
			var $temperature; $min_p; $top_p; $top_k : Real
			var $ctx_size; $n_gpu_layers; $repeat_penalty : Integer
			var $flash_attn : Text
			
			$temperature:=0  // (default: 0.8)
			$ctx_size:=8192
			$min_p:=0.1  // (default: 0.1, 0.0 = disabled)
			$top_p:=1  //(default: 0.9, 1.0 = disabled)
			$top_k:=0  //top-k sampling (default: 40, 0 = disabled)
			$n_gpu_layers:=-1  //max. number of layers to store in VRAM (default: -1)
			$repeat_penalty:=1  //(default: 1.0 = disabled)
			$flash_attn:="on"
			
			$options:={\
				ctx_size: $ctx_size; \
				temp: $temperature; \
				top_k: $top_k; \
				top_p: $top_p; \
				min_p: $min_p; \
				log_disable: True; \
				repeat_penalty: $repeat_penalty; \
				n_gpu_layers: $n_gpu_layers; \
				flash_attn: $flash_attn; \
				jinja: True}
			
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
	
	//$folder:=$homeFolder.folder("multilingual-e5-base")
	//$path:="multilingual-e5-base-ct2-int8_float16"
	//$URL:="keisuke-miyako/multilingual-e5-base-ct2-int8_float16"
	//$options:={pooling: "mean"}
	
	$folder:=$homeFolder.folder("multilingual-e5-small")
	$path:="multilingual-e5-small-ct2-int8_float16"
	$URL:="keisuke-miyako/multilingual-e5-small-ct2-int8_float16"
	$options:={pooling: "mean"}
	
	//$folder:=$homeFolder.folder("granite-embedding-278m-multilingual")
	//$path:="granite-embedding-278m-multilingual-ct2-int8_float16"
	//$URL:="keisuke-miyako/granite-embedding-278m-multilingual-ct2-int8_float16"
	//$options:={pooling: "mean"}
	
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
	
	var $folder : 4D.Folder
	var $path : Text
	var $URL : Text
	
	$folder:=$homeFolder.folder("Qwen3-4B-Instruct-2507")
	$path:="keisuke-miyako/Qwen3-4B-Instruct-2507-mlx-4bit"
	$URL:="keisuke-miyako/Qwen3-4B-Instruct-2507-mlx-4bit"
	
	var $chat : cs.event.huggingface
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
	
	$LLMs:=[]
	
	var $chat_template : Text
	var $folder : 4D.Folder
	var $path : Text
	var $URL; $pooling : Text
	var $temperature; $min_p; $top_p; $top_k : Real
	var $ctx_size; $n_gpu_layers; $repeat_penalty : Integer
	var $flash_attn : Text
	var $options : Object
	$options:={}
	
	var $huggingfaces : cs.event.huggingfaces
	
	If (False)
		$folder:=$homeFolder.folder("Qwen2.5-3B-Instruct")
		$path:="keisuke-miyako/Qwen2.5-3B-Instruct-onnx-int4-cpu"
		$URL:="keisuke-miyako/Qwen2.5-3B-Instruct-onnx-int4-cpu"
		var $chat : cs.event.huggingface
		$chat:=cs.event.huggingface.new($folder; $URL; $path; "chat.completion")
		$LLMs.push($chat)
	End if 
	
	//$folder:=$homeFolder.folder("multilingual-e5-base")
	//$path:="multilingual-e5-base-onnx"
	//$URL:="keisuke-miyako/multilingual-e5-base-onnx"
	//$options.pooling:="mean"
	
	$folder:=$homeFolder.folder("multilingual-e5-small")
	$path:="multilingual-e5-small-onnx"
	$URL:="keisuke-miyako/multilingual-e5-small-onnx"
	$options.pooling:="mean"
	
	//$folder:=$homeFolder.folder("granite-embedding-278m-multilingual")
	//$path:="granite-embedding-278m-multilingual-onnx"
	//$URL:="keisuke-miyako/granite-embedding-278m-multilingual-onnx"
	//$options.pooling:="mean"
	
	var $embeddings : cs.event.huggingface
	$embeddings:=cs.event.huggingface.new($folder; $URL; $path; "embedding"; "model_quantized.onnx")
	$LLMs.push($embeddings)
	$huggingfaces:=cs.event.huggingfaces.new($LLMs)
	
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
	