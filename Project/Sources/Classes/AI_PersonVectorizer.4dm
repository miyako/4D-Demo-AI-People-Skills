Class extends AI_Vectorizer

singleton Class constructor()
	Super()
	
Function vectorizePerson($person : cs.personEntity; $prefix : Text)
	$person.embedding:=This.vectorize($prefix+$person.descriptivePhrase("full"))
	$person.save()
	
Function vectorizePeople($provider : Text; $model : Text; $recomputeAll : Boolean; $formObject : Object)
	var $person : cs.personEntity
	var $total; $generated : Integer
	var $embeddingInfo : cs.embeddingInfoEntity
	var $startTime : Integer:=Milliseconds
	var $endTime : Integer
	var $progress : Object:={}
	
	var $people : cs.personSelection
	
	If ($recomputeAll)
		$people:=ds.person.all()
	Else 
		$people:=ds.person.query("embedding = null")
	End if 
	
	$total:=$people.length
	
	$generated:=0
	
	This.setAgent($provider; $model; False)
	
	Case of 
		: ($model="@sarashina-@")
			$prefix:="task: クエリを与えるので，もっともクエリに意味が似ている一節を探してください。\nquery: "
		: ($model="@bge-@")
			$prefix:=""
		: ($model="@e5-@")
			$prefix:="passage: "
		Else 
			$prefix:=""
	End case 
	
	For each ($person; $people)
		This.vectorizePerson($person; $prefix)
		If (Not(Undefined($formObject)) && ($formObject#Null) && ($formObject.window#0))
			$generated+=1
			$progress.value:=Int($generated/$total*100)
			$progress.message:="Generating embeddings "+String($generated)+"/"+String($total)
			CALL FORM($formObject.window; $formObject.progressVectorizing; $progress)
		End if 
	End for each 
	
	$endTime:=Milliseconds
	
	$embeddingInfo:=ds.embeddingInfo.info()
	$embeddingInfo.provider:=This.provider
	$embeddingInfo.model:=This.model
	$embeddingInfo.embeddingDate:=Current date
	$embeddingInfo.embeddingTime:=Current time
	$embeddingInfo.duration:=$endTime-$startTime
	
	$embeddingInfo.save()
	If (Not(Undefined($formObject)) && ($formObject#Null) && ($formObject.window#0))
		CALL FORM($formObject.window; $formObject.terminateVectorizing; $progress)
	End if 