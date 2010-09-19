
// test vars
/*
upButtonText = "Yay Up!";
downButtonText = "Yay Down!";
topAnchorText = "\rTop!"
bottomAnchorText = "Bottom!"
barLocked = false;
barDragging = true;
upAdjust = 10;
downAdjust = -5;
initialPercent = 35;
*/


// vars
var currentValue = -1; // current scale value


function initalize()
{
	trace("vas: initalize started");
	trace("vas: this is " + new String(this));
	trace("vas: myName is " + this.myName);
	trace("vas: my state is " + getValue("lifeCycleState"));
	
	
	// Set default values
	if (startFrame == "" || startFrame == null)
		var startFrame = "start";
	
	trace("startFrame = " + startFrame);
	
	if (barLocked == "" || barLocked == null)
		barLocked = false;
	if (barDragging = "" || barDragging == null)
		barDragging = false;
	if (upAdjust == "" || upAdjust == null)
		upAdjust = 5;
	if (downAdjust == "" || downAdjust == null)
		downAdjust = -5;
	if (initialPercent == "" || initialPercent == null)
		initialPercent = 50;
	
	//trace("vas: After Init:\nbarLocked = " + barLocked + "\nbarDragging = " + barDragging + "\nupAdjust = "  + upAdjust + "\ndownAdjust = " + downAdjust + "\ninitialPercent = " + initialPercent); 
	
	gotoAndPlay(startFrame);
	
	updateBarAndText (initialPercent, initialPercent);
	
	textfieldTopAnchor.autosize = "center";
	textfieldBottomAnchor.autosize = "center";
	//setTopAndBottomAnchors(topAnchor, bottomAnchor);
	
	
	setUpAndDownButtonText(upButtonText,downButtonText)
}

function finalize()
{	
	trace("vas: finalize started");
	trace("vas: my state is " + getValue("lifeCycleState"));
	setValue("vasValue",vasScale.barScale);
}




// info
// vasScale.scaleBar is the bar.



function startBarDrag() {
	//
	if (barLocked == false)
		barDragging = true;
	
}



function stopBarDrag() {
	
	barDragging = false;
	
}




function barClick() {
	
	if (barLocked == false) {
		barLocked = true;
		barDragging = false;
	} else {
		barLocked = false;
		barDragging = true;
	}
	
	
}


function adjustPercent (amount) {
	
	newText = percentText + amount;
	newScalePos = vasScale.barScale + amount;
	
	newText = (newText > 100) ? 100 : newText;
	newText = (newText < 0) ? 0 : newText;
	
	newScalePos = (newScalePos > 100) ? 100 : newScalePos;
	newScalePos = (newScalePos < 0) ? 0 : newScalePos;
	
	updateBarAndText (newText, newScalePos);
	
}

function updateBarAndText (newText, newBarValue) {
	
		if (currentValue != -1) 
			this.selfFinalizable();
		
		currentValue = newBarValue;
		
		percentText = newText;
		this.vasScale.barScale = newBarValue;
		this.vasScale.scaleBar._yscale = newBarValue;
		
}

function setUpAndDownButtonText (upText, downText) {
	// sets the text next to the up (plus) and down (minus) buttons
	
	upButtonText.autosize = "left";
	downButtonText.autosize = "left";
	
	
	if (typeof(upText) != "undefined" && upText != null)
		upButtonText = upText;
		
	if (typeof(downText) != "undefined" && downText != null)
		downButtonText = downText;
}

initalize();


// ------------------- onClipEvent Code (on the vasScale instance) --------------------

