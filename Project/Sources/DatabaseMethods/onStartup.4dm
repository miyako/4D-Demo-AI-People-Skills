//ds.providerSettings.updateProviderSettings()

var $ONNX : cs.ONNX.ONNX

var $homeFolder : 4D.Folder
$homeFolder:=Folder(fk home folder).folder(".ONNX")
var $file : 4D.File
var $URL : Text
var $port : Integer

var $event : cs.event.event
$event:=cs.event.event.new()

/*
Function onError($params : Object; $error : cs.event.error)
Function onSuccess($params : Object; $models : cs.event.models)
Function onData($request : 4D.HTTPRequest; $event : Object)
Function onResponse($request : 4D.HTTPRequest; $event : Object)
Function onTerminate($worker : 4D.SystemWorker; $params : Object)
*/

$event.onError:=Formula(ALERT($2.message))
$event.onSuccess:=Formula(ALERT($2.models.extract("name").join(",")+" loaded!"))
$event.onData:=Formula(LOG EVENT(Into 4D debug message; This.file.fullName+":"+String((This.range.end/This.range.length)*100; "###.00%")))
$event.onResponse:=Formula(LOG EVENT(Into 4D debug message; This.file.fullName+":download complete"))
$event.onTerminate:=Formula(LOG EVENT(Into 4D debug message; (["process"; $1.pid; "terminated!"].join(" "))))

$port:=8080

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
		$folder:=$homeFolder.folder("multilingual-e5-base-onnx")
		$path:="keisuke-miyako/multilingual-e5-base-onnx"
		$URL:="keisuke-miyako/multilingual-e5-base-onnx"
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

00_Start