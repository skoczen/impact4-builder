<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>i4Builder</title>
</head>
<body bgcolor="#DDDDDD" style="margin:0; padding:0; font-family:'Arial,Verdana';">

<form action="i4Builder.php" method="post" enctype="multipart/form-data">
<div style="margin:20%; margin-top:10%">	
	<h2>Welcome to the i4 Builder. </h2><br/>
	
	Would you like to:
	<ul>
		<li><a href="i4Builder.php">Begin a new survey</a></li><br/>
		<li><a href="javascript:document.forms[0].submit()">Load an existing survey</a><br/>
			 <small>(Upload a configuration.xml file below)</small><br/>
			<input type="file" name="configFile"/><br/><br/>
		</li>
		<li>Download the base i4 Client<br/>
			<small><a href="baseWithoutSource.zip">Without source (Zip, 3.3 MB)</a></small><br/>
			<small><a href="baseWithSource.zip">With full source (Zip, 12.7 MB)</a></small></li><br/>
		</ul>
		
	 <small><strong><i>Note:</i></strong> Presently, the i4 builder allows you to create a configuration.xml file.  To create a survey, first download either version of the base i4 Client, then place the configuration.xml file into the "Resources" folder.<br/><br/>
		
		Voila! A working survey!</small>
</textarea>
</center>

</div>
</form>
</body>
</html>
