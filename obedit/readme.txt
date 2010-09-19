
---------------------------------
obedit v3.03 beta notes:
---------------------------------

Formal documentation for obedit has not yet been created. 
Please refer to the comments in the source code for now.

---------------------------------
Server Requirements:
---------------------------------

PHP 4.1.0+ is required for the demo scripts.
Latest version is always recommended.

	NOTE: I have not conducted any backwards-compatibility testing
	whatsoever. You may find that even with PHP 4.1.0 it may not
	fully work. I haven't had time (or servers) to test this with.
	
	That being said, most of the scripts use SuperGlobals 
	($_POST, $_GET, $_REQUEST) which were introduced in PHP 4.1.x. 
	These can be replaced with $HTTP_POST_VARS, $HTTP_GET_VARS, etc.
	to improve backwards compatibility. $_REQUEST doesn't have
	an equivalent in previous PHP versions so you'll need to 
	write a function to help you do that.

SPELL CHECK:

For spell-check to work with the beta version, your server MUST have
GNU ASpell correctly installed for use with PHP and the english
dictionary. Support for other languages has not been implemented
nor tested. Use at your own risk.

	Win32 Servers:
	
		If you run a Win32 server, see my blog about installing ASpell on
		a Win32 machine:
		
		http://www.oblius.com/?.blogs.184
		
		If you are having problems getting it running,
		see the follow-up blog with a tip to help:
		
		http://www.oblius.com/?.blogs.194
	
	Unix / Linux / etc. Servers:
	
		Refer to the GNU ASpell website and the PHP manual 
		for how to install ASpell on other platforms:
		
		http://aspell.sourceforge.net/
		http://www.php.net/pspell
		
		I do not run a *nix server so I can't provide
		you any help about compiling, installing or 
		testing aspell on a *nix (or other) system.
		You're completely on your own.

---------------------------------
obedit3 beta archive:
---------------------------------

The folders in the beta release are structured like so:

/
	
	- Preview page (index.html)
	- Load Test Script (obedit_load.php)
	- Save Test Script (obedit_save.php)
	- Compiled obedit RTE (obedit3.swf)	

/css 

	- The CSS for the preview page
	
/docs

	- GNU LGPL License (license.txt)
	- This document (readme.txt)
	
/fla

	- obedit v3.00 FLA source (obedit3.fla)
	
/js

	- Save Confirmation Javascript (obedit_save_confirmation.js)
	
/libs

	- HTML Output Filter (obedit_html_filter.inc.php)
	- Unicode conversion (obedit_unicode.inc.php)
	- Spellchecker interface (obedit_spellcheck.php)
	
---------------------------------
obedit3 parameters:
---------------------------------

You can pass query/url parameters to obedit in the OBJECT
tag to set several settings.

Note: 
These parameter names are case sensitive!

Note: 
You can probably use the FlashVars="" attribute to 
pass these values as well (*untested*)

loadURL
	
	The path to the script that will return text
	for obedit to load into the editing window.
	The text / HTML must be valid Flash XML-HTML (obHTML).
	See obedit_load.php for an example of a load script,
	and see index.html for a demo of using this parameter.
	
	WARNING: Any features/tags/attributes not recognized in 
	the source by the editor may be nuked!!!
	
saveURL 

	The path where the text in the RTE window will
	be submitted to. This is most likely going to be
	a script which will store the text in a database
	or on disk somewhere.
	
	See obedit_save.php for an example of a save script 
	and how to use the included HTML output filter and
	unicode translation.
	
	See index.html for a demo of using this parameter.
