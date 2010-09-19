////////////////////////////////////////////////////////////////////
//
//                                          SAVE CONFIRMATION SCRIPT
//
////////////////////////////////////////////////////////////////////

// This variable is used to track whether 
// there are unsaved changes in obedit.

var changesSaved = true;

// This function is called by obedit to udpate whether
// there are unsaved changes or not.

function setSafeToExit(safeValue)
{
	changesSaved = safeValue;
}

// Call this function from your JavaScripts
// to determine if the changes are saved or not.

function isSafeToExit()
{
	return changesSaved;
}

// Use this function instead of direct <a href..> links in
// the page that obedit is hosted in. This function will check
// whether changes have been saved to obedit before allowing the
// user to follow the link.
//
// Instead of:  <a href="somepage.html">text</a>
// Use this:    <a href="javascript:openURL('somepage.html')">text</a>

function openURL(hrefValue)
{
	if (isSafeToExit())
	{
		location.href = hrefValue;
	}
	else
	{
		if (confirm("You will lose unsaved changes in your document. Are you sure?"))
		{
			location.href = hrefValue;
		}
	}
}

//
// This function was intended to be called from the onBeforeUnload and/or onUnload events.
// However, cross-browser issues prevent this from working reliably.
//

function closeConfirmation()
{
	if (!isSafeToExit())
	{
		if (confirm("You have unsaved changes - shall I save them for you now?\n\n(OK = SAVE, CANCEL = DISCARD)"))
		{
			alert("Document would be saved at this point.");
		}
	}
}