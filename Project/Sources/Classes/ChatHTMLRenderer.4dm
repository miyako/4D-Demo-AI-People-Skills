property lastContentHash : Text

singleton Class constructor()
	// Singleton instance is automatically managed by 4D
	This.lastContentHash:=""
	
	
	//MARK: -
	//MARK: Private helper methods
	
Function _normalizeLineBreaks($text : Text) : Text
	// Convert literal \n to actual line breaks
	return Replace string($text; "\\n"; Char(Line feed); *)

Function _createTag($tagType : Text; $content : Text; $isStreaming : Boolean) : Text
	// Create consistent HTML tags for different content types
	var $class : Text
	var $icon : Text
	
	Case of 
		: ($tagType="think")
			$class:="think-tag"
			$icon:="💭"
		: ($tagType="persons")
			$class:="persons-tag"
			$icon:="📋"
		Else 
			$class:="generic-tag"
			$icon:=""
	End case 
	
	If ($isStreaming)
		$class+=" streaming"
	End if 
	
	return "<br><span class=\""+$class+"\">"+$icon+" "+$content+"</span><br>"

Function _createPreview($text : Text; $maxLength : Integer) : Text
	// Create a preview of text content by normalizing whitespace and trimming
	var $preview : Text:=$text
	
	// Replace line feeds and tabs with spaces
	$preview:=Replace string($preview; Char(Line feed); " "; *)
	$preview:=Replace string($preview; Char(Tab); " "; *)
	
	// Trim whitespace using native 4D function
	$preview:=Trim($preview)
	
	// Truncate if too long
	If (Length($preview)>$maxLength)
		$preview:=Substring($preview; 1; $maxLength-3)+"..."
	End if
	
	return $preview

Function _escapeHTML($text : Text) : Text
	// Escape HTML content with a single pass for better performance
	var $escaped : Text:=$text
	
	// Use a single Replace string call for better performance
	$escaped:=Replace string($escaped; "&"; "&amp;"; *)  // Replace all occurrences
	$escaped:=Replace string($escaped; "<"; "&lt;"; *)
	$escaped:=Replace string($escaped; ">"; "&gt;"; *)
	$escaped:=Replace string($escaped; "\""; "&quot;"; *)
	$escaped:=Replace string($escaped; "'"; "&#39;"; *)
	
	return $escaped
	


Function _cleanMarkdownCodeBlocks($content : Text) : Text
	// Remove markdown code block markers like ```html...``` or ```...```
	var $result : Text:=$content
	var $startPos : Integer
	var $endPos : Integer
	
	// Handle code blocks starting with ``` (any language)
	If (Position("```"; $result)=1)
		// Skip past opening ``` and optional language specifier
		$startPos:=Position(Char(Line feed); $result)
		If ($startPos>0)
			$result:=Substring($result; $startPos+1)  // Remove ```language\n
		Else 
			$result:=Substring($result; 4)  // Remove ``` only
		End if 
		
		// Remove trailing ``` if present
		$endPos:=Position("```"; $result; Length($result)-2)
		If ($endPos>0)
			$result:=Substring($result; 1; $endPos-1)
		End if 
	End if 
	
	// Use native 4D trim function
	$result:=Trim($result)
	
	return $result


Function _hasHTMLTags($content : Text) : Boolean
	// Check if content contains common HTML tags - optimized with early exit
	var $htmlTags : Collection:=["<div"; "<p>"; "<ul>"; "<li>"; "<strong>"; "<br>"; "<table"; "<tr>"; "<td>"; "<th>"]
	var $tag : Text
	
	For each ($tag; $htmlTags)
		If (Position($tag; $content)>0)
			return True  // Early exit when first tag is found
		End if 
	End for each 
	
	return False


Function _countPersonIDs($content : Text) : Integer
	// Count person IDs in content
	var $personCount : Integer:=0
	var $searchPos : Integer:=1
	var $foundPos : Integer
	
	Repeat 
		$foundPos:=Position("\"ID\":"; $content; $searchPos)
		If ($foundPos>0)
			$personCount:=$personCount+1
			$searchPos:=$foundPos+5
		End if 
	Until ($foundPos=0)
	
	return $personCount


Function _processPersonsMarker($content : Text) : Text
	// Process content that contains [PERSONS] marker
	var $personsPos : Integer:=Position("[PERSONS]"; $content)
	var $commentStartPos : Integer:=Position("<!--"; $content)
	var $commentEndPos : Integer:=Position("-->"; $content)
	var $beforePersons : Text
	var $isInComment : Boolean:=False
	var $personCount : Integer
	var $isStreaming : Boolean:=False
	var $result : Text
	
	// Check if [PERSONS] is within an HTML comment block
	If ($personsPos>0) && ($commentStartPos>0) && ($commentStartPos<$personsPos)
		// [PERSONS] is after a comment start - check if it's actually within the comment
		If ($commentEndPos>0) && ($commentStartPos<$personsPos) && ($personsPos<$commentEndPos)
			// [PERSONS] is within a closed HTML comment block
			$isInComment:=True
			$beforePersons:=Substring($content; 1; $commentStartPos-1)
		Else 
			// Either no closing --> yet, or --> comes before [PERSONS]
			If ($commentEndPos=0)
				// No closing comment yet, [PERSONS] might be within an unclosed comment
				$isInComment:=True
				$beforePersons:=Substring($content; 1; $commentStartPos-1)
			Else 
				// Comment was closed before [PERSONS], so [PERSONS] is plain text
				$isInComment:=False
				$beforePersons:=Substring($content; 1; $personsPos-1)
			End if 
		End if 
	Else 
		If ($personsPos>0)
			// Plain [PERSONS] marker (not in comments)
			$isInComment:=False
			$beforePersons:=Substring($content; 1; $personsPos-1)
		End if 
	End if 
	
	// Count person IDs in the entire message content
	$personCount:=This._countPersonIDs($content)
	
	// Detect if still streaming: check if JSON containing personIDs is complete anywhere in content
	$isStreaming:=This._hasIncompletePersonJSONAnywhere($content) 
	
	// Check if beforePersons contains HTML tags
	var $cleanBeforePersons : Text:=This._cleanMarkdownCodeBlocks($beforePersons)
	var $hasHTMLTags : Boolean:=This._hasHTMLTags($cleanBeforePersons)
	
	// Convert literal \n to actual line breaks using centralized function
	$beforePersons:=This._normalizeLineBreaks($beforePersons)
	
	// Process <think> sections BEFORE escaping HTML
	If (Position("<think>"; $beforePersons)>0)
		$beforePersons:=This._processThinkSections($beforePersons)
		// After processing thinks, we likely have HTML now
		$result:=$beforePersons
	Else 
		// Create content with persons tag
		If ($hasHTMLTags)
			$result:=$cleanBeforePersons  // Use cleaned HTML content
		Else 
			$result:=This._escapeHTML($beforePersons)  // Escape regular text
		End if 
	End if 
	
	// Create persons tag content
	var $personsContent : Text:="Listing persons"
	If ($isStreaming)
		If ($personCount>0)
			$personsContent+=" ("+String($personCount)+"+...)"  // Show count with "+" for streaming
		Else 
			$personsContent+=" (loading...)"  // Show loading if no IDs detected yet
		End if 
	Else 
		If ($personCount>0)
			$personsContent+=" ("+String($personCount)+")"  // Final count
		End if 
	End if 
	
	// Add persons tag using centralized function
	$result+=This._createTag("persons"; $personsContent; $isStreaming)
	
	return $result


Function _processThinkSections($content : Text) : Text
	// Process content that contains <think> sections with state logic like tool calls
	var $result : Text:=$content
	var $thinkStart : Integer
	var $thinkEnd : Integer
	var $beforeThink : Text
	var $thinkContent : Text
	var $afterThink : Text
	var $thinkCard : Text
	var $thinkPreview : Text
	var $isThinkRunning : Boolean
	
	// Process all <think> sections in the content
	Repeat 
		$thinkStart:=Position("<think>"; $result)
		If ($thinkStart>0)
			$thinkEnd:=Position("</think>"; $result; $thinkStart)
			
			// Determine if thinking is running (like $isToolRunning logic)
			$isThinkRunning:=($thinkEnd=0)  // No closing tag = still thinking
			
			If ($isThinkRunning)
				// Still thinking - show simple icon (no CSS animation)
				$beforeThink:=Substring($result; 1; $thinkStart-1)
				$thinkCard:=This._createTag("think"; "Thinking..."; True)
				$result:=$beforeThink+$thinkCard
				break  // Exit like tool calls do when running
			Else 
				// Thinking complete - show content (like completed tool calls)
				$beforeThink:=Substring($result; 1; $thinkStart-1)
				$thinkContent:=Substring($result; $thinkStart+7; $thinkEnd-$thinkStart-7)
				$afterThink:=Substring($result; $thinkEnd+8)
				
				// Create preview using centralized function
				$thinkPreview:=This._createPreview($thinkContent; 50)
				
				var $displayText : Text
				If (Length($thinkPreview)>0)
					$displayText:=$thinkPreview
				Else 
					$displayText:="Thinking..."
				End if 
				
				$thinkCard:=This._createTag("think"; $displayText; False)
				$result:=$beforeThink+$thinkCard+$afterThink
			End if 
		End if 
	Until ($thinkStart=0)
	
	return $result


Function _processRegularContent($content : Text) : Text
	// Process content without [PERSONS] marker but check for <think> sections
	var $processedContent : Text:=$content
	var $cleanContent : Text
	var $contentHasHTML : Boolean
	
	// Convert literal \n to actual line breaks using centralized function
	$processedContent:=This._normalizeLineBreaks($processedContent)
	
	// Process <think> sections BEFORE any other processing
	If (Position("<think>"; $processedContent)>0)
		$processedContent:=This._processThinkSections($processedContent)
	End if 
	
	// Then clean markdown and check for HTML tags
	$cleanContent:=This._cleanMarkdownCodeBlocks($processedContent)
	$contentHasHTML:=This._hasHTMLTags($cleanContent)
	
	If ($contentHasHTML)
		return $cleanContent  // Use cleaned HTML content
	Else 
		return This._escapeHTML($processedContent)  // Escape the processed content (after think processing)
	End if


Function _hasIncompleteToolArgs($toolCall : Object) : Boolean
	// Check if tool call has incomplete or missing arguments
	If ($toolCall.function.arguments=Null) || ($toolCall.function.arguments="")
		return True  // No arguments at all
	End if 
	
	// Try to parse JSON arguments
	Try
		var $testArgs : Object:=JSON Parse($toolCall.function.arguments; Is object)
		return ($testArgs=Null)
	Catch
		return True  // Parse error means incomplete
	End try


Function _hasToolResponse($toolCall : Object; $messages : Collection; $currentIndex : Integer) : Boolean
	// Check if this tool call has a response by looking ahead in messages array
	If ($toolCall.id=Null) || ($toolCall.id="")
		return False
	End if 
	
	// Look for tool response messages after current message
	For ($j; $currentIndex+1; $messages.length-1)
		var $laterMessage : Object:=$messages[$j]
		If ($laterMessage.role="tool") && ($laterMessage.tool_call_id=$toolCall.id)
			return True
		End if 
	End for 
	
	return False


Function _renderToolCallArgs($toolCall : Object) : Text
	// Render tool call arguments as HTML
	var $result : Text
	var $toolArgs : Object
	var $argKey : Text
	var $argumentsText : Text:=$toolCall.function.arguments
	
	If ($argumentsText=Null) || ($argumentsText="")
		return ""
	End if 
	
	// Try to parse JSON arguments
	var $parseError : Boolean:=False
	Try
		$toolArgs:=JSON Parse($argumentsText; Is object)
		If ($toolArgs=Null)
			$parseError:=True
		End if 
	Catch
		$parseError:=True
	End try
	
	If ($parseError)
		// If JSON parsing fails (incomplete stream), show raw arguments
		$result:="<span class=\"tool-args\">"+This._escapeHTML($argumentsText)+"</span>"
	Else 
		// Successfully parsed JSON - show as compact key:value pairs
		$result:="<span class=\"tool-args\">"
		var $argCount : Integer:=0
		For each ($argKey; $toolArgs)
			If ($argCount>0)
				$result+="<span class=\"arg-separator\">,</span>"
			End if 
			$result+="<span class=\"arg-key\">"+This._escapeHTML($argKey)+":</span>"
			$result+="<span class=\"arg-value\">"+This._escapeHTML(String($toolArgs[$argKey]))+"</span>"
			$argCount:=$argCount+1
		End for each 
		$result+="</span>"
	End if 
	
	return $result


Function _processToolCalls($message : Object; $messages : Collection; $currentIndex : Integer) : Text
	// Process all tool calls for a message
	var $result : Text
	var $toolCall : Object
	
	// Render each tool call with appropriate icon
	For each ($toolCall; $message.tool_calls)
		var $isToolRunning : Boolean:=False
		var $toolIcon : Text
		
		// Determine if this specific tool is still running
		If (This._hasIncompleteToolArgs($toolCall))
			$isToolRunning:=True
		Else 
			$isToolRunning:=(This._hasToolResponse($toolCall; $messages; $currentIndex)=False)
		End if 
		
		// Choose icon based on tool status
		If ($isToolRunning)
			$toolIcon:="<span class=\"tool-spinner\"></span>"  // CSS spinner for running tools
		Else 
			$toolIcon:="<span class=\"tool-icon\"><img src=\"../Resources/tool-icon.svg\" alt=\"tool\"></span>"  // Small SVG tool icon for completed tools
		End if 
		
		$result+="<span class=\"tool-call\">"
		$result+="<span class=\"tool-name\">"+$toolIcon+" "+This._escapeHTML($toolCall.function.name)+"</span>"
		$result+=This._renderToolCallArgs($toolCall)
		$result+="</span> "
	End for each 
	
	return $result


Function _generateContentHash($messages : Collection) : Text
	// Generate a simple hash of the messages to detect if content changed
	var $content : Text
	var $message : Object
	
	For each ($message; $messages)
		$content+=$message.role+String($message.content)
		If ($message.tool_calls#Null)
			$content+=JSON Stringify($message.tool_calls)
		End if 
	End for each 
	
	return Generate digest($content; MD5 digest)
	

	//MARK: -
	//MARK: Public methods
	
Function getInitialHTML() : Text
	// Returns the filename of the HTML template for initial load
	// The calling code should combine this with Current resources folder
	return "chat-template.html"
	
	
Function generateMessagesHTML($messages : Collection) : Text
	// Generates only the messages HTML content (not the full page)
	var $message : Object
	var $toolCall : Object
	var $toolArgs : Object
	var $argKey : Text
	var $content : Text
	var $i : Integer
	var $result : Text
	
	For ($i; 0; $messages.length-1)
		$message:=$messages[$i]
		
		Case of 
			: ($message.role="user")
				$result+="<div class=\"message user-message\">\n"
				$result+="<div class=\"message-content\">"+This._escapeHTML($message.content)+"</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="assistant")
				$result+="<div class=\"message assistant-message\">\n"
				
				// Only show copy button if there's actual content (not just tool calls)
				var $hasContent : Boolean:=(($message.content#Null) && ($message.content#""))
				If ($hasContent)
					$result+="<button class=\"copy-button\" onclick=\"copyMessageContent(this, "+String($i)+")\">Copy</button>\n"
				End if 
				
				$result+="<div class=\"message-content\">\n"
				
				// Handle tool calls if present (show before content)
				If ($message.tool_calls#Null) && ($message.tool_calls.length>0)
					$result+=This._processToolCalls($message; $messages; $i)
				End if 
				
				// Handle content if present
				If ($message.content#Null) && ($message.content#"")
					// Check for [PERSONS] marker and process accordingly
					If (Position("[PERSONS]"; $message.content)>0)
						$content:=This._processPersonsMarker($message.content)
					Else 
						$content:=This._processRegularContent($message.content)
					End if 
					$result+=$content+"\n"
				End if 
				
				$result+="</div>\n"
				$result+="</div>\n\n"
				
			: ($message.role="tool")
				// Skip tool response messages (they're already handled in assistant messages)
				// But for debugging, let's log that we're skipping them
				
			Else 
				// Debug: log unknown message types
				$result+="<!-- DEBUG: Unknown message role: "+This._escapeHTML(String($message.role))+" -->\n"
		End case 
	End for 
	
	return $result
	
	
Function updateWebAreaWithJS($webAreaName : Text; $messages : Collection)
	// Update web area content via JavaScript without page reload
	var $messagesHTML : Text
	var $jsResult : Text
	
	$messagesHTML:=This.generateMessagesHTML($messages)
	
	// Early exit if no content
	If (Length($messagesHTML)=0)
		return 
	End if 
	
	// Minimal escaping for JavaScript safety - single pass with Replace string *
	$messagesHTML:=Replace string($messagesHTML; "\\"; "\\\\"; *)  // Escape backslashes
	$messagesHTML:=Replace string($messagesHTML; Char(Line feed); " "; *)  // Replace line feeds with spaces
	$messagesHTML:=Replace string($messagesHTML; Char(Carriage return); " "; *)  // Replace carriage returns with spaces
	$messagesHTML:=Replace string($messagesHTML; Char(Tab); " "; *)  // Replace tabs with spaces
	
	WA EXECUTE JAVASCRIPT FUNCTION(*; $webAreaName; "updateMessages"; $jsResult; $messagesHTML)


Function _cleanAndParseJSON($jsonContent : Text) : Object
	// Shared helper to clean and parse JSON content
	var $cleanJSON : Text:=$jsonContent
	var $parsedJSON : Object
	
	// Clean up JSON content in one pass
	$cleanJSON:=Replace string($cleanJSON; Char(Tab); "")
	$cleanJSON:=Replace string($cleanJSON; Char(Line feed); "")
	$cleanJSON:=Replace string($cleanJSON; Char(Carriage return); "")
	$cleanJSON:=Replace string($cleanJSON; "json"+Char(Line feed); "")  // Remove "json" if present
	
	Try
		$parsedJSON:=JSON Parse($cleanJSON)
		return $parsedJSON
	Catch
		return Null
	End try


Function _hasIncompletePersonJSONAnywhere($content : Text) : Boolean
	// Unified function to check if personID JSON is complete anywhere in content
	// This handles all cases: with/without comments, JSON in/out of comments, etc.
	
	var $personsPos : Integer:=Position("[PERSONS]"; $content)
	var $allJSONContent : Collection
	var $jsonContent : Text
	var $parsedJSON : Object
	var $i : Integer
	
	// If no [PERSONS] marker found, assume complete
	If ($personsPos=0)
		return False
	End if 
	
	// Look for JSON content in all possible locations
	$allJSONContent:=New collection
	
	// 1. Look for JSON code blocks (```json ... ```)
	var $searchPos : Integer:=1
	var $codeBlockStart : Integer
	var $codeBlockEnd : Integer
	
	Repeat 
		$codeBlockStart:=Position("```json"; $content; $searchPos)
		If ($codeBlockStart>0)
			$codeBlockEnd:=Position("```"; $content; $codeBlockStart+6)
			If ($codeBlockEnd>0)
				// Complete code block found
				$jsonContent:=Substring($content; $codeBlockStart+7; $codeBlockEnd-$codeBlockStart-7)
				$allJSONContent.push($jsonContent)
				$searchPos:=$codeBlockEnd+3
			Else 
				// Incomplete code block - still streaming
				return True
			End if 
		End if 
	Until ($codeBlockStart=0)
	
	// 2. Look for direct JSON objects (starting with { after [PERSONS])
	var $afterPersons : Text:=Substring($content; $personsPos+9)
	var $jsonStart : Integer:=Position("{"; $afterPersons)
	If ($jsonStart>0)
		$jsonContent:=Substring($afterPersons; $jsonStart)
		$allJSONContent.push($jsonContent)
	End if 
	
	// 3. If no JSON content found, still streaming
	If ($allJSONContent.length=0)
		return True
	End if 
	
	// 4. Try to parse each JSON content found
	For ($i; 0; $allJSONContent.length-1)
		$jsonContent:=$allJSONContent[$i]
		
		// Use shared JSON cleaning and parsing helper
		$parsedJSON:=This._cleanAndParseJSON($jsonContent)
		
		// If we can parse JSON with personIDs, it's complete
		If ($parsedJSON#Null) && ($parsedJSON.personIDs#Null)
			return False  // Found complete personIDs JSON
		End if 
	End for 
	
	// If none of the JSON content parsed successfully with personIDs, still streaming
	return True