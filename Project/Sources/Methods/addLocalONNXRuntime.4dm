//%attributes = {"invisible":true}
var $p : cs.providerSettingsEntity
$p:=ds.providerSettings.new()

$p.name:="ONNX Runtime"
$p.url:="http://127.0.0.1:8080/v1"
$p.save()