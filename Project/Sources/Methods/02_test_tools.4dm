//%attributes = {"invisible":true}
var $cases : Collection
$cases:=[]

If (True)
	//$cases.push({provider: "NVIDIA"; models: \
		["moonshotai/kimi-k2.5"/*;"qwen/qwen3-235b-a22b";"moonshotai/kimi-k2-instruct-0905";"meta/llama-3.1-8b-instruct";"meta/llama-3.1-70b-instruct";"meta/llama-3.1-405b-instruct"*/]})
	
	//$cases.push({provider: "DeepInfra"; models: \
		["Qwen/Qwen3-32B"/*;"Qwen/Qwen3-14B";"microsoft/phi-4";"deepseek-ai/DeepSeek-R1-0528";"moonshotai/Kimi-K2-Thinking"*/]})
	
	//$cases.push({provider: "FireWorks"; models: \
		["accounts/fireworks/models/kimi-k2p5"/*;"accounts/fireworks/models/kimi-k2-thinking";"accounts/fireworks/models/deepseek-r1-0528";"accounts/cogito/models/cogito-671b-v2-p1";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507"*/]})
	
	//$cases.push({provider: "ModelArk"; models: \
		["glm-4-7-251222"/*;"accounts/fireworks/models/kimi-k2-thinking";"accounts/fireworks/models/deepseek-r1-0528";"accounts/cogito/models/cogito-671b-v2-p1";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507"*/]})
	
	$cases.push({provider: "Gemini"; models: \
		["models/gemini-pro-latest"; "models/gemini-2.5-pro"; "models/gemini-3-pro-preview"]})
End if 

var $class : Text
If (Macintosh option down)
	$class:="RemoteLLM"
	$cases.push({provider: "LongCat"; \
		models: ["LongCat-Flash-Thinking-2601"]})
Else 
	$class:="LocalLLM"
	$cases.push({provider: "llama.cpp.chat.completions"; \
		models: ["Hammer2.1-1.5b"]})
End if 

var $OpenAITool : cs.AIKit.OpenAITool
$OpenAITool:=cs.AIKit.OpenAITool.new({\
type: "function"; \
function: {\
name: "get_current_weather"; \
description: "指定した都市の現在の天候を返します。"; \
parameters: {\
type: "object"; \
properties: {\
location: {type: "string"; description: "都道府県および都市の名前。例: 東京都渋谷区"}\
}; \
unit: {type: "string"; enum: ["摂氏"; "華氏"]}; \
required: ["location"]\
}}})

var $messages : Collection
$messages:=[]
$messages.push({role: "user"; content: "今日のシブヤのお天気はどんな感じ？"})

var $case : Object
var $name; $model; $key : Text

For each ($case; $cases)
	For each ($model; $case.models)
		$name:=$case.provider
		
		var $ChatCompletionsParameters : cs.AIKit.OpenAIChatCompletionsParameters
		$ChatCompletionsParameters:=cs.AIKit.OpenAIChatCompletionsParameters.new({model: $model})
		
		//parameters for tool calling
		$ChatCompletionsParameters.temperature:=0
		$ChatCompletionsParameters.tool_choice:="auto"
		$ChatCompletionsParameters.tools:=[$OpenAITool]
		
		$key:=cs.RemoteLLM.me.getAccessToken($name)
		var $OpenAI : cs.AIKit.OpenAI
		$OpenAI:=cs.AIKit.OpenAI.new($key)
		$OpenAI.baseURL:=cs[$class].me.endpoints[$name]
		
		var $ChatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult
		$ChatCompletionsResult:=$OpenAI.chat.completions.create($messages; $ChatCompletionsParameters)
		If ($ChatCompletionsResult.success)
			If ($ChatCompletionsResult.choice.finish_reason="tool_calls")
				var $reasoning_content : Text:=$ChatCompletionsResult.choice.message["reasoning_content"]
				var $tool_calls : Collection:=$ChatCompletionsResult.choice.message.tool_calls
				var $tool_call; $arguments : Object
				var $function : 4D.Function
				var $current_weather : Text
				For each ($tool_call; $tool_calls)
					$function:=Formula from string($tool_call.function.name)
					$arguments:=JSON Parse($tool_call.function.arguments)
					$current_weather:=$function.call($OpenAI; $arguments)
					
					//parameters for chat
					$ChatCompletionsParameters.temperature:=0.8
					$ChatCompletionsParameters.tool_choice:=Null
					$ChatCompletionsParameters.tools:=Null
					
					$messages:=[{role: "user"; content: "これをフランス語に翻訳して:\n"+$current_weather}]
					$ChatCompletionsResult:=$OpenAI.chat.completions.create($messages; $ChatCompletionsParameters)
					If ($ChatCompletionsResult.success)
						ALERT($ChatCompletionsResult.choice.message.content)
					End if 
				End for each 
			End if 
		End if 
	End for each 
End for each 