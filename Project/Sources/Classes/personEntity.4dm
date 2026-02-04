Class extends Entity

//MARK: -
//MARK: Computed attributes
Function get fullname() : Text
	var $fullname : Text
	
	$fullname:=(This.lastname) ? (This.lastname+" ") : ""
	$fullname+=(This.firstname) ? (This.firstname) : ""
	return $fullname
	
Function set fullname()
	
Function get valid() : Boolean
/* 
* Validates that the person has enough information to be used
* The address must be valid
* At least a firstname and a lastname
* Phone or email
 */
	If ((This.address#Null) && This.address.valid)
		return ((This.firstname && This.lastname && (This.email || This.phone)) ? True : False)
	End if 
	return False
	
Function set valid()
	
	//MARK: -
	//MARK: Functions
	
Function deleteMe()
	This.address.drop()
	This.personSkills.drop()
	This.jobDetail.drop()
	This.drop()
	
Function descriptivePhrase($kind : Text) : Text
	var $returnValue : Text:=""
	var $heShe : Text
	var $hisHer : Text
	
	Case of 
		: (This.gender="male") || (This.gender="@男@")
			$heShe:="he"
			$hisHer:="his"
		: (This.gender="female") || (This.gender="@女@")
			$heShe:="she"
			$hisHer:="her"
		Else 
			$heShe:="he/she"
			$hisHer:="his/her"
	End case 
	
	If (($kind="identity") || ($kind="full"))
		$returnValue+=This.fullname+" is a "+This.gender+" person. "
		$returnValue+=$heShe+" was born on "+String(This.birthDate; "yyyy-MM-dd")+". "
		$returnValue+=$heShe+" can be contacted via "+$hisHer+" email address "+This.email+" or by phone on "+This.phone+". "
	End if 
	
	If (($kind="skills") || ($kind="full"))
		$returnValue+=$hisHer+" skills and experience are the following:\n"+This.personSkills.skillSetText()
	End if 
	
	If (($kind="jobDetails") || ($kind="full"))
		$returnValue+=$heShe+" was hired by the company on "+String(This.jobDetail.hireDate; "yyyy-MM-dd")+". "
		$returnValue+=$hisHer+" job title is "+This.jobDetail.jobTitle+" and "+$hisHer+" daily rate is "+String(This.jobDetail.billingRate)+" USD. "
		If (This.jobDetail.notes#Null) && (This.jobDetail.notes#"")
			$returnValue+="Additionnally: "+This.jobDetail.notes
		End if 
	End if 
	
	If (($kind="address") || ($kind="full"))
		$returnValue+=$heShe+" lives in "+This.address.country+". "+$hisHer+" exact address is "+This.address.formatted()+". "
	End if 
	
	return $returnValue