//ds.providerSettings.updateProviderSettings()

var $LocalLLM : cs.LocalLLM
$LocalLLM:=cs.LocalLLM.new()
$LocalLLM.use("ONNX Runtime"; 8080)
$LocalLLM.use("Ctranslate2"; 8081)

00_Start