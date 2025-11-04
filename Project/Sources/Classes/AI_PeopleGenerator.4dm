property systemPrompt : Text
property peopleGenBot : cs.AIKit.OpenAIChatHelper
property formObject : Object
property generated : Integer
property alreadyThere : Integer
property quantityBy : Integer
property quantity : Integer
property failedAttempts : Integer
property maxFailedAttempts : Integer
property startMillisecond : Integer
property timing : Integer
property progress : Object
property personArraySchema : Object
property personArraySchema_fixDate : Object
property specificRequest : Text


Class extends AI_Agent

singleton Class constructor()
	Super()
	This.formObject:=Null

	
Function loadSchemas()
	var $schemaFilePath:="/RESOURCES/personArraySchema.json"
	var $jsonText:=File($schemaFilePath).getText()
	This.personArraySchema:=JSON Parse($jsonText; Is object)
	
	$schemaFilePath:="/RESOURCES/personArraySchema_fixDate.json"
	$jsonText:=File($schemaFilePath).getText()
	This.personArraySchema_fixDate:=JSON Parse($jsonText; Is object)
	
Function getPersonArrayFromResponse($AIresponse : Text) : Object
	var $jsonContent : Text
	var $charStart : Text:=""
	var $jsonStart : Integer
	var $response : Object
	var $thinkStart : Integer
	var $thinkEnd : Integer
	var $jsonValidation : Object
	
	$charStart:="{"
	
	//Remove <think> </think> part of the answer, from some well known llms
	$thinkStart:=Position("<think>"; $AIresponse)
	If ($thinkStart>0)
		$thinkEnd:=Position("</think>"; $AIresponse)
		If ($thinkEnd>0)
			$AIresponse:=Delete string($AIresponse; $thinkStart; $thinkEnd+Length("</think>")-$thinkStart)
		End if 
	End if 
	
	$jsonStart:=Position($charStart; $AIresponse)
	If ($jsonStart<=0)
		return {success: False; response: Null; error: "No JSON to process"; errors: Null}
	End if 
	
	$jsonContent:=Substring($AIresponse; $jsonStart)
	$response:=Try(JSON Parse($jsonContent; Is object))
	If ($response=Null)
		return {success: False; response: Null; error: "JSON parse failed"; errors: Null}
	End if 
	
	$jsonValidation:=JSON Validate($response; This.personArraySchema_fixDate)
	If (Not($jsonValidation.success))
		return {success: False; response: Null; error: "JSON Validate failed with errors"; errors: $jsonValidation.errors}
	End if 
	
	return {success: True; response: $response.personArray; error: Null; errors: Null}
	
	
Function onStreamChatData($result : cs.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs.AI_PeopleGenerator.me
	
	If (Not($result.success))
		throw(999; "Problem querying AI provider, please try again")
		return 
	End if 
	
	$me.formObject.progressGeneratePeople({AIText: $result.choice.delta.text})
		
Function onStreamChatTerminate($result : cs.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs.AI_PeopleGenerator.me
	var $response : Object
	var $item : Object
	var $person : cs.personEntity
	var $prompt : Text
	var $toGenerate : Integer
	var $timingPerPerson : Integer
	
	If (Not($result.success))
		throw(999; "Problem querying AI provider, please try again")
		return 
	End if 
	
	//terminated and success
	$me.formObject.progressGeneratePeople({AIText: "\n\nAI response completed\n"})
	$response:=$me.getPersonArrayFromResponse($me.peopleGenBot.messages.last().text)
	
	//try to import persons
	If (Not($response.success))
		$me.failedAttempts+=1
		$me.formObject.progressGeneratePeople({AIText: "AI did not respond with the expected format.\n"})
	Else 
		For each ($item; $response.response)
			$person:=ds.person.newPersonFromObject($item)
		End for each 
	End if 
	
	//check remaining persons to generate and reprompt if needed
	$me.generated:=ds.person.all().length-$me.alreadyThere
	If (($me.generated<$me.quantity) && ($me.failedAttempts<$me.maxFailedAttempts))
		$me.prompt()
	Else   //all people are generated or too many failed attempts ==> Finish
		$me.timing:=Milliseconds-$me.startMillisecond
		$me.formObject.progressGeneratePeople({AIText: String($me.generated)+" person generated in "+String($me.timing)+" ms. \n"})
		If ($me.generated>0)
			$me.formObject.progressGeneratePeople({AIText: String(Int($me.timing/$me.generated))+" ms per person entity\n"})
		End if 
		$me.formObject.terminateGeneratePeople()
	End if 
	
Function prompt()
	var $prompt : Text
	var $toGenerate : Integer
	var $progress : Object
	
	$progress:={value: Int(This.generated/This.quantity*100); message: "Generating people "+String(This.generated)+"/"+String(This.quantity)}
	$toGenerate:=(This.quantityBy<(This.quantity-This.generated)) ? This.quantityBy : (This.quantity-This.generated)
	$prompt:="generate "+String($toGenerate)+" people. Specific request: "+This.specificRequest+"Start answering with ```json\n{ \"personArray\":"
	
	This.formObject.progressGeneratePeople({AIText: "Prompt : "+$prompt+"\n\n"; progress: $progress})
	This.peopleGenBot.prompt($prompt)

Function initBot()
	var $systemPrompt : Text
	var $options:=cs.AIKit.OpenAIChatCompletionsParameters.new()
	var $skillSet:=ds.skill.all().extract("name")
	
	This.loadSchemas()
		
	$systemPrompt:="You are a data generating assistant. Your answers are used to populate a database.\n"+\
		"**CONTEXT**\n"+\
		"My application stores employees data of a worldwide software consulting firm, dealing with a wide variety of projects from app development to HR and project management\n"+\
		"**INSTRUCTIONS**\n"+\
		"I will ask you to generate a certain amount of records, and you always provide me the answer as a **json array**.\n"+\
		"You can reason step by step, but in such case do it between <THINK> </THINK> so that it does not polute your final answer.\n"+\
		"**CONSTRAINTS**\n"+\
		"Your answers must be structured and stricly JSON formatted, not conclusion, no introduction, no greetings, just pure json.\n"+\
		"Avoid too generic names like john doe, prefer realistic ones.\n"+\
		"Each skill of **personSkills** has a **skillName** being one of the following values:"+JSON Stringify($skillSet)+"\n"

	$options.response_format:={type: "json_schema"; json_schema: {name: "person_array_schema"; schema: this.personArraySchema}}
	$options.model:=This.model
	$options.stream:=True
	$options.onData:=This.onStreamChatData
	$options.onTerminate:=This.onStreamChatTerminate
	
	This.peopleGenBot:=This.AIClient.chat.create($systemPrompt; $options)
	
Function generatePeopleAsync($quantity : Integer; $quantityBy : Integer; $specificRequest : Text; $formObject : Object)
	var $options : cs.AIKit.OpenAIChatCompletionsParameters
	
	This.quantity:=$quantity
	This.quantityBy:=$quantityBy
	This.specificRequest:=$specificRequest
	This.formObject:=$formObject
	
	This.generated:=0
	This.failedAttempts:=0
	This.maxFailedAttempts:=3
	This.alreadyThere:=ds.person.all().length
	This.startMillisecond:=Milliseconds
	
	This.initBot()
	This.prompt()