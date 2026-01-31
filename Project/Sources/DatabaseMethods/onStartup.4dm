var $LocalLLM : cs.LocalLLM
$LocalLLM:=cs.LocalLLM.new()
//$LocalLLM.use("ONNX Runtime"; 8080)
//$LocalLLM.use("Ctranslate2"; 8081)
$LocalLLM.use("llama.cpp"; 8082)
//$LocalLLM.use("swama"; 8084)

00_Start