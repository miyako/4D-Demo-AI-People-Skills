Class constructor()
	
Function resolve($item : Object) : Object
	
	return OB Class($item).new($item.platformPath; fk platform path)
	
Function getText($name : Text) : Text
	
	var $file : 4D.File
	$file:=This.resolve(Folder("/PROJECT/")).parent.file($name)
	
	If ($file.exists)
		return $file.getText()
	End if 