Class extends EntitySelection

Function skillSetText() : Text
	
	var $skillText : Text
	var $skill : cs.personSkillEntity
	var $collection : Collection:=[]
	
	For each ($skill; This)
		Case of 
			: (True)
				$skillText:=$skill.skill.name
				$skillText+=" ("+$skill.skill.category.name+") "
				$skillText+=String($skill.yearsOfXP)+"年。"
				$skillText+=$skill.levelStr+"。"
			Else 
				$skillText:=$skill.levelStr+" in "+$skill.skill.name
				$skillText+=" ("+$skill.skill.category.name+") "
				$skillText+="with "+String($skill.yearsOfXP)+" years of experience."
		End case 
		$collection.push($skillText)
	End for each 
	return $collection.join("\n")