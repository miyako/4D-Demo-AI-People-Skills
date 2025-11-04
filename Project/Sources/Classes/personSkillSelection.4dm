Class extends EntitySelection

Function skillSetText() : Text
	var $skillText : Text
	var $skill : cs.personSkillEntity
	var $collection : Collection:=[]
	
	For each ($skill; This)
		$skillText:=$skill.levelStr+" in "+$skill.skill.name
		$skillText+=" ("+$skill.skill.category.name+") "
		$skillText+="with "+String($skill.yearsOfXP)+" years of experience."
		
		$collection.push($skillText)
	End for each 
	return $collection.join("\n")
	