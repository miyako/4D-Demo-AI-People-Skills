Class extends Entity


Function get cityCountry() : Text
	return JSON Stringify({city: This.city; country: This.country})
	
exposed Function formatted() : Text
/* 
* Gives a nicely formatted single-line address
 */
	var $parts : Collection:=[]
	var $streetAddress : Text
	
	If (This.valid)
		$streetAddress:=This.streetNumber ? (This.streetNumber+" ") : ""
		$streetAddress+=This.streetName
		
		$parts:=[\
			($streetAddress ? $streetAddress : ""); \
			(This.building ? This.building : ""); \
			(This.apartment ? This.apartment : ""); \
			(This.poBox ? This.poBox : ""); \
			(This.city ? This.city : ""); \
			(This.region ? This.region : ""); \
			(This.postalCode ? This.postalCode : ""); \
			(This.country ? This.country : "")]
		return $parts.join(", "; ck ignore null or empty)
	Else 
		return "Invalid address"
	End if 
	
	
Function get valid() : Boolean
/* 
* Validates that the address has enough information to be used
* While the required fields can vary by country, a general rule for global applicability is:
*   - street_name AND (street_number OR building OR po_box)
*   - city
*   - postal_code
*   - country
 */
	
	var $street : Variant
	
	$street:=This.streetName && (This.streetNumber || This.building || This.poBox)
	return ($street && This.city && This.postalCode && This.country ? True : False)
	