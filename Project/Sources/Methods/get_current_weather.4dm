//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($arguments : Object) : Text

var $location; $unit : Text
$location:=$arguments.location  //required
$unit:=$arguments.unit  //optional
$unit:=$unit="" ? "摂氏" : $unit  //default=C°

var $weather : Object
Case of 
	: ($location="東京都渋谷区")
		$weather:={unit: $unit; temperature: 10; weather: "晴れ時々曇り所により一時雨"}
	Else 
		$weather:={unit: $unit; temperature: 0; weather: "曇り時々雨または霙"}
End case 

If ($unit="華氏")
	$weather.temperature:=((9/5)*$weather.temperature)+32
End if 

return JSON Stringify($weather)