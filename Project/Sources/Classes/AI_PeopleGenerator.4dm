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
	$jsonStart:=Position($charStart; $AIresponse; *)
	If ($jsonStart<=0)
		return {success: False; response: Null; error: "No JSON to process"; errors: Null}
	End if 
	var $charEnd : Text
	var $jsonEnd : Integer
	$AIresponse:=Substring($AIresponse; $jsonStart)
	$charEnd:="```"
	$jsonEnd:=Position($charEnd; $AIresponse; *)
	If ($jsonEnd>0)
		$AIresponse:=Delete string($AIresponse; $jsonEnd; Length($charEnd))
	End if 
	$response:=Try(JSON Parse($AIresponse; Is object))
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
	If ($me.formObject#Null)
		If (Not($result.success))
			throw(999; "Problem querying AI provider, please try again")
			return 
		End if 
		$me.formObject.progressGeneratePeople({AIText: $result.choice.delta.text})
	End if 
	
Function onStreamChatTerminate($result : cs.AIKit.OpenAIChatCompletionsResult)
	
	var $me:=cs.AI_PeopleGenerator.me
	If ($me.formObject#Null)
		
		var $response : Object
		var $item : Object
		var $person : cs.personEntity
		var $prompt : Text
		var $toGenerate : Integer
		var $timingPerPerson : Integer
		
		If (Not($result.success))
			$me.formObject.progressGeneratePeople({AIText: "Problem querying AI provider, please try again"})
			$me.formObject.terminateGeneratePeople()
			//throw(999; "Problem querying AI provider, please try again")
			return 
		End if 
		
		//%W-550.26
		If (This.stream=False)  //This=cs.AIKit.OpenAIChatCompletionsParameters
			$me.formObject.progressGeneratePeople({AIText: $result.choice.message.text})
		End if 
		//%W+550.26
		
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
		
	End if 
	
Function prompt()
	
	var $prompt : Text
	var $toGenerate : Integer
	var $progress : Object
	
	$progress:={value: Int(This.generated/This.quantity*100); message: "Generating people "+String(This.generated)+"/"+String(This.quantity)}
	$toGenerate:=(This.quantityBy<(This.quantity-This.generated)) ? This.quantityBy : (This.quantity-This.generated)
	Case of 
		: (True)
			$prompt:=String($toGenerate)+" 人分のデータを生成してください。"+This.specificRequest+"回答は以下の文字列で始めてください``\n{ \"personArray\":"
		Else 
			$prompt:="generate "+String($toGenerate)+" people. Specific request: "+This.specificRequest+"Start answering with \n{ \"personArray\":"
	End case 
	
	This.formObject.progressGeneratePeople({AIText: ""/*"Prompt : "+$prompt+"\n\n"*/; progress: $progress})
	
	var $result : cs.AIKit.OpenAIChatCompletionsResult
	$result:=This.peopleGenBot.prompt($prompt)
	
	If (This.peopleGenBot.parameters.stream)
		//async
	Else 
		This.onStreamChatTerminate.call(This.peopleGenBot.parameters; $result)
	End if 
	
Function initBot()
	
	var $systemPrompt : Text
	var $options:=cs.AIKit.OpenAIChatCompletionsParameters.new()
	var $skillSet:=ds.skill.all().extract("name")
	
	This.loadSchemas()
	
	Case of 
		: (True)
			$systemPrompt:="あなたは誠実で優秀な日本人のサンプルデータ生成アシスタントです。特に指示が無い場合は、常に日本語で回答してください。あなたの回答はデータベースにサンプルデータを登録す"+"るために使用されます。\n"+\
				"**場面**\n"+\
				"わたしのデータベースアプリケーションには、さまざま業種のソフトウェア開発プロジェクトを手掛ける国際的なコンサルティング会社で使用されるデータベースで、開発エンジニアや"+"人事部門やプロジェクトマネージャーといった分野のスキルを有するメンバーの個人情報が登録されることになっています。\n"+\
				"**指示**\n"+\
				"あなたには、一定数のサンプルデータを生成していただきたいと思います。データは必ずjson array形式で返してください。\n"+\
				"処理の過程で思考に入るときは <THINK> </THINK> の中にその内容を収め、最終的なデータそのものとは混ざらないようにお願いします。\n"+\
				"**制約**\n"+\
				"回答は厳密はJSON形式の構造で返してください。データではない説明文や補足情報や終了トークンなどは不要です。生成した個人情報データだけを返してください。\n"+\
				"いかにも機械的に生成したような氏名ではなく、それなりに現実的な個人名を生成してください\n"+\
				"スキルの項目つまりpersonSkillsはそれぞれがオブジェクトで、skillNameプロパティには、つぎに挙げる値の中からひとつ以上の値を含めてください:"+JSON Stringify($skillSet; *)+"\n"
		Else 
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
	End case 
	
	//If (This.provider="Claude")
	$systemPrompt+="Instruction\nRole: You are a Strict JSON Data Generator. You output valid JSON only, with no conversational text.\nTask: Generate a JSON object containing a single key: \"personArray\". This array must contain realistic user profiles that "+"strictly adhere to the following specification.\n1. Root Object & Naming Conventions\nStrict Casing: You must use firstname and lastname (all lowercase). Do NOT use firstName or lastName.\nNo Generic Data: Avoid names like \"John Doe.\" Use culturally dive"+"rse, realistic names.\n2. Personal Details (All Required)\nfirstname: String.\nlastname: String.\nemail: A realistic email address.\nphone: String.\nbirthDate: ISO 8601 date string (YYYY-MM-DD).\ngender: String.\n3. Address Object (Required)\nKey: \"address\"\nMa"+"ndatory Fields: streetName, city, postalCode, country.\nValidation Rule: The address MUST include a streetName AND at least one of the following: streetNumber, building, or poBox.\nOptional Fields: apartment, region.\n4. Skills Array (Required)\nKey: \"per"+"sonSkills\"\nQuantity: Generate between 5 to 15 skills per person.\nCoherence: Skills must match the person's jobTitle.\nItem Structure (All 3 fields are mandatory):\nskillName: String (e.g., \"Python\").\nlevel: Integer (1–10).\nyearsOfXP: Integer. CRITICAL"+": You must use the key yearsOfXP. Do NOT use yearsOfExperience.\n5. Job Details Object (Required)\nKey: \"jobDetail\"\nMandatory Fields:\nhireDate: ISO date string.\njobTitle: A plausible title based on their skills.\nbillingRate: Integer between 250 and 2000"+".\nnotes: String.\nRule: Leave this string empty (\"\") for 90% of people.\nRule: Fill with HR-style notes for 10% of people.\nFinal Check: Ensure every single object in the array has all required fields. Do not omit notes or billingRate. Verify strictly th"+"at yearsOfXP and firstname are spelled exactly as requested."
	//End if 
	
	$options.response_format:={type: "json_schema"; json_schema: {name: "person_array_schema"; schema: This.personArraySchema}}
	
	$options.model:=This.model
	$options.stream:=True
	
	Case of 
		: (This.provider="ONNX@")
			$options["top_k"]:=50
			$options["top_p"]:=0.9
			$options["max_tokens"]:=100000
			$options["repetition_penalty"]:=1.2
			$options.temperature:=0.7
			$options.body:=This.body
	End case 
	
	If ($options.stream)  //setting callbacks will force async
		$options.onData:=This.onStreamChatData
		$options.onTerminate:=This.onStreamChatTerminate
	End if 
	
	This.peopleGenBot:=This.AIClient.chat.create($systemPrompt; $options)
	
Function generatePeopleAsync($quantity : Integer; $quantityBy : Integer; $specificRequest : Text; $formObject : Object)
	
	This.quantity:=$quantity
	This.quantityBy:=$quantityBy
	This.specificRequest:=$specificRequest
	This.formObject:=$formObject
	
	This.generated:=0
	This.failedAttempts:=0
	This.maxFailedAttempts:=1
	This.alreadyThere:=ds.person.all().length
	This.startMillisecond:=Milliseconds
	
	This.initBot()
	This.prompt()
	
Function body() : Object
	
	//%W-550.26
	return {\
		top_k: This.top_k; \
		top_p: This.top_p; \
		max_tokens: This.max_tokens; \
		repetition_penalty: This.repetition_penalty; \
		temperature: This.temperature; \
		n: This.n; \
		response_format: This.response_format; \
		stream: This.stream}
	//%W+550.26