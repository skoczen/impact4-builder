<?

	//
	// This depends on the unicode library.
	//
	require_once(dirname(__FILE__).'/obedit_unicode.inc.php');

	//////////////////////////////////////////////////////////////////////////
	//
	//                                                       UTILITY FUNCTIONS
	//
	//////////////////////////////////////////////////////////////////////////
	
	//
	// Clears the document that is being generated on the fly
	//
	function clearDoc()
	{
		global $newdoc;
		$newdoc = "";
	}

	//
	// Appends data to the document being generated on the fly
	//
	function add2Doc($data)
	{
		global $newdoc;
		$newdoc .= $data;
	}
		
	//
	// Returns the current document
	//
	function getDoc()
	{
		global $newdoc;
		return $newdoc;
	}
	
	//
	// Sets a state variable
	//
	function setState($name, $value, $append = false)
	{
		global $state;
		if ($append && isset($state[$name])) $state[$name] .= $value;
		else $state[$name] = $value;
	}
	
	//
	// Retrieves a state variable
	//
	function getState($name)
	{
		global $state;
		return (isset($state[$name])) ? $state[$name] : false;		
	}
	
	//
	// Manages CSS styles
	//
	function getCSS() { return getState('css'); }
	function addCSS($css) { setState('css', $css, true); }
	function clearCSS() { setState('css', ''); }
	
	// 
	// Used to handle list rendering <ul>, <ol>
	//
	function isInsideList() { return getState('in_list'); }
	function setInsideList($val) { setState('in_list', $val); }
	function isOrderedList() { return getState('is_ordered_list'); }
	function setOrderedList($val) { return getState('is_ordered_list', $val); }

	//
	// Used to track if filter should be aborted due to unsupported tags (hand-coded document)
	//	
	function abortFiltering() { setState('abort_filter', true); }
	function filterWasAborted() { return getState('abort_filter'); }	
	
	//
	// Manages tag states
	//	
	function setCurrentTag($tagname) { setState('current_tag', $tagname); }
	function getCurrentTag() { return getState('current_tag'); }
	function setLastTag($tagname) { setState('last_tag', $tagname); }
	function getLastTag() { return getState('last_tag'); }
	
	//
	// Manages elements empty or not
	//
	function setEmpty($val) { setState('empty', $val); }
	function getEmpty() { return getState('empty'); }

	//
	// Depth management
	//
	function setDepth($val) { setLastDepth(getDepth()); setState('depth', $val); }
	function getDepth() { return getState('depth'); }
	function setLastDepth($val) { setState('last_depth', $val); }
	function getLastDepth() { return getState('last_depth'); }

	//
	// Tracking style tags (for elimination of redundant nested tags)
	//
	function setLastStyleTag($val) { setState('style_tag', $val); }
	function getLastStyleTag() { return getState('last_style_tag'); }

	//
	// Keeping track of font sizes & colors
	//
	function setLastFont($val) { setState('last_font', $val); }
	function getLastFont() { return getState('last_font'); }
	function setLastSize($val) { setState('last_size', $val); }
	function getLastSize() { return getState('last_size'); }
	function setLastColor($val) { setState('last_color', $val); }
	function getLastColor() { return getState('last_color'); }	
	function resetLastStyle() { setLastFont(""); setLastSize(""); setLastColor("");	}
	
	//
	// Converts Flash default fonts to CSS default fonts (_sans = sans-serif, etc.)
	//
	function filterFontNames($name)
	{
		switch($name) // convert default font names
		{
			case "_sans" : $name = "sans-serif"; break;
			case "_typewriter" : $name = "monospace"; break;
			case "_serif" : $name = "serif"; break;
		}
		if (strpos($name, " ") !== false) $name = "'$name'";
		return $name;
	}

	//
	// Converts older HTML FONT sizes (1-6) into their
	// px equivalents (for use with CSS);
	//
	function fontSizeToPx($htmlFontSize)
	{
		switch($htmlFontSize)
		{
			case 1: return 10; break;
			case 2: return 12; break;
			case 3: return 16; break;
			case 4: return 18; break;
			case 5: return 24; break;
			case 6: return 36; break;
			default: return $htmlFontSize; break;
		}
	}

	//
	// Converts px font sizes to older HTML FONT equivalents (1-6)
	//	
	function pxToFontSize($pxSize)
	{
		switch($htmlFontSize)
		{
			case 10: return 1; break;
			case 12: return 2; break;
			case 16: return 3; break;
			case 18: return 4; break;
			case 24: return 5; break;
			case 36: return 6; break;
			default: return $pxSize; break;
		}		
	}	
	
	//////////////////////////////////////////////////////////////////////////
	//
	//                                                        PARSER FUNCTIONS
	//
	//////////////////////////////////////////////////////////////////////////
	
	//
	// Handles the beginning of a tag
	//
	function startElement($parser, $name, $attrs) 
	{
		setCurrentTag(strtolower($name));
		setEmpty(true);

		//
		// If we are currently processing a list (<ol> or <ul>), check if the next element is a 
		// block-level element (P, etc.). If so, then we must break out of the list by closing it (</ul> or </ol>)
		// and start rendering the new element.   
		//		
		if (isInsideList() && $name == "P")
		{
			if (isOrderedList()) add2Doc("\n</ol>\n");  // check for ordered lists and preserve if present.
			else add2Doc("</ul>\n");
			setInsideList(false);			
			setDepth(getDepth()-1);				
		}
		
		switch($name)
		{
			//////////////////////// TEXTFORMAT (some attrs add to <p>)
			case "TEXTFORMAT": 
			
				foreach ($attrs as $aname => $avalue)
				{
					switch($aname)
					{
						case "INDENT":
							addCSS("margin-left:".strtolower($avalue)."px;");
							break;
					}
				}
				break;
				
			//////////////////////// PARAGRAPH
			case "P": 
							
				add2Doc("\n<p style=\"margin:0;".getCSS());
				setDepth(getDepth()+1);			
				
				foreach ($attrs as $aname => $avalue)
				{
					switch($aname)
					{
						case "ALIGN":	add2Doc("text-align:".strtolower($avalue).";"); break;
					}
				}
				add2Doc("\">");
				break;
				
			//////////////////////// ANCHORS (LINKS)
			case "A": 
				
				add2Doc("<a ");
				foreach ($attrs as $aname => $avalue)
				{
					switch($aname)
					{
						case "HREF": 	add2Doc("href=\"$avalue\" "); break;
						case "TARGET": 	add2Doc("target=\"$avalue\" "); break;
					}
				}
				add2Doc(">");				
				
			//////////////////////// FONT (converts to <span>)
			case "FONT": 
			
				$stylevalue = "";
				
				foreach ($attrs as $aname => $avalue)
				{
					switch($aname)
					{
						case "FACE": 
							if (getLastFont() != $avalue) 	$stylevalue .= "font-family:".filterFontNames($avalue).";";
							setLastFont($avalue);
							break;

						case "SIZE": 
							$avalue = fontSizeToPx($avalue);
							if (getLastSize() != $avalue) $stylevalue .= "font-size:".$avalue."px;"; 
							setLastSize($avalue);
							break;
							
						case "COLOR": 
							if (getLastColor() != $avalue) 	$stylevalue .= "color:".strtolower($avalue).";"; 
							setLastColor($avalue);							
							break;
					}					
				}				
				if ($stylevalue != "")
				{
					add2Doc("<span style=\"$stylevalue\">");
					setDepth(getDepth()+1);
				}				
				break;				

			//////////////////////// Bold
			case "B":
				add2Doc("<strong>");	
				setDepth(getDepth()+1);				
				break;
				
			//////////////////////// Italic
			case "I":
				add2Doc("<em>");	
				setDepth(getDepth()+1);				
				break;			
				
			//////////////////////// Italic
			case "U":
				add2Doc("<span style=\"text-decoration:underline;\">");	
				setDepth(getDepth()+1);				
				break;					
				
			//////////////////////// List Items
			case "LI":
				
				if (!isInsideList()) // check for unwrapped lists from obedit.
				{
					add2Doc("\n<ul style=\"margin-top:0;margin-bottom:0;\">\n");
					setDepth(getDepth()+1);
					setInsideList(true);
					setOrderedList(false);
				}
				add2Doc("\t<li>");	
				setDepth(getDepth()+1);				
				break;
			
			case "PARSERDOCUMENT": break;

			/////////////////////// Abort filtering on unsupported tags
			default: 
				abortFiltering();
				//echo "Aborted filtering on &lt;$name&gt;<br />";
				break;
		}
	}

	//
	// Handles element closing
	//
	function endElement($parser, $name) 
	{	
		setCurrentTag("");
		
		switch($name)
		{
			////////////////////// Paragraph
			case "P":
				if (getEmpty()) add2Doc("&nbsp;");
				setLastTag("p");
				clearCSS();
				add2Doc("</p>\n");
				setDepth(getDepth()-1);
				resetLastStyle();
				break;

			//////////////////////  List Item
			case "LI":
				setLastTag("li");		
				add2Doc("</li>\n");
				setDepth(getDepth()-1);
				resetLastStyle();
				break;

			////////////////////// Bold				
			case "B":
				setLastTag("strong");		
				add2Doc("</strong>");
				setDepth(getDepth()-1);
				break;	
				
			////////////////////// Italic
			case "I":
				setLastTag("em");		
				add2Doc("</em>");
				setDepth(getDepth()-1);
				break;	
				
			////////////////////// Underline
			case "U":
				setLastTag("u");		
				add2Doc("</span>");
				setDepth(getDepth()-1);
				break;		
			
			////////////////////// Underline
			case "A":
				setLastTag("a");		
				add2Doc("</a>");
				setDepth(getDepth()-1);
				break;												
				
			////////////////////// Font <span>
			case "FONT":
				setLastTag("span");		
				add2Doc("</span>");
				setDepth(getDepth()-1);
				break;
				
			case "PARSERDOCUMENT": break;
			case "TEXTFORMAT": break;
			
			/////////////////////// Abort filtering on unsupported tags
			default:
				abortFiltering();
				//echo "Aborted filtering on &lt;/$name&gt;<br />";
				break;
		}		
	}

	//
	// Handles character data
	//
	function characterData($parser, $data) 
	{
		setEmpty(false);
		add2Doc(unicode_to_entities(utf8_to_unicode($data)));
	}

	///////////////////////////////////////////////////////////////////////////
	//
	//                             						   MAIN FILTER FUNCTION
	//
	///////////////////////////////////////////////////////////////////////////
	
	function filterHTML($codeContent)
	{
		global $state;
			
		// Array holds information about the current state of parsing 
		// e.g. the current tag, the last tag, etc.
		$state = array();
		
		// Clear the document in case function is called several times on one page
		clearDoc();

		// set up state defaults
		setState('abort_filtering', false); // used to abort filtering on encountering an unsupported tag
		setState('current_tag', "");		// the current tag being processed
		setState('in_list', false);			// whether the parser is currently inside a list (<ul> or <ol> etc...)
		setState('is_ordered_list', false);	// whether the current list being parsed is an <ol> (for preservation)
		setState('last_tag', "");			// the last tag that was processed
		setState('css', "");				// keeps track of css styles to add to the next p tag (used to grab textformat attributes)
		setState('empty', true);			// keeps track of whether an element is empty
		setState('depth', 0);				// keeps track of the depth of the current node
		setState('style_depth', 0);			// keeps track of the depth of the current styling node (used to remove redundant styles)
		setState('last_style_depth', 0);	// keeps track of the depth of the current styling node (used to remove redundant styles)
		setState('last_depth', 0);			// keeps track of the last depth processed
		setState('last_font', "");			// keeps track of the last font family (used to avoid redundant styles)
		setState('last_size', "");			// keeps track of the last font size  (used to avoid redundant styles)
		setState('last_color', "");			// keeps track of the last foreground color (used to avoid redundant styles)

		//
		// URL-Decode the incoming content (obedit will url-encode it before sending.)
		//
		$codeContent = urldecode($codeContent);
		
		//
		// Initialize the XML parser and set element handler functions
		//
		$xml_parser = xml_parser_create();
		
		xml_parser_set_option($xml_parser, XML_OPTION_CASE_FOLDING, true);
		xml_parser_set_option($xml_parser, XML_OPTION_TARGET_ENCODING, "UTF-8");
		xml_set_element_handler($xml_parser, "startElement", "endElement");
		xml_set_character_data_handler($xml_parser, "characterData");
	
		//
		// Wrap the obedit document in XML to prevent validation errors 
		// from the XML parser (this extra stuff is ignored by the filter and won't show up in the output)
		//
		$xml_data = "<?xml version='1.0'?><parserdocument>".$codeContent."</parserdocument>";
	
		//
		// Do the parsing. See the handler functions above.
		//
		$filterResult = @xml_parse($xml_parser, $xml_data, true);
	
		//
		// If the document is invalidly formed or not valid obedit-generated HTML (e.g. hand-coded), 
		// then spit out the originally submitted HTML (but still perform unicode conversion) 
		//
		if (!$filterResult || filterWasAborted())
		{
			clearDoc();
			add2Doc(unicode_to_entities(utf8_to_unicode($codeContent)));			
		}
		else
		{
			//
			// If we're here, the document is a valid RTE document and was successfully parsed and filtered.
			//
			// Now we just have to check if the document ended with a list, and if so, 
			// close the list off with the appropriate </ul> or </ol> to wrap things up.
			//
			if (isInsideList()) 
			{
				if (isOrderedList()) add2Doc("\n</ol>");
				else add2Doc("\n</ul>");
				setInsideList(false);
			}
		}
		
		// Free up memory
		xml_parser_free($xml_parser);
		
		// Return the final HTML document
		return getDoc();
	}
?>