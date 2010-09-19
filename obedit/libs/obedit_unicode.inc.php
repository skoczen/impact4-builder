<?php	
	
	///////////////////////////////////////////////////////////////////////////
	//
	//                                                         UNICODE HANDLING
	//
	///////////////////////////////////////////////////////////////////////////
	
	//
	// Converts UTF-8 multibyte characters to Unicode #'s
	//
	// -- Modified original function to convert only characters outside
	// the standard ASCII range (> 0x07f/128). The standard ASCII range
	// of characters is added to the array byte-by-byte.
	//
	function utf8_to_unicode( $str ) 
	{
        
        $unicode = array();        
        $values = array();
        $lookingFor = 1;
        
        for ($i = 0; $i < strlen($str); $i++) 
        {
            $thisValue = ord($str[$i]);
            
            if ($thisValue < 128) 
            {
            	$unicode[] = $str[$i];  //$thisValue; <-- keep regular characters intact
            }
            else 
            {
                if (count($values) == 0) $lookingFor = ($thisValue < 224) ? 2 : 3;
                
                $values[] = $thisValue;
                
                if (count( $values ) == $lookingFor) 
                {
					$number = ($lookingFor == 3) ?
                    
                        (($values[0] % 16) * 4096) + (($values[1] % 64) * 64) + ($values[2] % 64):
                    	(($values[0] % 32) * 64) + ($values[1] % 64);
                        
                    $unicode[] = $number;
                    $values = array();
                    $lookingFor = 1;
                }
            }
        }
        return $unicode;
    }

	//
	// Converts UTF-8 character codes to HTML entities
	//
	// -- Modified original function to only "entitize" the extended codes.
	//
	// Any value in the $unicode array which is an integer larger
	// than 9 is treated as a unicode character and converted to an HTML entity.
	//
	// Technically, we could look for only values larger than 128 - because
	// the function above only encodes ASCII character values >= 128. But we 
	// know a user's value can only go up to 9 (at one char @ a time), so we
	// may as well use that as the upper limit.
	//
	function unicode_to_entities($unicode) 
	{    
        $entities = '';
        
        foreach($unicode as $value) 
        {
        	if (is_numeric($value) && $value > 9)
        	{
       			$entities .= '&#' . $value . ';';
       		}
       		else
       		{
       			$entities .= $value;
       		}
        }
        return $entities;
           
    }
    
    //
	// Converts UTF-8 character codes to spaces
	//
	// This is used by the spellchecker so that unicode characters
	// are ignored. PHP sees raw unicode as three bytes, but Flash,
	// which has full unicode compliance, sees them as one character.
	// This messes up the spellchecker word indexes by 2 bytes
	// for every unicode character preceding the bad word.
	//
    function unicode_to_periods($unicode)
    {
    	foreach($unicode as $value) 
        {
        	if (is_numeric($value) && $value > 9)
        	{
       			$entities .= ".";
       		}
       		else
       		{
       			$entities .= $value;
       		}
        }
        return $entities;
    }
    
?>