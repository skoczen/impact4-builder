<?php

	//
	// Document Load Test Script
	// 
	// Returns values to obedit for loading into the editor
	//
	// Usage:
	//
	// 1. Pass the location of this script to obedit in the loadURL query variable.
	//       <object src="obedit.swf?loadURL=/path/to/this/script.php" ... > ... </object>
	// 

	// 
	// This is the document to load into the RTE. 
	// It's defined as a constant variable in this script,
	// but nothing says you can't have this text load up from a database,
	// a text file on the server, a web service, or another means - whatever your CMS or 
	// application needs to do.
	//	
	$html_document = '<TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="Arial" SIZE="18" COLOR="#000000">Welcome to obedit v3.x!</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">This is a basic rich-text editor written in Flash MX. This new version of obedit sports a spanky new interface and several new features:</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Unlinking</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Spell Checking (based on PHP &amp; <FONT COLOR="#0000FF"><A HREF="http://aspell.sourceforge.net/" TARGET="_blank"><U>GNU ASpell</U></A></FONT>)</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Load / Save mechanism</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">XHTML output filtering</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Background color (with a way to load &amp; save)</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Save Confirmation (for HTML links on obedit page)</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Document statistics (a bit buggy right now, HTML byte count is accurate)</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><LI><FONT FACE="_sans" SIZE="12" COLOR="#000000">Pimpin&apos; new logo</FONT></LI></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">While obedit has come a long way since its conception, it&apos;s still not a fully-fledged CMS editor. If you are looking for something that can do tables, images, and all that other fancy stuff - check out <FONT COLOR="#0000FF"><A HREF="http://www.fckeditor.net/" TARGET="_blank"><U>FCKeditor</U></A></FONT> by Frederico Caldeira Knabben. It is amazingly cross-browser for a DHTML editor and it is also open source<I>.</I></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">That being said, obedit would find a good home as a simple <B> blog editor</B>, <B> forum editor</B>, or something where you probably don&apos;t want users to be creating tables and images anyway.</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">This beta preview may have some bugs, but overall it&apos;s running fairly stable. If you notice any problems, please <FONT COLOR="#0000FF"><A HREF="mailto:richard@oblius.com" TARGET="_top"><U>email me</U></A></FONT> and let me know. I hope to release the source as soon as possible.</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">Thanks,</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000"></FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#000000">oblius</FONT></P></TEXTFORMAT><TEXTFORMAT LEADING="2"><P ALIGN="LEFT"><FONT FACE="_sans" SIZE="12" COLOR="#0000FF"><A HREF="http://www.oblius.com/" TARGET="_blank"><U>www.oblius.com</U></A></FONT></P></TEXTFORMAT>';
	
	
	//
	// The background color for the editing window.
	//
	// If not defined, obedit defaults to White.
	//
	// Note: This must be in the list of available background colors in the
	// bgcolor dropdown in obedit. Otherwise, obedit may still display this 
	// color in the background of the editing window while the user is working,
	// but the drop-down control where the user selects the background color
	// will default to "White" --> so this custom color will not be saved (White will
	// be submitted to your save script when saving.)
	//
	// TODO: The list of bgcolors need to be customizable. Most likely,
	// the list of approved colors should be in the config file.
	//
	// TODO: obedit needs to read the config file and set itself up based
	// on those values.
	//
	$bg_color = "FFFFFF";
	
	//
	// We must urlencode the values passed to obedit.
	//
	// This could of course be done above when the variables were defined,
	// but I've placed this here to make it clear that it is important
	// to do this before passing the vars back to obedit.
	//
	$html_document = urlencode($html_document);
	$bg_color = urlencode($bg_color);
	
	// 
	// Create the final output string for passing to obedit
	//
	$output_string = "inText=".$html_document."&bgColor=".$bg_color;
	
	//
	// And simply output it to obedit!
	//	
	echo $output_string;

	////// END
	
?>