singleton Class constructor()
	
/**
* List similar people for all people
**/
Function searchAllSimilarPeople($formObject : Object; $window : Integer)
	var $startMillisecond; $timing : Integer
	var $peopleWithSimilarities : Collection
	
	$startMillisecond:=Milliseconds
	$peopleWithSimilarities:=ds.person.peopleWithSimilarities($formObject.actions.searchingSimilarities.similarityLevel/100)
	$timing:=Milliseconds-$startMillisecond
	CALL FORM($window; Formula($formObject.terminateSearchAllSimilarPeople($peopleWithSimilarities; $timing)))