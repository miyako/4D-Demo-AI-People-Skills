//%attributes = {}
//LM Studio:
//URL: http://127.0.0.1:1234/v1
//text-embedding-mxbai-embed-large-v1
//text-embedding-nomic-embed-text-v1.5


//Ollama:
//URL: http://localhost:11434/v1
//nomic-embed-text:latest

var $textToSearch : Text
var $AIClient : cs.AIKit.OpenAI  //no key needed if local model 
var $embeddingResult : cs.AIKit.OpenAIEmbeddingsResult
var $vector : 4D.Vector
var $vectorSearchObj : Object
var $persons : cs.personSelection
var $formula : 4D.Function
var $col : Collection:=[]
var $result : Object

TRACE

//1) capture a text from the user, use for semantic query in database
$textToSearch:="a manager or leader, expert in HR policies, living in France"

//2) instantiate an openAI API client
$AIClient:=cs.AIKit.OpenAI.new()
$AIClient.baseURL:="http://127.0.0.1:1234/v1"  //set the baseURL for local model (not needed if using openAI)

//3) get the embedding for the searched text
$embeddingResult:=$AIClient.embeddings.create($textToSearch; "text-embedding-mxbai-embed-large-v1")
$vector:=$embeddingResult.vector

//4) execute the semantic query
$vectorSearchObj:={vector: $vector; metric: "cosine"; threshold: 0.5}  //metric and threshold are optional
$persons:=ds.person.query("embedding > :1"; $vectorSearchObj)

//5) orderByFormula (orderBy in Orda query soon to come in 4D 21 R2)
$formula:=Formula(This.embedding.cosineSimilarity($vector))
$persons:=$persons.orderByFormula($formula; dk descending)

$col:=$persons.extract("fullname"; "1_who"; "jobDetail.jobTitle"; "2_job"; "address.country"; "3_where"; "jobDetail.billingRate"; "4_billingRate"; "personSkills.skill.name"; "5_skills")
TRACE

//Bonus: mix semantic and conventional queries with ORDA!
$persons:=ds.person.query("jobDetail.billingRate <= :1 and embedding > :2"; 1000; $vectorSearchObj)
$persons:=$persons.orderByFormula($formula; dk descending)
$col:=$persons.extract("fullname"; "1_who"; "jobDetail.jobTitle"; "2_job"; "address.country"; "3_where"; "jobDetail.billingRate"; "4_billingRate"; "personSkills.skill.name"; "5_skills")
TRACE

//Bottom line: easy to wrap it all in a small dataclass function and make it a tool
$result:=ds.person.personSearchByVector("someone who knows 4D development"; 10)
$persons:=$result.peopleFound
$col:=$persons.extract("fullname"; "1_who"; "jobDetail.jobTitle"; "2_job"; "address.country"; "3_where"; "jobDetail.billingRate"; "4_billingRate"; "personSkills.skill.name"; "5_skills")
TRACE

