<?
	header("Pragma: public"); // required
	header("Expires: 0");
	header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
	header("Cache-Control: private",false); // required for certain browsers 
	header('Content-Type: application/force-download'); 
	header("Content-Disposition: attachment; filename=\"configuration.xml\";" );

	$fullXML = stripslashes(urldecode($_REQUEST['XMLField']));
	//echo "fullXML = " . $fullXML;
	echo $fullXML;

?>
