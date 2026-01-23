//%attributes = {"invisible":true}
cs.RemoteLLM.new().use("xAI")

var $p : Object
Case of 
	: (True)
		$p:=ds.providerSettings.query("name == :1"; "xAI").first()
		$p.defaults.reasoning:="grok-4-1-fast-reasoning"
	: (False)  //DeepInfra
		$p:=ds.providerSettings.query("name == :1"; "DeepInfra").first()
		$p.modelsToRemove:={values: ["sao10k@"; "shibing@"; "anthropic@"; "nvidia@"; "google@"; "bytedance@"; "stability@"; "@image@"; "@bria@"; "@ocr@"; "@qwen3-235b-a22b"; "@deepseek-v3@"; "@instruct@"; "@coder@"; "@8b@"; "@30b@"; "@llama@"; "@glm@"; "@minimax@"; "@gpt@"; "@flux@"; "@-vl-@"]}
		$p.defaults.reasoning:="microsoft/phi-4"
		$p.defaults.embedding:="intflat/multilingual-e5-large"
	: (False)
		$p:=ds.providerSettings.query("name == :1"; "Groq").first()
		$p.modelsToRemove:={values: ["@whisper@"]}
		//$p.defaults.reasoning:="kimi-k2-thinking"
	: (False)  //FireWorks
		$p.modelsToRemove:={values: ["@qwen3-235b-a22b"; "@deepseek-v3@"; "@instruct@"; "@coder@"; "@8b@"; "@30b@"; "@llama@"; "@glm@"; "@minimax@"; "@gpt@"; "@flux@"; "@-vl-@"]}
		$p.defaults.reasoning:="accounts/fireworks/models/qwen3-235b-a22b-thinking-2507"
	: (False)  //Azure
		$p:=ds.providerSettings.query("name == :1"; "Azure").first()
		$p.modelsToKeep:={values: ["DeepSeek-@"; "Kimi-@"; "Llama-4-@"; "Llama-3.3-70B@"; "Meta-Llama-3.1-405B-@"; "Qwen@"; "Phi-@"; "text-@"]}
		$p.modelsToRemove:={values: ["Llama-3.3-70B-Instruct-@"; "Qwen3@"; "Phi-4-2"; "Phi-4-3"; "Phi-4-4"; "Phi-4-5"; "Phi-4-6"; "Phi-4-7"; "Phi-3@"; \
			"@vision@"; "mistral-@"; "o1-@"; "o3-@"; "o4-@"; "sora@"; "jais-@"; "model-router@"; "Stable-@"; "grok-@"; "Ministral-@"; "MAI-@"; "FLUX@"; "embed-@"; "computer-@"; "curie"; "codex-@"; "Codestral-@"; "code-@"; \
			"davinci"; "dall-e-@"; "cohere-@"; "claude-@"; "whisper@"; "gpt-@"; "claude-@"; "babbage"; "ada"; "AI21-@"; "aoai-@"]}
		$p.defaults.reasoning:="Phi-4-mini-reasoning"
		$p.defaults.embedding:="text-embedding-3-small"
End case 
$p.save()
ds.providerSettings.updateProviderSettings()