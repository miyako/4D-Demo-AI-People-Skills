property skillsData : Collection
property categoriesData : Collection



Class constructor()
	
	
	This.skillsData:=[]
	This.categoriesData:=[]

	
	//MARK: -

	//MARK: Form & form objects event handlers
	
Function formEventHandler($formEventCode : Integer)
	Case of 
		: ($formEventCode=On Load)
			// Load and calculate skills data
			This.loadSkillsData()
			
	End case 
	

	//MARK: -
	//MARK: Data loading functions
	
Function loadSkillsData()
	var $category : cs.skillCategoryEntity
	var $skill : cs.skillEntity
	var $personSkill : cs.personSkillEntity
	var $personSkills : cs.personSkillSelection
	var $skillObj : Object
	var $categoryObj : Object
	var $avgLevel : Real
	var $totalLevel : Real
	var $count : Integer
	
	This.skillsData:=[]
	This.categoriesData:=[]
	
	// Loop through all categories
	For each ($category; ds.skillCategory.all().orderBy("name"))
		$categoryObj:={\
			categoryName: $category.name; \
			categoryID: $category.ID; \
			skills: []\
			}
		
		// Loop through skills in this category
		For each ($skill; $category.skills.orderBy("name"))
			// Get all person-skill relationships for this skill
			$personSkills:=$skill.personSkills
			$count:=$personSkills.length
			
			// Calculate average level
			$avgLevel:=0
			$totalLevel:=0
			
			If ($count>0)
				For each ($personSkill; $personSkills)
					If ($personSkill.level#Null)
						$totalLevel:=$totalLevel+$personSkill.level
					End if 
				End for each 
				$avgLevel:=$totalLevel/$count
			End if 
			
			// Create skill object with calculated data
			$skillObj:={\
				skillID: $skill.ID; \
				skillName: $skill.name; \
				categoryName: $category.name; \
				categoryID: $category.ID; \
				employeeCount: $count; \
				averageLevel: $avgLevel; \
				averageLevelDisplay: String($avgLevel; "###0.0")\
				}
			
			$categoryObj.skills.push($skillObj)
			This.skillsData.push($skillObj)
		End for each 
		
		// Add category summary
		If ($categoryObj.skills.length>0)
			This.categoriesData.push($categoryObj)
		End if 
		
	End for each 
	
	// Sort skills by employee count (descending)
	This.skillsData:=This.skillsData.orderBy("employeeCount desc, skillName asc")
	

