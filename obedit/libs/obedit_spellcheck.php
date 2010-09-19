<?php

	//
	// Include the unicode functions
	//
	require_once(dirname(__FILE__).'/obedit_unicode.inc.php');
	
	//
	// Tell the browser (obedit) we're sending XML
	//	
	header("Content-type: text/xml\n\n");	
	
	//
	// Check if ASpell functionality exists - if not, exit with an error.
	//
	// Possible reasons for this error:
	//  - The ASpell library at apsell.sourceforge.net is not installed on the server;
	//  - (unix)  PHP has not been compiled with the aspell extension
	//  - (win32) The ASpell DLL extension has not been enabled in php.ini, 
	//            or the required DLL's cannot be found (some need to be copied to
	//            the %System32% folder in windows - see the PHP documentation for pspell()) 
	//  - Your version of PHP does not support the ASpell libraries.
	//
	if (!@function_exists("pspell_new"))
	{
		die("<?xml version=\"1.0\"?><error>Server Error: The ASpell library is not installed or PHP is not configured to use it.</error>");
	}
	
	// 
	// Initialize vars
	//
	$bad_words = 0;
	$total_words = 0;
	$responseitem = "";

	//
	// Get the text from the client (POST or GET queries accepted)
	//
	$stxt = isset($_REQUEST['txt']) ? $_REQUEST['txt'] : FALSE;

	//
	//	If the user submitted text...
	//
	if ($stxt !== FALSE) 
	{
		//
		// This turns all extended unicode characters into periods.
		// It makes the spellchecker ignore unicode characters without
		// upsetting the character indexes for spellchecker results.
		//
		$stxt = unicode_to_periods(utf8_to_unicode($stxt));
		
		//
		// Fire up ASpell and load the english dictionary.
		//
		// Possible reasons for this error:
		//  - The dictionary you're trying to load is not installed (see aspell.sourceforge.net)
		//  - Some other error beyond our control 
		//       (PHP/Win32 sometimes has problems init'ing the library, trying again usually works.)
		//
		// Added 26-03-2005 - Retry feature.
		// Try loading the library up to 3 times before failing. Seems to work well,
		// except it increases the processing time for the script (the failed tries take some time.)
		//
		
		$psp = FALSE;
		$loaded_psp = FALSE;

		for ($i=1; $i <= 3; $i++)
		{
			if (($psp = @pspell_new("en")) !== FALSE) 
			{
				$fp = fopen("aspell_retry_count.txt", "a");
				
				$msg = $_SERVER['REMOTE_ADDR'] . " - Tries: $i\n";
				
				fwrite($fp, $msg, strlen($msg));
				fclose($fp);
				$loaded_psp = TRUE;
				break;
			}
		}
		
		// Failed, show error.
		if (!$loaded_psp) 
		{
			die("<?xml version=\"1.0\"?><error>Server Error: PHP could not initiate the ASpell library.</error>");
		}

		if (($psp = @pspell_new("en")) === FALSE)
		{
			//
			// Return an error message
			//
		}
		
		//
		// Get a count of the words in the document.
		//		
		$total_words = str_word_count($stxt);
		
		//
		// Split document into words
		//  Ignore anything that is not a word or digit character (as defined in regex \w & \d).
		//
		$swords = preg_split('#(\W|\d)#', $stxt, -1, PREG_SPLIT_OFFSET_CAPTURE);
		
		//
		// Loop through the words
		//
		foreach ($swords as $word_data)
		{
			$word = $word_data[0];		
			$word_beg = $word_data[1];
			$word_end = $word_data[1] + strlen($word);
			
			//
			// Spellcheck the word
			//
			if (strlen($word) > 1 && !@pspell_check($psp, $word)) 
			{
				//
				// The word is misspelled...
				//
				$bad_words++;	
				
				$responseitem .= "<word text=\"$word\" startchar=\"$word_beg\" endchar=\"$word_end\">";	 // describe the word and where it begins & ends

				//
				// Get spelling suggestions...
				//							
				$suggestions = @pspell_suggest($psp, $word);  // get alternate spelling suggestions
					
				foreach ($suggestions as $suggestion) 
				{
					$responseitem .= "<alternate>$suggestion</alternate>\n";  // loop through suggestions and add them to the response
				}
							
				$responseitem .= "</word>";
			}
		}

		//
		// Output the XML response containing the misspelled words
		// and suggestions for replacements.
		//	
		echo "<?xml version=\"1.0\"?>";
		echo "<spellcheckreply>";		
		echo "<words total=\"$total_words\" bad=\"$bad_words\">";
		echo $responseitem;
		echo "</words>";
		echo "</spellcheckreply>";
	
	}
	else
	{
		//
		// Return an error message
		//
		die("<?xml version=\"1.0\"?><error>You must send text to spellcheck.</error>");
	}

?>