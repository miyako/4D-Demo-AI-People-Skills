singleton Class constructor
	
	
Function importSkills()
	var $jsonText:=File("/RESOURCES/exp_skills.json").getText()
	var $skillsCollection:=JSON Parse($jsonText)
	var $skill : Object
	var $categoryEnt : cs.skillCategoryEntity
	var $skillEnt : cs.skillEntity
	
	For each ($skill; $skillsCollection)
		$categoryEnt:=ds.skillCategory.query("name = :1"; $skill.category.name).first()
		If ($categoryEnt=Null)
			$categoryEnt:=ds.skillCategory.new()
			$categoryEnt.name:=$skill.category.name
			$categoryEnt.save()
		End if 
		$skillEnt:=ds.skill.query("name = :1"; $skill.name).first()
		If ($skillEnt=Null)
			$skillEnt:=ds.skill.new()
			$skillEnt.name:=$skill.name
		End if 
		$skillEnt.category:=$categoryEnt
		$skillEnt.save()
	End for each 
	
	
	