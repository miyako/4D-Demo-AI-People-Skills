Class extends DataClass

Function personSearchByVector($terms : Text; $requestedQuantity : Integer; $threshold : Real) : Object
	
	var $logs : Collection:=[]
	var $embeddingInfo : cs.embeddingInfoEntity
	var $peopleFound : cs.personSelection
	var $vector : 4D.Vector
	var $vectorObj : Object
	var $formula : 4D.Function
	var $distincts : Collection
	
	$embeddingInfo:=ds.embeddingInfo.info()
	If ($embeddingInfo.model=Null)
		return {success: False}
	End if 
	
	$logs.push("Start vector search")
	
	cs.AI_Vectorizer.me.setAgent($embeddingInfo.provider; $embeddingInfo.model; False)
	
	Case of 
		: ($embeddingInfo.model="@sarashina-@")
			$terms:="task: クエリを与えるので，もっともクエリに意味が似ている一節を探してください。\nquery: "+$terms
		: ($embeddingInfo.model="@bge-@")
			$terms:="Represent this sentence for searching relevant passages: "+$terms
		: ($embeddingInfo.model="@e5-@")
			$terms:="query: "+$terms
	End case 
	
	$vector:=cs.AI_Vectorizer.me.vectorize($terms)
	$vectorObj:={vector: $vector; metric: mk cosine; threshold: $threshold}
	$peopleFound:=ds.person.query("embedding > :1"; $vectorObj)
	
	$logs.push("Selection of "+String($peopleFound.length)+" people => searched terms = '"+$terms+"'")
	$logs.push("... "+String($peopleFound.length)+" people matched")
	$logs.push("Now ordering and slicing to return the "+String($requestedQuantity)+" best matches")
	
	$formula:=Formula(This.embedding.cosineSimilarity($vector))
	$peopleFound:=$peopleFound.orderByFormula($formula; dk descending)
	$peopleFound:=$peopleFound.slice(0; $requestedQuantity)
	
	$logs.push("Returning the following persons: "+$peopleFound.extract("fullname").join(" || "))
	
	return {success: True; peopleFound: $peopleFound; logs: $logs; vectorUsed: $vector}
	
Function pushPersonSimilarity($peopleCol : Collection; $personX : cs.personEntity; $personY : cs.personEntity; $similarity : Real) : Collection
/**
* $personX similarity with $personY is the same than
* $personY similarity with $personX
**/
	var $objPerson : Object
	
	If ($peopleCol.query("entity.ID = :1"; $personX.ID).length=0)
		$peopleCol.push({entity: $personX; personID: $personX.ID; similarities: []})
	End if 
	$objPerson:=$peopleCol.query("entity.ID = :1"; $personX.ID).first()
	$objPerson.similarities.push({entity: $personY; personID: $personY.ID; similarity: $similarity})
	
	If ($peopleCol.query("entity.ID = :1"; $personY.ID).length=0)
		$peopleCol.push({entity: $personY; personID: $personY.ID; similarities: []})
	End if 
	$objPerson:=$peopleCol.query("entity.ID = :1"; $personY.ID).first()
	$objPerson.similarities.push({entity: $personX; personID: $personX.ID; similarity: $similarity})
	
	return $peopleCol
	
Function peopleWithSimilarities($targetSimilarity : Real) : Collection
	var $peopleCol : Collection:=[]
	var $personX; $personY : cs.personEntity
	var $peopleX; $peopleY : cs.personSelection
	var $similarities : Integer
	var $similarity : Real
	var $objPerson : Object
	
	If (ds.embeddingInfo.embeddingStatus()=False)
		throw(999; "Cannot find similarities, no embedding info found. Please generate embeddings")
		return []
	End if 
	
	$peopleX:=ds.person.all().orderBy("ID")
	
	For each ($personX; $peopleX)
		If ($personX.embedding#Null)
			$peopleY:=$peopleX.slice($personX.indexOf()+1)
			For each ($personY; $peopleY)
				If ($personY.embedding#Null)
					$similarity:=$personX.embedding.cosineSimilarity($personY.embedding)
					If ($similarity>=$targetSimilarity)
						$peopleCol:=This.pushPersonSimilarity($peopleCol; $personX; $personY; $similarity)
					End if 
				End if 
				
			End for each 
		End if 
		
	End for each 
	
	For each ($objPerson; $peopleCol)
		$objPerson.similarities:=$objPerson.similarities.orderBy("similarity desc")
		$objPerson.bestMatch:=$objPerson.similarities.first().similarity
	End for each 
	$peopleCol:=$peopleCol.orderBy("bestMatch desc")
	return $peopleCol
	
Function peopleMissingEmbedding() : Integer
	return This.query("embedding = null").length
	
Function newPersonFromObject($personObject : Object) : cs.personEntity
	
	var $person : cs.personEntity
	var $address : cs.addressEntity
	var $jobDetail : cs.jobDetailEntity
	var $personSkill : cs.personSkillEntity
	var $skill : cs.skillEntity
	
	var $skillObj : Object
	var $skillsCol : Collection
	
	If (Undefined($personObject.address) || Undefined($personObject.personSkills) || Undefined($personObject.jobDetail))
		return Null
	End if 
	
	Try
		START TRANSACTION
		
		$address:=ds.address.new()
		$address.fromObject($personObject.address)
		$address.save()
		OB REMOVE($personObject; "address")
		
		$jobDetail:=ds.jobDetail.new()
		$jobDetail.fromObject($personObject.jobDetail)
		$jobDetail.save()
		OB REMOVE($personObject; "jobDetail")
		
		$skillsCol:=$personObject.personSkills
		OB REMOVE($personObject; "personSkills")
		
		$person:=ds.person.new()
		$person.fromObject($personObject)
		$person.address:=$address
		$person.jobDetail:=$jobDetail
		$person.save()
		
		For each ($skillObj; $skillsCol)
			$skill:=ds.skill.query("name = :1"; $skillObj.skillName).first()
			If ($skill#Null)
				$personSkill:=ds.personSkill.new()
				$personSkill.fromObject($skillObj)
				$personSkill.skill:=$skill
				$personSkill.person:=$person
				$personSkill.save()
			End if 
			
		End for each 
		OB REMOVE($personObject; "personSkills")
		
		VALIDATE TRANSACTION
		return $person
		
	Catch
		CANCEL TRANSACTION
		return Null
		
	End try