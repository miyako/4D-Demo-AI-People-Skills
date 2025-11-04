Class extends DataClass

Function embeddingStatus() : Boolean
	return (ds.embeddingInfo.all().first()=Null) ? False : True
	
	
Function info() : cs.embeddingInfoEntity
	var $embeddingInfo : cs.embeddingInfoEntity
	
	$embeddingInfo:=ds.embeddingInfo.all().first()
	$embeddingInfo:=($embeddingInfo=Null) ? ds.embeddingInfo.new() : $embeddingInfo
	
	return $embeddingInfo

Function dummyInfo() : cs.embeddingInfoEntity
	var $embeddingInfo : cs.embeddingInfoEntity
	
	$embeddingInfo:=This.new()
	$embeddingInfo.model:=""
	$embeddingInfo.provider:=""
	return $embeddingInfo