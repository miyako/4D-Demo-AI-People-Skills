//%attributes = {"invisible":true}
var $person : cs.personEntity
$person:=ds.person.all().first()
$person.embedding:=Null
$person.save()