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
		Case of 
			: (True)
				$returnValue+=This.fullname+"は"+This.gender+"です。"
				$returnValue+="生年月日:"+String(This.birthDate; "yyyy-MM-dd")+"。"
				$returnValue+="連絡先メールアドレス:"+This.email+"。電話番号:"+This.phone+"。"
			Else 
				$returnValue+=This.fullname+" is a "+This.gender+" person. "
				$returnValue+=$heShe+" was born on "+String(This.birthDate; "yyyy-MM-dd")+". "
				$returnValue+=$heShe+" can be contacted via "+$hisHer+" email address "+This.email+" or by phone on "+This.phone+". "
		End case 
	End if 
	
	If (($kind="skills") || ($kind="full"))
		Case of 
			: (True)
				$returnValue+="技能やスキル:\n"+This.personSkills.skillSetText()
			Else 
				$returnValue+=$hisHer+" skills and experience are the following:\n"+This.personSkills.skillSetText()
		End case 
	End if 
	
	If (($kind="jobDetails") || ($kind="full"))
		Case of 
			: (True)
				$returnValue+="人材データベース登録日:"+String(This.jobDetail.hireDate; "yyyy-MM-dd")+"。"
				$returnValue+="職種:"+This.jobDetail.jobTitle+"。基本日給:"+String(This.jobDetail.billingRate)+"。"
				If (This.jobDetail.notes#Null) && (This.jobDetail.notes#"")
					$returnValue+="追加情報:"+This.jobDetail.notes
				End if 
			Else 
				$returnValue+=$heShe+" was hired by the company on "+String(This.jobDetail.hireDate; "yyyy-MM-dd")+". "
				$returnValue+=$hisHer+" job title is "+This.jobDetail.jobTitle+" and "+$hisHer+" daily rate is "+String(This.jobDetail.billingRate)+" USD. "
				If (This.jobDetail.notes#Null) && (This.jobDetail.notes#"")
					$returnValue+="Additionnally: "+This.jobDetail.notes
				End if 
		End case 
	End if 
	
	If (($kind="address") || ($kind="full"))
		Case of 
			: (True)
				$returnValue+="居住国:"+This.address.country+"。住所:"+This.address.formatted()+"。"
			Else 
				$returnValue+=$heShe+" lives in "+This.address.country+". "+$hisHer+" exact address is "+This.address.formatted()+". "
		End case 
	End if 
	
	return $returnValue
	
	
	
	
	