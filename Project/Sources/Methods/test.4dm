//%attributes = {"invisible":true}
//cs.RemoteLLM.new().use("Moonshot")

$p:=ds.providerSettings.query("name == :1"; "Moonshot").first()
Case of 
	: (True)
		$p.modelsToRemove:={values: ["@-vision-@"; "@-preview"]}
		$p.defaults.reasoning:="kimi-latest"
		//$p.defaults.embedding:=
	: (False)
		$p.modelsToKeep:={values: ["DeepSeek-@"; "Kimi-@"; "Llama-4-@"; "Llama-3.3-70B@"; "Meta-Llama-3.1-405B-@"; "Qwen@"; "Phi-@"; "text-@"]}
		$p.modelsToRemove:={values: ["Llama-3.3-70B-Instruct-@"; "Qwen3@"; "Phi-4-2"; "Phi-4-3"; "Phi-4-4"; "Phi-4-5"; "Phi-4-6"; "Phi-4-7"; "Phi-3@"; \
			"@vision@"; "mistral-@"; "o1-@"; "o3-@"; "o4-@"; "sora@"; "jais-@"; "model-router@"; "Stable-@"; "grok-@"; "Ministral-@"; "MAI-@"; "FLUX@"; "embed-@"; "computer-@"; "curie"; "codex-@"; "Codestral-@"; "code-@"; \
			"davinci"; "dall-e-@"; "cohere-@"; "claude-@"; "whisper@"; "gpt-@"; "claude-@"; "babbage"; "ada"; "AI21-@"; "aoai-@"]}
		$p.defaults.reasoning:="Phi-4-mini-instruct"
		$p.defaults.embedding:="text-embedding-3-small"
End case 
$p.save()
ds.providerSettings.updateProviderSettings()