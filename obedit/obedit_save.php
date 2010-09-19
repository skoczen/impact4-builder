<?php

	//
	// Include the filter functions
	// 
	require_once('libs/obedit_html_filter.inc.php');
	
	//
	// If the user submitted some text, we want to show the output screen (this is specific to this demo page..)
	// 
	if (isset($_POST['content'])) 
	{
	
		//
		// Get the background color for the document from obedit (if present, otherwise, default to white).
		//
		$bgColor = (isset($_POST['bgColor']) && preg_match("#[0-9A-F]{3,6}#i", $_POST['bgColor'])) ? trim($_POST['bgColor']) : "FFFFFF"; 
	
		//
		// Filter the HTML and store it in a variable (for use in the output below).
		// You can of course simply echo the output of the filterHTML() function directly to the browser.
		//
		$filteredHTML = "";
		$filteredHTML = filterHTML($_POST['content']);
		
?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>obedit v3.0 / Output Filter Test</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<style type="text/css">
<!--

/***********************************
	Page Background Color
	comes from obedit
************************************/

body { 
	background-color:#<?php echo $bgColor ?>;
	font-family:Arial, Helvetica, sans-serif;
	font-size:12px;
}
h1, h2, h3, h4, h5 {
	font-family: Arial, Helvetica, sans-serif;
	margin: 0; padding: 0;
	padding-bottom:10px;
}
.pageTitle {
	padding:10px;
	border:1px dotted #aaaaaa;
	background-color:#f3f3f3;
	margin-bottom:10px;
	font-size:20px;
}
.obHTML {
	height:175px;
	width:80%;
	overflow:auto;
	white-space:pre;
	font-family:Verdana,sans-serif;
	font-size:11px;
	padding:15px;
	border:1px dotted #aaaaaa;
	background-color:#ffcc88;
	margin-bottom:10px;
}
.finalHTML {
	height:175px;
	width:80%;
	overflow:auto;
	white-space:pre;
	font-family:Verdana,sans-serif;
	font-size:9px;
	padding:15px;
	border:1px dotted #aaaaaa;
	background-color:#ffffcc;
	margin-bottom:20px;
}
-->
</style>
</head>

<body>

	<h1>obedit output preview</h1>
	
	<h2>obHTML (HTML submitted from obedit)</h2>
	<div class="obHTML"><? echo htmlspecialchars(str_replace(">",">",urldecode($_POST['content']))); ?></div>

	<h2>XHTML (filtered obHTML)</h2>
	<div class="finalHTML"><? echo trim(htmlspecialchars(getDoc())); //preg_replace("#^(\n|\r\n|\n\r|\r)#", "", ); ?></div>

<?

	//	
	// Output the filtered HTML.
	//
	echo $filteredHTML;

?>
</body>
</html>
<?
	}
	else	// No text was submitted. Show a submission form instead (ONLY for debugging - remove this for real usage!)
	{
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>obedit v3.0 / Output Filter Test</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">
label, textarea { font-family: Arial, Helvetica, sans-serif; font-weight: bold; font-size: 11px; color: black; display:block; clear:both; margin:10px; }
textarea { width: 95%; height: 400px; font-weight: normal; }
</style>
</head>
<body>
<form action="<?=$_SERVER['testfilter/PHP_SELF']?>" name="contentform" method="post">
<label for="content">Paste HTML here and submit to test output.</label>
<textarea name="content"></textarea>
<input type="submit" name="submit" value="View Filter Output" />
</form>
</body>
</html>
<?
	}
?>