//%attributes = {"invisible":true}
var $cases : Collection
$cases:=[]

//$cases.push({provider: "NVIDIA"; models: \
["moonshotai/kimi-k2.5"/*;"qwen/qwen3-235b-a22b";"moonshotai/kimi-k2-instruct-0905";"meta/llama-3.1-8b-instruct";"meta/llama-3.1-70b-instruct";"meta/llama-3.1-405b-instruct"*/]})

//$cases.push({provider: "DeepInfra"; models: \
["Qwen/Qwen3-32B"/*;"Qwen/Qwen3-14B";"microsoft/phi-4";"deepseek-ai/DeepSeek-R1-0528";"moonshotai/Kimi-K2-Thinking"*/]})

//$cases.push({provider: "FireWorks"; models: \
["accounts/fireworks/models/kimi-k2p5"/*;"accounts/fireworks/models/kimi-k2-thinking";"accounts/fireworks/models/deepseek-r1-0528";"accounts/cogito/models/cogito-671b-v2-p1";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507"*/]})

$cases.push({provider: "ModelArk"; models: \
["glm-4-7-251222"/*;"accounts/fireworks/models/kimi-k2-thinking";"accounts/fireworks/models/deepseek-r1-0528";"accounts/cogito/models/cogito-671b-v2-p1";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507";"accounts/fireworks/models/qwen3-235b-a22b-thinking-2507"*/]})


var $OpenAITool : cs.AIKit.OpenAITool
$OpenAITool:=cs.AIKit.OpenAITool.new({\
type: "function"; \
function: {\
name: "get_current_weather"; \
description: "Get the current weather in a given location"; \
parameters: {\
type: "object"; \
properties: {\
location: {type: "string"; description: "The city and state, e.g. San Francisco, CA"}\
}; \
unit: {type: "string"; enum: ["celsius"; "fahrenheit"]}; \
required: ["location"]\
}}})

var $messages : Collection
$messages:=[]
$messages.push({role: "user"; content: "What is the weather like in Boston today?"})

var $case : Object
var $name; $model; $key : Text

For each ($case; $cases)
	For each ($model; $case.models)
		$name:=$case.provider
		
		var $ChatCompletionsParameters : cs.AIKit.OpenAIChatCompletionsParameters
		$ChatCompletionsParameters:=cs.AIKit.OpenAIChatCompletionsParameters.new({model: $model})
		$ChatCompletionsParameters.temperature:=0
		
		$ChatCompletionsParameters.tool_choice:="auto"
		$ChatCompletionsParameters.tools:=[$OpenAITool]
		
		$key:=cs.RemoteLLM.me.getAccessToken($name)
		var $OpenAI : cs.AIKit.OpenAI
		$OpenAI:=cs.AIKit.OpenAI.new($key)
		$OpenAI.baseURL:=cs.RemoteLLM.me.endpoints[$name]
		
		var $ChatCompletionsResult : cs.AIKit.OpenAIChatCompletionsResult
		$ChatCompletionsResult:=$OpenAI.chat.completions.create($messages; $ChatCompletionsParameters)
		If ($ChatCompletionsResult.success)
			ALERT(JSON Stringify($ChatCompletionsResult.choice.message.tool_calls; *))
		End if 
	End for each 
End for each 
