property AIBot : cs.AIKit.OpenAIChatHelper
property startMillisecond : Integer
property timing : Integer
property formObject : Object

Class extends AI_Agent

singleton Class constructor()
	Super()
	This.AIBot:=Null
	This.formObject:=Null
	
	//MARK: -
	//MARK: Tools declaration & schema
	
Function loadTools()
	//https://platform.openai.com/docs/guides/migrate-to-responses#5-update-function-definitions
	//https://platform.openai.com/docs/guides/function-calling#defining-functions
	var $toolsFilePath:="/RESOURCES/AITools.json"
	var $jsonText : Text
	var $jsonObject : Object
	var $tool : Object
	
	$jsonText:=File($toolsFilePath).getText()
	$jsonObject:=JSON Parse($jsonText; Is object)
	For each ($tool; $jsonObject.tools)
		$tool.handler:=This
	End for each 
	This.AIBot.registerTools($jsonObject.tools)
	
Function getToolArgumentsSchema($name : Text) : Object
	var $toolDecl : Object
	
	$toolDecl:=This.AIBot.tools.query("name = :1"; $name).first()
	return ($toolDecl#Null) ? $toolDecl.parameters : Null
	
	//MARK: -
	//MARK: Tools implementation
	
Function tool_PersonSearchByVector($input : Object) : Object
	var $result : Object
	var $identity:="firstname, lastname, email, phone, birthDate, gender"
	var $skills:="personSkills.yearsOfXP,personSkills.level,personSkills.levelStr,personSkills.skill.name"
	var $jobDetails:="jobDetail.jobTitle, jobDetail.hireDate, jobDetail.notes, jobDetail.billingRate"
	var $address:="address.streetNumber, address.streetName, address.apartment, address.building, address.poBox, address.city, address.region, address.postalCode, address.country"
	var $attributesToExtract:="ID, "+$identity+", "+$jobDetails+", "+$address+", "+$skills
	var $validation : Object
	
	$validation:=JSON Validate($input; This.getToolArgumentsSchema("tool_PersonSearchByVector"))
	If (Not($validation.success))
		return {error: "Could not validate input parameters against JSON Schema, call the tool again with proper input parameters"}
	End if 
	
	$result:=ds.person.personSearchByVector($input.terms; 20)
	
	If ($result.success)
		return {peopleFound: $result.peopleFound.toCollection($attributesToExtract)}
	Else 
		return {error: $result.logs}
	End if 
	
Function tool_listSkillsAndCategories($input : Object) : Collection
	return ds.skill.all().toCollection(["name"; "category.name"])
	
Function tool_listCitiesAndCountries($input : Object) : Collection
	return ds.address.all().distinct("cityCountry")
	
Function tool_listJobTitles($input : Object) : Collection
	return ds.jobDetail.all().distinct("jobTitle")
	
	
	//MARK: -
	//MARK: onStreamTerminate and onStreamData
	
Function getMentionnedPersonsInResponse($AIresponse : Text) : cs.personSelection
	var $jsonContent : Text
	var $jsonStart : Integer
	var $response : Object
	var $thinkStart : Integer
	var $thinkEnd : Integer
	var $personsStart : Integer
	
	//Remove <think> </think> part of the answer, from some well known llms
	$thinkStart:=Position("<think>"; $AIresponse)
	If ($thinkStart>0)
		$thinkEnd:=Position("</think>"; $AIresponse)
		If ($thinkEnd>0)
			$AIresponse:=Delete string($AIresponse; $thinkStart; $thinkEnd+Length("</think>")-$thinkStart)
		End if 
	End if 
	
	$personsStart:=Position("[PERSONS]"; $AIresponse)
	If ($personsStart>0)
		$AIresponse:=Substring($AIresponse; $personsStart+Length("[PERSONS]"))
	Else 
		return {success: True; response: Null; error: ""}
	End if 
	
	$jsonStart:=Position("{"; $AIresponse)
	If ($jsonStart>0)
		$jsonContent:=Substring($AIresponse; $jsonStart)
		$response:=Try(JSON Parse($jsonContent; Is object))
		If (($response#Null) && (Value type($response.personIDs)=Is collection))
			If ($response.personIDS.length=0)
				return {success: True; response: Null; error: ""}
			End if 
			If ((Value type($response.personIDs.first())=Is object) && (Not(Undefined($response.personIDs.first().ID))))
				return {success: True; response: ds.person.query("ID in :1"; $response.personIDs.extract("ID")); error: ""}
			End if 
		End if 
	End if 
	
	return {success: False; response: Null; error: "Failed to parse personIDs"}
	
Function onStreamTerminate($result : cs.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs.AI_QuestionningTools.me
	var $progress : Object:={}
	var $mentionnedPeople : cs.personSelection
	var $elapsedTime : Integer
	
	If (Not($result.success))
		throw(999; "Problem querying AI provider, please try again")
		return 
	End if 
	
	$mentionnedPeople:=$me.getMentionnedPersonsInResponse($me.AIBot.messages.last().text).response
	$elapsedTime:=Milliseconds-$me.startMillisecond
	
	$progress.message:="Finished"
	$me.formObject.progressQuestionning({progress: $progress})
	$me.formObject.terminateQuestionning($elapsedTime; $mentionnedPeople)
	
Function onStreamData($result : cs.AIKit.OpenAIChatCompletionsResult)
	var $me:=cs.AI_QuestionningTools.me
	var $progress:={message: "Receiving data..."}
	
	If (Not($result.success))
		throw(999; "Problem querying AI provider, please try again")
		return 
	End if 
	
	If (Not(Undefined($me.AIBot.messages)))
		$me.formObject.progressQuestionning({progress: $progress; messages: $me.AIBot.messages})
	End if 
	//MARK: -
	//MARK: AIBot management functions
	
Function resetContext()
	This.AIBot:=Null
	
Function initBot()
	var $systemPrompt : Text
	var $personSectionSchema:={personIDs: [{ID: "31288092"}; {ID: "70121441"}; {ID: "7231DGH2"}; {ID: "..."}]}
	var $options:=cs.AIKit.OpenAIChatCompletionsParameters.new()
	
	$systemPrompt:="You are a helpful assistant. I need your help to answer questions about person data stored in my application.\n"+\
		"**CONTEXT**\n"+\
		"The application stores data about employees of the company: identity and personal infos, their address, skills and level, and HR infos like notes, hire date and daily billing rate in USD"+\
		"**INSTRUCTIONS**\n"+\
		"Analyze questions and answer step by step.\n"+\
		"Use the tools at your disposal to answer everytime you think they are relevant.\n"+\
		"Format your answers as HTML snippets, as I will include them in a Web area.\n"+\
		"When there's a lot of people to list, or project cost calculation, do no hesite to use synthetic tables whenever it clarifies the answer.\n"+\
		"**IMPORTANT**\n"+\
		"When calling tools, always include all required arguments in valid JSON. Do not call a tool with empty arguments. If a value is missing, choose a reasonable default.\n"+\
		"Always double check tools results before answering. Especially when they rely on vector search. Indeed they may return results not matching with your search intention.\n"+\
		"When tool callings returns data not related with the initial question, or that you cannot use to answer, avoid detailing such results too much and stay short.\n"+\
		"**IF YOUR ANSWER DESIGNATES ONE OR SEVERAL PERSONS**\n"+\
		"Avoid using person IDs in your direct answer. Refer to persons by their name."+\
		"But at the very end of your answer, insert a section <!--[PERSONS]\n```json\n"+JSON Stringify($personSectionSchema; *)+"-->\n"+\
		"personIDs is an json array of IDs. Everytime you mention a given person in your answer, mention its ID in the array 'personIDs'.\n"+\
		"Avoid any kind of comments in this part, as it breaks json parsing.\n"+\
		"**NOTES**:\n"+\
		"The end-user sometimes asks irrelevant questions, not related to persons, skills, job position or locations.\n"+\
		"In such case, and only in such case, do not execute any tool and invite the user to ask more appropriate questions.\n"
	
	$options.model:=This.model
	$options.temperature:=0
	$options.stream:=True
	$options.onData:=This.onStreamData
	$options.onTerminate:=This.onStreamTerminate
	
	//FIXME: improve adjust tool_choice depending on provider
	//Check if model info is aware of supported values
	Case of 
		: (This.provider="@Ollama@")
			$options.tool_choice:="any"
		Else 
			$options.tool_choice:="auto"  //'any' not supported by openAI
	End case 
	
	This.AIBot:=This.AIClient.chat.create($systemPrompt; $options)
	This.loadTools()
	
	
	//MARK: -
	//MARK: Main entry point: askMe function
Function askMe($prompt : Text; $formObject : Object)
	var $progress : Object:={}
	
	This.formObject:=$formObject
	This.startMillisecond:=Milliseconds
	
	$progress.message:="Prompting AI"
	$formObject.progressQuestionning({progress: $progress})
	
	If (This.AIBot=Null)
		This.initBot()
	End if 
	
	This.AIBot.prompt($prompt)
	
	
	