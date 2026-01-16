//%attributes = {"invisible":true}
var $f : cs.providerSettingsEntity
$f:=ds.providerSettings.query("name == :1"; "Gemini").first()

$f.modelsToRemove:={values: ["@robotics@"; "@image@"; "@tts@"; "@audio@"; "models/nano-banana-@"; "models/imagen-@"; "models/lyria-@"; "models/veo-@"; "models/aqa"; "models/deep-research-@"]}
$f.defaults:={reasoning: "models/gemini-2.0-flash"; embedding: "models/gemini-embedding-001"}
$f.save()