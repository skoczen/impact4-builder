// /////////////////////////////////////////////
// ///////  VARIABLES AND CONSTANTS ////////////
// /////////////////////////////////////////////
var topLevelBase 		= 10000;
var topLevelMultiplier 	= 1;
var topLevel 			= topLevelBase * topLevelMultiplier;
var clipArray 			= new Array();
var clipNumber 			= 0;
var xOffset 			= 0;
var xClipOverhangBase 	= 104;
var xClipOverhang 		= xClipOverhangBase;
var yBranchOffsetBase 	= 118;
var yBranchOffset 		= yBranchOffset;
var	xBranchOffsetBase	= 64;
var	xBranchOffset		= xBranchOffsetBase;
var baseNestingOffset	= 164;

var baseBranchVertical	= 126;
var nestingOffset		= baseNestingOffset;
var currentScale 		= 100;
var stageWidth 			= 800;
var totalClipsWidth		= 150;
var autoZoom 			= true;
var autoZooming 		= false;
var dragIntervalObj 	= null;
var currentDragClip 	= null;
var midDragZoom 		= 100;
var branchBaseOffset 	= 0;
var branchTrueYOffset	= 0;
var branchFalseYOffset 	= 0;
var branchCloseOffset 	= 0;
var branchFinalXOffset 	= 0;
var middleOffset		= 0;
var prevMouseX			= 0;
var prevMouseY			= 0;
var	surveyDepth		 	= 0;
var basePathWidth		= branchPath0.middle._width;
var baseScreenWidth		= screen0._width;
var baseBranchWidth		= branch0._width;
var branchXCenteringBase= 104;
var branchYCenteringBase= -44;
var screenXCenteringBase= 87;
var screenYCenteringBase= 43.7;
var branchXCentering	= 0;
var branchYCentering	= 0;
var screenXCentering	= 0;
var screenYCentering	= 0;
var	branchCloseYOffset	= 0;
var scaleMultiplier		= 1;
var scrollOffset 		= 0;
var initalStartScreenPos= startScreen._x;
var currentScrollPct	= 0;
var startingX			= 0;
var	startingY			= 0;
var toolTipShowing		= false;
var dragStartTime		= 0;
var currentEditScreen	= null;
var modulesXML			= new XML();
var modulesArr			= new Array();
var currentModuleLevels = new Array();
var numModulesToLoad	= 0;
var numModulesLoaded	= 0;
var navXML				= new XML();

// Layout Constants
var leftEdge			= 0;
var rightEdge 			= 645;
var topEdge				= 31;
var bottomEdge			= 497;
var layoutScaling		= 80;
var panelIntOffset		= 44;
var panelStrOffset		= 67;
var panelCdataOffset	= 130;
var panelBoolOffset		= 24;
var paramClips			= new Array();
var currentParamSet		= false;
var paramScrollPos		= 0;
var maxPanelOffset		= 425;
var panelDownEnabled	= false;
var panelUpEnabled		= false;
var baseModuleLevel		= 5000;
var nestingLevel		= 0;
var doMoves				= false;

// Condition constants
var operationsArr 		= new Array("equals","notequal","lessthan","lessthanequal","greaterthan","greaterthanequal");

// Debug.
var debugMode 			= true;
var maxLoops 			= 100;

#include "Runtime/includes/events.as"


// For the styles
_global.style.setStyle("fontSize","18");
_global.style.setStyle("fontFamily","Helvetica, Arial, _serif");



// ////////////////////////////////
// ///////  FUNCTIONS  ////////////
// ////////////////////////////////
// Supporting functions for the i4 builder
function initializeBuilder() {
	// set up clipArray
	clipArray.push(startScreen);
	
	// hide default clips
	screen0._visible = false;
	branch0._visible = false;
	
	branchClose0._visible = false;
	branchPath0._visible = false;
	
	toolTipClip._y = -4000;
//	toolTipClip._visible = false;
	
	// set the initial vars
	setup_offsets();
	
	loadModulesList();
	
	// set a param or two
	startScreen.clipType = "screen";
	startScreen.olderSibling = false;
	startScreen.youngerSibling = false;
	startScreen.inSequence = true;
	startScreen.inBranch = false;
	startScreen.nestingLevel = 0;
	startScreen.youngerSiblingTrue = false;
	startScreen.youngerSiblingFalse = false;
	startScreen.hasBeenAdded = false;
	
	scroll(0);
	
	if (debugMode == true) {
		trace ("/////////////////////////////////////////////\n///// DEBUG MODE ON /////////////////////////\n/////////////////////////////////////////////");
	}
	// load up survey?
	if (typeof(_root.xmlToLoad) != "undefined") {
		loadSurveyXML("./uploads/"+_root.xmlToLoad);
	}
}


function layout_survey (layoutMode) {
	// layout mode options: calc or real
	
	// IDEA:  if we're in layout mode calc,
	// why not just loop through and increment the counters, nada mas.
	// split the if calc OUTSIDE the while loop, so they're efficient loops.
	
	
	trace("Starting Layout. layoutMode is " + layoutMode);
	// trace("  clipArray = " + clipArray);
	tempObj = startScreen;
	counter = 0;
	xOffset = 0;
	var lastX;
	surveyDepth = 0;
	setup_offsets();
	
	// check the layout mode.
	// options: calc or real
//	if (layoutMode == "calc") {
//		doMoves = false;
//	} else {
//		doMoves = true;
//	}
	doMoves = false;
	var tempNestingLevel;

	do {
		check_branch_layout(tempObj,false, "layout_survey false");		
		layout_screen(tempObj);
		tempNestingLevel = tempObj.nestingLevel;
		tempObj = tempObj.youngerSibling;
		if (tempObj !== false ) {	tempObj.nestingLevel = tempNestingLevel;	}
		counter++;
 	} while (tempObj !== false && typeof(tempObj) != "undefined" && (debugMode == false || counter < maxLoops )) 

	tempObj = startScreen;
	counter = 0;
	doMoves = true;
	surveyDepth = 0;
	do {
		check_branch_layout(tempObj,false,"layout_survey true");		
		layout_screen(tempObj);//, ((tempObj == currentDragClip)? false : doMoves));
		lastX = tempObj._x + tempObj._width;		
		tempObj = tempObj.youngerSibling;
		counter++;
 	} while (tempObj !== false && typeof(tempObj) != "undefined" && (debugMode == false || counter < maxLoops )) 

//	trace ("***tempObj = " + tempObj + "\n   tempObj.youngerSibling = " + tempObj.youngerSibling);	

	
	totalClipsWidth = xOffset + startScreen._width;
	totalClipsWidth += (tempObj.clipType == "branch") ? (currentScale/100*(branchClose0._width + branchPath0._width)) : 0;
	
	totalClipsWidth = lastX - startScreen._x;

	branchTipClip.swapDepths(get_topLevel());	
	toolTipClip.swapDepths(get_topLevel());
	trace("Layout Complete");
}

function check_branch_layout (tempBranchScreen,inBranch, comingFrom) {
	var tempSize=0;
	var tempObj = tempBranchScreen;

//	trace("check_branch_layout: doMoves = " + doMoves + " for tempObj = " + tempObj + "  inBranch = " + inBranch + "  comingFrom= " + comingFrom);
//	trace("surveyDepth = " + surveyDepth);
	
	if (tempObj.clipType == "branch") {
		if (tempObj.inBranch !== false) {
			trace(tempObj + " is in " + tempObj.inBranch);
 			if (tempObj.branchSide === true) {
 				tempObj.inBranch.numTrueChildBranches++;
 			} else {
 				tempObj.inBranch.numFalseChildBranches++;
 			}
		}
		tempObj.xBranchTrueOffset 		= 0;
		tempObj.xBranchFalseOffset 		= 0;
		tempObj.numTrueChildScreens 	= 0;
		tempObj.numFalseChildScreens 	= 0;
		tempObj.numTrueChildBranches 	= 0;
		tempObj.numFalseChildBranches	= 0;
		tempObj.nestedBranches			= 0;
		surveyDepth ++;
//		trace("   Tricksy branch: " + tempObj.inBranch + ")");
//		trace("tempObj.youngerSiblingTrue = " + tempObj.youngerSiblingTrue);
//		trace("tempObj.youngerSiblingFalse = " + tempObj.youngerSiblingFalse)
		
		tempObj.xBranchTrueOffset =0;
		if (tempObj.youngerSiblingTrue !== false) {
			var tempBranchClip = tempObj.youngerSiblingTrue;
			if (!doMoves) {
				tempObj.nestingLevel = tempObj.nestingLevel++;				
			}
			counter = 0;
			do {
				//tempBranchClip.inBranch = tempObj;
				if (tempBranchClip.clipType == "screen") {	
					tempObj.numTrueChildScreens++;
				}
				if (!doMoves) {
					tempBranchClip.nestingLevel = tempObj.nestingLevel -1;					
				}
				tempSizeBranch = check_branch_layout(tempBranchClip,tempObj, "check_branch_layout true") + ((tempBranchClip.clipType == "branch") ? tempBranchClip._width*2 : 0 );
				tempSize = layout_screen(tempBranchClip);
				tempObj.xBranchTrueOffset += tempSize + tempSizeBranch;
//				trace("layout_screen returned tempSize = " + tempSize + " and tempSizeBranch = " + tempSizeBranch + ",\n so "+tempObj+".xBranchTrueOffset = " + tempObj.xBranchTrueOffset );


				counter++;
				tempBranchClip = tempBranchClip.youngerSibling;
			} while (tempBranchClip !== false && typeof(tempBranchClip) != "undefined" && (debugMode == false || counter < maxLoops ))
		}
		
		tempObj.xBranchFalseOffset =0;
		if (tempObj.youngerSiblingFalse !== false) {
			var tempBranchClip = tempObj.youngerSiblingFalse;
			counter = 0;
			do {
				//tempBranchClip.inBranch = tempObj; 
				if (tempBranchClip.clipType == "screen") {	
					tempObj.numFalseChildScreens++;
				}
				if (!doMoves) {
					tempBranchClip.nestingLevel = tempObj.nestingLevel +1;					
				}

				tempSizeBranch = check_branch_layout(tempBranchClip,tempObj, "check_branch_layout false") + ((tempBranchClip.clipType == "branch") ? tempBranchClip._width*2 : 0 );		
				tempSize = layout_screen(tempBranchClip);
				tempObj.xBranchFalseOffset += tempSize + tempSizeBranch;
//				trace("layout_screen returned tempSize = " + tempSize + " so "+tempObj+".xBranchFalseOffset = " + tempObj.xBranchFalseOffset );
				
				counter++;
				tempBranchClip = tempBranchClip.youngerSibling;					
			} while (tempBranchClip !== false && typeof(tempBranchClip) != "undefined" && (debugMode == false || counter < maxLoops )) 
		}
		if (tempObj.xBranchFalseOffset > tempObj.xBranchTrueOffset) {
			tempObj.pathOffset = tempObj.xBranchFalseOffset + xBranchOffset;
		} else {
			tempObj.pathOffset = tempObj.xBranchTrueOffset + xBranchOffset;
		}

		
		
		sizeBranchPaths(tempObj,false,false,0);

		// IBBITY:
		// Most of this seems to be fixed, but now we're hitting the recursion limit cap. Lovely.
		
		
		// The youngerSibling values are flat-out wrong, and i'm not sure they're even being parsed correctly. 
		// none of the branches appear to have inBranch params either.
		// Meanwhile, the layout function appears to never call layout_screen for nested branches, and relies on non local variables. Hooray!
		//layout_screen(tempObj);
		surveyDepth --;
	}
	return tempSize;
}


function hide_layout() {
	for (j in clipArray) {
		clipArray[j]._visible = false;
	}
	toolTipClip._y = -4000;
//	toolTipClip._visible = false;
//	branchTipClip._visible = false;
//	toolTipClip.removeMovieClip();
//	branchTipClip.removeMovieClip();
}


function show_layout() {
	for (j in clipArray) {
		clipArray[j]._visible = true;
	}
}




function layout_screen (tempScreen) {

//	trace("tempScreen.nestingLevel = " + tempScreen.nestingLevel);
	trace("laying out tempScreen = " + tempScreen + "  and youngerSibling= " + tempScreen.youngerSibling);
	trace("tempScreen.olderSibling = " + tempScreen.olderSibling + "   and  inBranch=" + tempScreen.inBranch); 
//	trace("surveyDepth = " + surveyDepth);
//	trace("layout_screen doMoves = " + doMoves);
	var tempSize;
	if (tempScreen != false && tempScreen != undefined) {
	
		if (doMoves) {
			// border control
			tempScreen.lockedBorder._visible = true;
			tempScreen.unlockedBorder._visible = false;

			// depth control
			tempScreen.swapDepths(get_topLevel() + 1000*surveyDepth);
		
			tempScreen.nestingSide = (tempScreen.inBranch !== false ) ? ((tempScreen.branchSide == true) ? -1 : 1) : 0;
//			trace("\nI AM tempScreen = " + tempScreen);
//			trace("tempScreen.inBranch = " + tempScreen.inBranch);
//			trace("tempScreen.inBranch.nestingLevel = " + tempScreen.inBranch.nestingLevel);
		
			// screen placement
			var tempXOffset = (tempScreen.olderSibling != startScreen) ? -1* xClipOverhang : 0;
			tempXOffset += -1 * ((tempScreen.olderSibling.clipType == "branch") ? branchXCentering :0);
			tempXOffset += (tempScreen.olderSibling.clipType == "branch" && tempScreen.inBranch != tempScreen.olderSibling) ? tempScreen.olderSibling.pathOffset + screenXCentering :0;

			tempYOffset = (tempScreen.inBranch == tempScreen.olderSibling) ? ((tempScreen.inBranch !== false ) ? (tempScreen.nestingSide * tempScreen.inBranch.nestingLevel * baseBranchVertical* currentScale/100) + (nestingOffset * tempScreen.nestingSide) :0) : 0;
	 		// nestingOffset + branchYCentering - (tempBranch.nestingLevel * baseBranchVertical* currentScale/100);
			// actual moves
			tempScreen._x = tempScreen.olderSibling._x + tempScreen.olderSibling._width + tempXOffset;
			tempScreen._y = tempScreen.olderSibling._y + tempYOffset;
		} else {
			tempScreen.hasBeenAdded = false;
		}

		if (tempScreen.clipType == "branch") {
			tempScreen.trueStretch.gotoAndStop("locked");
			tempScreen.falseStretch.gotoAndStop("locked");
			tempScreen.top.gotoAndStop("locked");
			tempScreen.bottom.gotoAndStop("locked");
			tempScreen.mainBorder.gotoAndStop("locked");
			branchDepthCounter = 0;
			sizeBranchPaths(tempScreen, true, true, 1);
			tempSize = tempScreen.pathOffset - xClipOverhang;
		} else {
			tempSize = tempScreen._width - xClipOverhang;
		}

		// handle branch sizing
		if (tempScreen.inBranch !== false && tempScreen.inBranch != undefined) {
			branchDepthCounter = 1;
			sizeBranchPaths(tempScreen,false,false,0);

		} else {
			if (tempScreen.olderSibling.clipType == "branch" && tempScreen.inBranch != tempScreen.olderSibling) {
				xOffset += tempScreen._x - tempScreen.inBranch._x;
			} 
			xOffset += tempScreen._width;
		}
//		if (tempScreen.hasBeenAdded === false && doMoves) {
			if (tempScreen.clipType == "branch") {
				if (tempScreen.pathOffset == undefined || isNaN(tempScreen.pathOffset)) {
					tempScreen.pathOffset = 0;
				}
//				trace("tempScreen = " + tempScreen);
//				trace("tempScreen.pathOffset = " + tempScreen.pathOffset);
//				trace("tempScreen._width = " + tempScreen._width);
				tempSize = tempScreen.pathOffset - xClipOverhang;
			} else {
				tempSize = tempScreen._width - xClipOverhang;
			}
			if (tempSize == undefined || isNaN(tempSize)) {
//				trace("\n\n tempSize = " + tempSize + "\ntempScreen = " + tempScreen + "\n\n");
			}
			tempScreen.hasBeenAdded = true;
//		} else {
//			tempSize = 0;
//		}
	} else {
		tempSize = 0;
	}
	return tempSize;
	
}

var branchDepthCounter;
function sizeBranchPaths (tempObj,isBranch, overrideNestCount, rootCall) {
//	trace("SIZE BRANCH PATHS CALLED!!!  ");
//	trace("sizeBranch doMoves = " + doMoves);
//	trace("tempObj = " + tempObj);
//	trace("isBranch = " + isBranch);
	rootCall ++;
		
//	trace("doMoves = " + doMoves);
	
	if (isBranch === true) {
		var tempBranch = tempObj;

	} else {
		var tempBranch = tempObj.inBranch;	

		// find which side it's on
		var side = tempObj.branchSide;

		// add to the xBranchFalseOffset / xBranchTrueOffset


//		if (doMoves === true && "foo" == "bar") {
//			if (tempObj.clipType!="branch") {
				if (tempObj.pathOffset == undefined || isNaN(tempObj.pathOffset)) {
					tempObj.pathOffset = 0;
				}
//				if (tempObj.hasBeenAdded == "ibbity") {
//					if (side === true) {
//						tempBranch.xBranchTrueOffset += tempObj._width  + tempObj.pathOffset;
//					} else {
//						tempBranch.xBranchFalseOffset += tempObj._width + tempObj.pathOffset;
//					}	
//					tempObj.hasBeenAdded = true;								
//				}

//   			trace("** Inside sizeBranchPaths: ("+tempBranch+") tempBranch._width = " + tempBranch._width + " so tempBranch.xBranchTrueOffset=" + tempBranch.xBranchTrueOffset);
//   			trace("tempBranch.pathOffset = " + tempBranch.pathOffset);
//   			trace("tempObj.inBranch = " + tempObj.inBranch);
//   			trace("tempBranch.inBranch = " + tempBranch.inBranch);

//   		} else {
//   			if (side === true) {
//   				tempBranch.xBranchTrueOffset  += tempObj.pathOffset;
//   			} else {
//   				tempBranch.xBranchFalseOffset += tempObj.pathOffset;
//   			}					
//   		}
//
//   	}
	}
	if (doMoves == false) {
//		trace("tempBranch = " + tempBranch);
//		trace("tempBranch.inBranch = " + tempBranch.inBranch);
//		trace("tempBranch.nestingLevel = " + tempBranch.nestingLevel);
//		trace("branchDepthCounter = " + branchDepthCounter);
//		trace("tempObj.youngerSibling = " + tempObj.youngerSibling);

		if (tempBranch.nestingLevel < branchDepthCounter || overrideNestCount === true) {
			tempBranch.nestingLevel = branchDepthCounter;
		}		
	} else {
		

	
//	tempBranch.nestedBranches ++;
	
	var redoSizing = false
//	if (tempObj.youngerSibling == false || isBranch === true) {
			if (tempObj.youngerSibling == false) {
				redoSizing = true;
			}
//  		trace("tempBranch = " + tempBranch);
//  		trace("tempBranch.branchCreated = " + tempBranch.branchCreated);
//  		trace("tempBranch.clipNum = " + tempBranch.clipNum);
//  		trace("tempBranch.xBranchTrueOffset = " + tempBranch.xBranchTrueOffset);
//  		trace("currentScale = " + currentScale);
			var trueClip = eval("truePath" + tempBranch.clipNum);
			var falseClip = eval("falsePath" + tempBranch.clipNum);
//			trace("trueClip = " + trueClip);
			trueClip.swapDepths(9000 - 10*tempBranch.nestingLevel - tempBranch.clipNum);
			falseClip.swapDepths(9000 -1000 - 10*tempBranch.nestingLevel - tempBranch.clipNum)

		//	trueClip._y = tempBranch._y - yBranchOffset;
			trueClip._x = tempBranch._x + xBranchOffset -1;

		//	falseClip._y = tempBranch._y + yBranchOffset;
			falseClip._x = tempBranch._x + xBranchOffset -1;

			// update the height
			// top bottom trueStretch falseStretch
//			trace("tempBranch.nestingLevel*baseBranchVertical = " + tempBranch.nestingLevel*baseBranchVertical);
			tempBranch.top._y = -206 - (tempBranch.nestingLevel * baseBranchVertical)
			tempBranch.bottom._y = 55 + (tempBranch.nestingLevel * baseBranchVertical)
			tempBranch.trueStretch._y = -105 - (tempBranch.nestingLevel * baseBranchVertical);
			tempBranch.falseStretch._y = 40+ (tempBranch.nestingLevel * 5); 
			tempBranch.trueStretch._height = 60 + (tempBranch.nestingLevel * baseBranchVertical)
			tempBranch.falseStretch._height = 70 + (tempBranch.nestingLevel * baseBranchVertical)


			// update the parent branch sizing.
			if (tempBranch.xBranchTrueOffset > tempBranch.xBranchFalseOffset) {
				trueClip.middle._width = (tempBranch.xBranchTrueOffset + baseScreenWidth) * (100/currentScale);
				falseClip.middle._width = trueClip.middle._width;
				trueClip.back._x = trueClip.middle._x - 38;
				falseClip.back._x = falseClip.middle._x - 38;
				falseClip.front._x = falseClip.middle._x + falseClip.middle._width - endOfPathOffset;
				trueClip.front._x = trueClip.middle._x + falseClip.middle._width - endOfPathOffset;
				tempBranch.pathOffset = trueClip._width;
			} else {
				falseClip.middle._width = (tempBranch.xBranchFalseOffset + baseScreenWidth) * (100/currentScale);
				trueClip.middle._width = falseClip.middle._width;
				trueClip.back._x = trueClip.middle._x - 38;
				falseClip.back._x = falseClip.middle._x - 38;
				trueClip.front._x = trueClip.middle._x + trueClip.middle._width - endOfPathOffset;
				falseClip.front._x = falseClip.middle._x + trueClip.middle._width - endOfPathOffset;
				tempBranch.pathOffset = falseClip._width;
			}
//			trace("tempBranch.nestingLevel = " + tempBranch.nestingLevel);
//			trace("nestingOffset = " + nestingOffset);
			trueClip._y = tempBranch._y - nestingOffset + branchYCentering - (tempBranch.nestingLevel * baseBranchVertical* currentScale/100);
		  	falseClip._y = tempBranch._y + nestingOffset + branchYCentering + (tempBranch.nestingLevel * baseBranchVertical* currentScale/100);

			var tempClip = eval("branchClose" + tempBranch.clipNum);
			tempClip.swapDepths(get_topLevel()+ 1000*surveyDepth);
			tempClip._y = tempBranch._y;
			tempClip._x = tempBranch._x + xBranchOffset + tempBranch.pathOffset - branchCloseOffset;
			tempClip.top._y = -206 - (tempBranch.nestingLevel * baseBranchVertical)
			tempClip.bottom._y = 103 + (tempBranch.nestingLevel * baseBranchVertical)
			tempClip.trueStretch._y = -105 - (tempBranch.nestingLevel * baseBranchVertical);
			tempClip.falseStretch._y = 40+ (tempBranch.nestingLevel * 5); 
			tempClip.trueStretch._height = 60 + (tempBranch.nestingLevel * baseBranchVertical)
			tempClip.falseStretch._height = 70 + (tempBranch.nestingLevel * baseBranchVertical)
	
	}
//	}
	
	

	if (tempBranch.inBranch != false && tempBranch.inBranch != undefined) {

		if (doMoves == false) {
			branchDepthCounter ++;			
		}

		sizeBranchPaths(tempBranch,redoSizing,overrideNestCount, rootCall);
	}
	if (doMoves == false) {
		branchDepthCounter --;
	}
	

}

/*



	trace ("  Laying out " + tempObj + "\n  " + tempObj + ".youngerSibling=" + tempObj.youngerSibling);

	var tempObj = tempScreen;

	if (tempObj == startScreen || tempObj == currentDragClip) {
		doMoves = false;
	} else {

		// move to a higher level
		tempObj.swapDepths(get_topLevel() + 1000*surveyDepth);


		// show the lockedBorders
		tempObj.lockedBorder._visible = true;
		tempObj.unlockedBorder._visible = false;		

		
		xClipTrueForThisScreen = ( (tempObj.olderSibling === tempObj.inBranch)? -1 : (xClipOverhang*(tempObj.inBranch.numTrueChildBranches+tempObj.inBranch.numTrueChildScreens-1)));
		xClipFalseForThisScreen = ( (tempObj.olderSibling === tempObj.inBranch)? -1 : (xClipOverhang*(tempObj.inBranch.numFalseChildBranches+tempObj.inBranch.numFalseChildScreens-1)));
	}


	if (tempObj.clipType == "screen") {
		// move screens and branches as needed


			// check if it's in a branch
			if (tempObj.inBranch !== false) {

				refYClip = (tempObj.branchSide === true)? eval("truePath"+tempObj.inBranch.clipNum) : eval("falsePath"+tempObj.inBranch.clipNum);
				if (doMoves) {
//					trace("   Laying out a screen: (" + tempObj.branchSide + ") " + tempObj + ")");				
					if (tempObj.branchSide=== true) {
						 tempObj._y = tempObj.inBranch._y - yBranchOffset + branchScrTrueYOffset ;
					} else {
						 tempObj._y = tempObj.inBranch._y + yBranchOffset + branchScrFalseYOffset;
					}
				}
				
				if (tempObj.branchSide === true) {	
					if (doMoves) {
						tempObj._x = refYClip._x + screenXCentering + tempObj.inBranch.xBranchTrueOffset - xClipTrueForThisScreen + ((branchXCentering-3)*tempObj.inBranch.numTrueChildBranches);
						//trace(" : tempObj.inBranch.numTrueChildScreens="+tempObj.inBranch.numTrueChildScreens+ "\n : (xClipOverhang * tempObj.inBranch.numTrueChildScreens)="+(xClipOverhang * tempObj.inBranch.numTrueChildScreens) + "\n : refYClip._x=" + refYClip._x + "\n : screenXCentering=" + screenXCentering + "\n : tempObj.inBranch.xBranchTrueOffset=" + tempObj.inBranch.xBranchTrueOffset + "\n : ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang)=-" + ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang) + "\n = ( big ass long _x = " + (refYClip._x + screenXCentering + tempObj.inBranch.xBranchTrueOffset - ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang)));
					}					
					tempObj.inBranch.xBranchTrueOffset += tempObj._width;

				} else {
					if (doMoves) {
						tempObj._x = refYClip._x + screenXCentering + tempObj.inBranch.xBranchFalseOffset - xClipFalseForThisScreen + ((branchXCentering-3)*tempObj.inBranch.numFalseChildBranches);
					}
					tempObj.inBranch.xBranchFalseOffset += tempObj._width;

				}
			} else {
				if (doMoves) {
					trace("   Laying out a screen: " + tempObj + ")");				
					tempObj._y = startScreen._y + screenYCentering;
					tempObj._x = startScreen._x + screenXCentering + xOffset;								
				}
				xOffset += tempObj._width - xClipOverhang;
			}
	} else {
		if (tempObj.clipType == "branch") {
			// it's a branch
			trace("   Laying out a branch. (" + tempObj + ")");
			//trace("   tempObj.xBranchTrueOffset = " + tempObj.xBranchTrueOffset );
			//trace("   tempObj.xBranchFalseOffset = " + tempObj.xBranchFalseOffset );	
			//trace("   tempObj.inBranch = " + tempObj.inBranch );	
			if (tempObj.inBranch == false) {
				if (doMoves) {	
					tempObj._y = startScreen._y + branchYCentering;
					tempObj._x = startScreen._x + xOffset + branchXCentering;
				}
				xOffset += tempObj._width - xClipOverhang; // + branchBaseOffset;
			} else {
				trace("   Branch In A Branch! ("+tempObj+" is in "+tempObj.inBranch+")");
				refYClip = (tempObj.branchSide === true)? eval("truePath"+tempObj.inBranch.clipNum) : eval("falsePath"+tempObj.inBranch.clipNum);
				if (tempObj.branchSide === true) {	
					if (doMoves) {
						tempObj._y = refYClip._y + branchYCentering;
						tempObj._x = refYClip._x + branchXCentering + tempObj.inBranch.xBranchTrueOffset - xClipTrueForThisScreen;
//						trace(" : tempObj.inBranch.numTrueChildScreens="+tempObj.inBranch.numTrueChildScreens+ "\n : (xClipOverhang * tempObj.inBranch.numTrueChildScreens)="+(xClipOverhang * tempObj.inBranch.numTrueChildScreens) + "\n : refYClip._x=" + refYClip._x + "\n : screenXCentering=" + screenXCentering + "\n : tempObj.inBranch.xBranchTrueOffset=" + tempObj.inBranch.xBranchTrueOffset + "\n : ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang)=-" + ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang) + "\n = ( big ass long _x = " + (refYClip._x + screenXCentering + tempObj.inBranch.xBranchTrueOffset - ( (tempObj.olderSibling === tempObj.inBranch)? 0 : xClipOverhang)));
					}					
					tempObj.inBranch.xBranchTrueOffset += tempObj._width;
				} else {
					if (doMoves) {
	//					trace ("about to place X., \n  refYClip = " + refYClip + "\n  tempObj.inBranch.xBranchFalseOffset=" + tempObj.inBranch.xBranchFalseOffset + "\n  xClipFalseForThisScreen=" + xClipFalseForThisScreen );
						tempObj._x = refYClip._x + branchXCentering + tempObj.inBranch.xBranchFalseOffset - xClipFalseForThisScreen;
						tempObj._y = refYClip._y + branchYCentering;
					}
					tempObj.inBranch.xBranchFalseOffset += tempObj._width;
				}
			}

			if (tempObj.branchCreated == true) {
				trueClip = eval("truePath" + tempObj.clipNum);
				if (doMoves) {
					trueClip.swapDepths(get_topLevel()+ 1000*surveyDepth);
					trueClip._y = tempObj._y - yBranchOffset + branchTrueYOffset;
					trueClip._x = tempObj._x + xBranchOffset -1;
				}

				falseClip = eval("falsePath" + tempObj.clipNum);
				if (doMoves) {
					falseClip.swapDepths(get_topLevel()+ 1000*surveyDepth);
					falseClip._y = tempObj._y + yBranchOffset + branchFalseYOffset;
					falseClip._x = tempObj._x + xBranchOffset -1;
				}

				// set offsets
				if (tempObj.xBranchTrueOffset == 0 && tempObj.xBranchFalseOffset == 0) {
					tempObj.xBranchTrueOffset = 0;
				} else {
					tempObj.xBranchTrueOffset 	= (baseScreenWidth * tempObj.numTrueChildScreens) + (baseBranchWidth * tempObj.numTrueChildBranches);
					tempObj.xBranchFalseOffset 	= (baseScreenWidth * tempObj.numFalseChildScreens)+ (baseBranchWidth * tempObj.numFalseChildBranches);
				}
//   			trace("#  baseBranchWidth = " + baseBranchWidth);
//   			trace("#  tempObj.numFalseChildBranches = " + tempObj.numFalseChildBranches);
//   			trace("#  tempObj.xBranchTrueOffset = " + tempObj.xBranchTrueOffset );
//   			trace("#  tempObj.xBranchFalseOffset = " + tempObj.xBranchFalseOffset );
				endOfPathOffset = 0
				if (tempObj.xBranchTrueOffset > tempObj.xBranchFalseOffset) {
					trueClip.middle._width = tempObj.xBranchTrueOffset * (100/currentScale) + baseScreenWidth/2;
					falseClip.middle._width = trueClip.middle._width;
					falseClip.front._x = falseClip.middle._x + falseClip.middle._width - endOfPathOffset;
					trueClip.front._x = trueClip.middle._x + falseClip.middle._width - endOfPathOffset;
					tempObj.pathOffset = trueClip._width;
				} else {
					falseClip.middle._width = tempObj.xBranchFalseOffset * (100/currentScale) + baseScreenWidth/2;;
					trueClip.middle._width = falseClip.middle._width;
					trueClip.front._x = trueClip.middle._x + trueClip.middle._width - endOfPathOffset;
					falseClip.front._x = falseClip.middle._x + trueClip.middle._width - endOfPathOffset;
					tempObj.pathOffset = falseClip._width;
				}

				var tempClip = eval("branchClose" + tempObj.clipNum);
				if (doMoves) {
					tempClip.swapDepths(get_topLevel()+ 1000*surveyDepth);
					tempClip._y = tempObj._y + branchCloseYOffset;
					tempClip._x = tempObj._x + xBranchOffset + tempObj.pathOffset - branchCloseOffset;
				}
				if (tempObj.inBranch == false) {
					xOffset += tempObj.pathOffset + tempClip._width - branchEndOffset - branchFinalXOffset;				
				} else {
					if (tempObj.branchSide === true) {						
						tempObj.inBranch.xBranchTrueOffset += tempClip._width - branchFinalXOffset;
					} else {
						tempObj.inBranch.xBranchFalseOffset += tempClip._width - branchFinalXOffset;
//						trace("*  tempObj.pathOffset="+ tempObj.pathOffset + "\n    tempClip._width =" + tempClip._width + "\n    branchFinalXOffset=" + branchFinalXOffset);
					}
				}
			} else {
				if (branchMode !== "branchClose" && tempObj.inBranch == false) {
					xOffset += tempObj._width - xClipOverhang - branchFinalXOffset;					
				}
			}
			trace("   Done with branch: " + tempObj);
	
		}
	}
}
	
	*/




function zoom ( scale, skipSlider ) {

	switch (scale) {
		case "fit":
			// figure out a scale based on the number of clips.
		break;

		case "full":
			scale = 100;
		break;
		default:
			if ((scale == "" || isNaN(scale) || typeof(scale) != "number") && autoZoom == true) {
				if (currentDragClip != null) {
					scale = Math.round((stageWidth/((totalClipsWidth)*(100/currentScale)))*100);							
				} else {
					scale = Math.round((stageWidth/((totalClipsWidth)*(100/currentScale)))*100);
				}
//				trace("totalClipsWidth = " + totalClipsWidth);
//				trace("currentScale = " + currentScale);
//				trace("Math.round(stageWidth/(totalClipsWidth*(100/currentScale)))*100; = " + (stageWidth/(totalClipsWidth*(100/currentScale)))*100);
			} else {
				if (autoZoom == true) {
					scale = 100;
				} else {
					if (scale == "" || isNaN(scale) || typeof(scale) != "number") {
						scale = currentScale;
					}
				}
			}
		break;

	}
//	trace("\n\nautoZoom=" + autoZoom + "\nscale = " + scale + "\n\n");

	if (currentDragClip !== null) {
		if (scale < midDragZoom) {
			midDragZoom = scale;
		} else {
			scale = midDragZoom;			
		}

	}

	if (scale > 100) {
		scale = 100;
	}
	if (scale < 1) {
		scale = 1;
	}


//	trace("New scale is " + scale + ", old scale was " + currentScale);
	if (scale != currentScale) {
		currentScale = scale;

		// scale all screens and branches to scale.
		for (j in clipArray) {
			//trace("scaling " + clipArray[j] + "to " + currentScale + "%");
			clipArray[j]._xscale = currentScale;
			clipArray[j]._yscale = currentScale;
		}
	}
	
	// set up the offsets
	setup_offsets();

	if (skipSlider !== true) {
		moveSlider(currentScale);		
	}

	if (autoZoom != true) {
		trace("totalClipsWidth*currentScale/100 = " + totalClipsWidth*currentScale/100);
		trace("stageWidth = " + stageWidth);
 		if ((totalClipsWidth*currentScale/100) > stageWidth) {
			scrollNav._visible = true;
		} else {
			scroll(0);
		}
	} else {
		scrollNav._visible = false;
	}
	
	layout_survey();

}

function zoomChecked () {
	autoZoom = true;
	scroll(0);
	zoom();
	layout_survey();
}

function zoomUnchecked () {
	autoZoom = false;
	zoom();	
	layout_survey();
}

function zoomSliderMoved (percentage) {
	hideToolTip();
	zoom(percentage);
	layout_survey();
}

function moveSlider (percentage) {
	zoomNav.moveSlider(percentage, true);
}



function scroll (percentage, doLayout) {
	// relevant vars:
	// totalClipsWidth
	// stageWidth
	// scrollOffset
	// 
	// all we need to do is move startScreen.


	if (percentage == "right") {
		doLayout = true;
		percentage = (currentScrollPct+5 > 100)? 100:currentScrollPct + 5;
		moveScrollSlider(percentage);
	} 
	if (percentage == "left") {
		doLayout = true;
		percentage = (currentScrollPct-5 < 0)?0:currentScrollPct - 5;
		moveScrollSlider(percentage);
	}
	
	
	if (totalClipsWidth > stageWidth) {
		scrollOffset = (percentage/100)* (totalClipsWidth-(stageWidth/2))
		startScreen._x = initalStartScreenPos - scrollOffset;
		moveScrollSlider(percentage);
	} else {
		startScreen._x = initalStartScreenPos;
		moveScrollSlider(0);
		scrollNav._visible = false;
	}
	currentScrollPct = percentage;
	if (doLayout===true) {
		zoom();
		layout_survey();
	}
}

function scrollSliderMoved (percentage) {
	scroll(percentage, true);

}

function moveScrollSlider (percentage) {
	scrollNav.moveSlider(percentage, true);
}


function setup_offsets () {
	var scaleMultiplier = currentScale/100;
	xClipOverhang 		= scaleMultiplier * xClipOverhangBase;
	xBranchOffset		= scaleMultiplier *	xBranchOffsetBase;
	yBranchOffset		= scaleMultiplier * yBranchOffsetBase;
	branchXCentering	= scaleMultiplier *	branchXCenteringBase;
	branchYCentering	= scaleMultiplier *	branchYCenteringBase;
	screenXCentering	= scaleMultiplier *	screenXCenteringBase;
	screenYCentering	= scaleMultiplier *	screenYCenteringBase;
	baseScreenWidth		= scaleMultiplier *	screen0._width;
	baseBranchWidth		= scaleMultiplier *	(branch0._width + branchClose0._width + branchPath0._width);
	branchBaseOffset 	= scaleMultiplier *	16;
	branchEndOffset 	= scaleMultiplier *	7.5;
	branchScrTrueYOffset= scaleMultiplier *	+12;
	branchScrFalseYOffset=scaleMultiplier *	-14;
	branchTrueYOffset	= scaleMultiplier *	-32;
	branchFalseYOffset 	= scaleMultiplier *	-59;
	branchCloseOffset 	= scaleMultiplier *	52;
	branchFinalXOffset 	= scaleMultiplier *	130;
	branchCloseYOffset	= scaleMultiplier * -50;
	nestingOffset		= scaleMultiplier * baseNestingOffset;
}

function save_survey () {
	// save the survey. 
	// either dump as XML, ajax, or post the data.
}

function load_survey () {
	// load the survey
	// either loading from a URL encoding, XML file, or ajax-javascript bridge.
}

function drag_sound(soundtype) {
	if (soundtype == "hit") {
		//dragSounds.gotoAndPlay("hit");
	} else {
		dragSounds.gotoAndPlay("lock");
	}
}

function dragging_started ( clip ) {
	// the drag has started with a particular clip. 
	trace("**** Dragging Started: " + clip);

	if (toolTipShowing != true || toolTipClip.currentClip != clip) {
		startingX = _root._xmouse;
		startingY = _root._ymouse;
		var now = new Date();
		dragStartTime = now.getUTCMilliseconds;		
	} 
	hideToolTip();
	hideBranchTip();

	clearInterval(dragIntervalObj);

//	clip.onMouseMove = false;

	// pull it out of the flow.
	pull_clip_from_survey(clip);
	
	clip.startDrag(true);
	currentDragClip = clip;
	midDragZoom = currentScale;
	
	// hide the border, show the unlocked border
	clip.lockedBorder._visible = false;
	clip.unlockedBorder._visible = true;
	clip.trueStretch.gotoAndStop("unlocked");
	clip.falseStretch.gotoAndStop("unlocked");
	clip.top.gotoAndStop("unlocked");
	clip.bottom.gotoAndStop("unlocked");
	clip.mainBorder.gotoAndStop("unlocked");
	
	// pull it to the top level
	clip.swapDepths(get_topLevel() + 10000);
	

	
	// if it's a branch, kill the other parts.
	if (clip.clipType == "branch") {
		tempObj = eval("branchClose" + clip.clipNum);
	//	clip.branchEndYoungerSibling = tempObj.youngerSibling;
		delete_screen(tempObj);

		tempObj = eval("truePath" + clip.clipNum);
		delete_screen(tempObj);

		tempObj = eval("falsePath" + clip.clipNum);
		delete_screen(tempObj);
		
		clip.branchCreated = false;

	}
	
/*	clip.onMouseMove = function() {
		pull_clip_from_survey(currentDragClip);
		check_drag_hits(currentDragClip);
	};
*/	
	dragIntervalObj = setInterval(drag_actions, 150, clip );
	
	clip.inSequence = false;
	

}

function drag_actions (clip, override) {
	if (prevMouseX != _root._xmouse || prevMouseY != _root._ymouse || override===true) {
		if (clip.inSequence ==true) {
			pull_clip_from_survey(clip);			
		}
		check_drag_hits(clip);			
		prevMouseX = _root._xmouse;
		prevMouseY = _root._ymouse;
	}
}

function dragging_stopped (clip) {
	// stop dragging
	//clip.onMouseMove = false;
	clearInterval(dragIntervalObj);
	clip.stopDrag();
	currentDragClip = null;

	if (_root._xmouse == startingX && _root._ymouse == startingY) {
		// the user clicked, but didn't drag.
		var now = new Date();
		var nowMS = now.getUTCMilliseconds;
		trace("single-click. checking..");

		if ((toolTipShowing == true || clip.clipType =="branch") && (dragStartTime+1300 > nowMS) ) {
			trace("double-click. Go into screen edit mode");
			if (clip.clipType =="branch") {
				gotoAndStop("branchEdit");
			}
		} else {
			if (clip.clipType =="branch") {
				showBranchTip(clip);
			} else {
				showToolTip(clip);
			}
		}
		drag_actions(clip,true);
	} else {
		



	
	// check for deletion
	if (clip.hitTest(trashCan)) {
		// delete it.

		delete_screen(clip);

	} else {

		drag_actions(clip, true);		
		//TODO: if the dragged clip is a branch AND it was just created, we also need to duplicate a branchClose0 and two branchPath0's
		if (clip.clipType === "branch") {
			createBranchSupportsAndClose(clip);
		} 


		}
		if (clip.inSequence == true) {
			drag_sound("lock");
		}

	}
	zoom();
	layout_survey();
}

function createBranchSupportsAndClose (clip) {
			branchClose0.duplicateMovieClip("branchClose" + clip.clipNum);
			tempObj = eval("branchClose" + clip.clipNum);
			add_to_clipArray(tempObj);
			tempObj.swapDepths(get_topLevel()+2);
			tempObj._visible = true;
			tempObj._xscale = currentScale;
			tempObj._yscale = currentScale;
			if (clip.branchEndYoungerSibling !== false) {
				tempObj.youngerSibling = clip.branchEndYoungerSibling;
				clip.branchEndYoungerSibling = false;
			} else {
				tempObj.youngerSibling = false;
			}

			tempObj.olderSiblingTrue = false;
			tempObj.olderSiblingFalse = false;
			tempObj.clipType = "branchClose";
			//clip.youngerSibling = tempObj;
			tempObj.olderSibling = clip;
			tempObj.youngerSibling = false;
			tempObj.inSequence = true;
			tempObj.clipNum = clip.clipNum;
			tempObj.parent = clip;

			branchPath0.duplicateMovieClip("truePath" + clip.clipNum);
			tempObj = eval("truePath" + clip.clipNum);
			add_to_clipArray(tempObj);
			tempObj.swapDepths(get_topLevel());
			tempObj._visible = true;
			tempObj._xscale = currentScale;
			tempObj._yscale = currentScale;
			tempObj.clipType = "branchPath";
			tempObj.inSequence = true;
			tempObj.branchSide = true;
			tempObj.clipNum = clip.clipNum;
			tempObj.parent = clip;

			branchPath0.duplicateMovieClip("falsePath" + clip.clipNum);
			tempObj = eval("falsePath" + clip.clipNum);
			add_to_clipArray(tempObj);
			tempObj.swapDepths(get_topLevel()-2);
			tempObj._visible = true;
			tempObj._xscale = currentScale;
			tempObj._yscale = currentScale;
			tempObj.clipType = "branchPath";
			tempObj.inSequence = true;
			tempObj.branchSide = false;
			tempObj.clipNum = clip.clipNum;
			tempObj.parent = clip;
			
			
			trace("BRANCH AND SUPPORTS CREATED.")
			clip.branchCreated = true;
			
}



function check_drag_hits (clip) {
	
	
			var hitsArr = new Array();
			// loop through clipArray, 
			for (j=0; j<clipArray.length; j++) {
				tempClip = clipArray[j];
				// check for hittest between clip.olderSiblingHit and tempClip.youngerSiblingHit or tempClip.trueSiblingHit/falseSiblingHit
				if (clip !== tempClip) {
					//trace("checking.. \ntempClip = " + tempClip + "\nclip = " + clip);
					// test: pull this out.
					//(tempClip.clipType=="branch" && (clip.olderSiblingHit.hitTest(tempClip.trueChildHit) || clip.olderSiblingHit.hitTest(tempClip.falseChildHit))) ||
					if (tempClip.inSequence == true && ( (tempClip.clipType == "screen" && clip.olderSiblingHit.hitTest(tempClip.youngerSiblingHit)) || (tempClip.clipType == "branchClose" && clip.olderSiblingHit.hitTest(tempClip.youngerSiblingHit))  ||  (tempClip.clipType == "branchPath" && clip.olderSiblingHit.hitTest(tempClip) ) )) {
						hitsArr.push (tempClip);
					}

	 			}
			}




			trace (hitsArr.length + " hits:\n"+hitsArr);
			// All Possibilities:
			/*
			// Checking for hits on: screen, branchPaths, branchClose.youngerSiblings
			
			No Hits
				- hitsArr.length == 0

			Else
				
				
			If there's a branchpath hit:
				
		    // Screen onto a blank branchPath
				- hitsArr.length == 1 || 2, hitsArr[n].clipType == "branchPath" && hitsArr[n].parent.youngerSibling[BranchPathT/F] == false
				
				
				
			// Screen onto a branchPath (after existing screen)
				- hitsArr.length == 1..3, hitsArr[n].clipType == "screen,branchClose", hitsArr[n].youngerSibling == false
				
				
			// Screen onto a branchPath (before existing screen, not first)
				- hitsArr.length == 1..3, hitsArr[n].clipType == "screen", hitsArr[0].youngerSibling == hitsArr[1] || vice versa
				
				
			// Branch onto a blank branchPath
				- hitsArr.length == 1..2, hitsArr[n].clipType == "branchPath", hitsArr[0].youngerSibling == hitsArr[1] || vice versa
				
				
			// Branch onto a branchPath (after existing)
				- hitsArr.length == 1..2, hitsArr[n].clipType == "screen,branchClose", hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Branch onto a branchPath (before/between existing)
				- hitsArr.length == 1..3, hitsArr[n].clipType == "screen", hitsArr[0].youngerSibling == hitsArr[1] || vice versa	
				
			Else	
				

			// Branch onto end (branchClose is last)
				- hitsArr.length == 1, hitsArr[0].youngerSibling == false
			// Screen onto end (screen is last)
				- hitsArr.length == 1, hitsArr[0].youngerSibling == false
			// Screen onto end (branchClose is last)
				- hitsArr.length == 1, hitsArr[0].youngerSibling == false
			// Branch onto end (screen is last)
				- hitsArr.length == 1, hitsArr[0].youngerSibling == false

				
				
			// Screen between 2 screens
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Screen between a screen and branch
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Screen between a branch and screen
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Branch between 2 screens
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Branch between a screen and branch
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa
			// Branch between a branch and screen
				- hitsArr.length == 2, hitsArr[0].youngerSibling == hitsArr[1] || vice versa

						
			//*/

			var inBranch = false;
			var branchOverride = false;
			for (j in hitsArr) {
				if (hitsArr[j].clipType == "branchPath") {
					branchSide = hitsArr[j].branchSide;
					inBranch = hitsArr[j];
				}
				
			}
			if (inBranch !== false) {
				drag_sound("hit");

				//TODO: Implement the below
				
				if (hitsArr.length == 1) {

				
					var onlyInPath = true;
				// Screen onto a blank branchPath / first screen?
				//	- hitsArr.length == 1 || 2, hitsArr[n].clipType == "branchPath" && hitsArr[n].parent.youngerSibling[BranchPathT/F] == false

					branchClip = inBranch.parent;
					trace("** clip = " + clip);
					trace("in branch? yes in "+ branchClip +", on the " + branchSide + " side.");	
					trace("checking around:\nbranchClip.olderSibling.youngerSiblingFalse=" + branchClip.olderSibling.youngerSiblingFalse)			

					
			
					// check to see if it is also hitting the branch root, or the first clip.  If not, then it's at the end.
					firstChildToCheck = (branchSide) ? branchClip.youngerSiblingTrue : branchClip.youngerSiblingFalse;
					if (firstChildToCheck == false || (clip.hitTest(branchClip) || clip.hitTest(firstChildToCheck)) ) {
						if (branchSide === true) {
							if (branchClip.youngerSiblingTrue !== false && branchClip.youngerSiblingTrue != clip) {
								oldFirstClip = branchClip.youngerSiblingTrue;
								oldFirstClip.olderSibling = clip;
								clip.youngerSibling = oldFirstClip;
								onlyInPath = false;
							}
							clip.branchSide = true;
							branchClip.youngerSiblingTrue = clip;

						}
						if (branchSide === false) {
							if (branchClip.youngerSiblingFalse !== false && branchClip.youngerSiblingFalse != clip) {
								oldFirstClip = branchClip.youngerSiblingFalse;
								oldFirstClip.olderSibling = clip;
								clip.youngerSibling = oldFirstClip;
								onlyInPath = false;
							}
							clip.branchSide = false;
							branchClip.youngerSiblingFalse = clip;
						}

						clip.olderSibling = branchClip;
						if (onlyInPath==true) {
							clip.youngerSibling = false;						
						}						
						
					} else {
						// it needs to go to the end.
						clip.youngerSibling = false;
						var endOfTheBranch = firstChildToCheck;
						while (endOfTheBranch.youngerSibling !== false && typeof(endOfTheBranch) != "undefined") {
							endOfTheBranch = endOfTheBranch.youngerSibling;
						}
						clip.olderSibling = endOfTheBranch;
						endOfTheBranch.youngerSibling = clip;

					}

					clip.inBranch = branchClip;
					clip.inSequence = true;

				} else {
					// Screen onto a branchPath (after existing screen)
					//	- hitsArr.length == 1..3, hitsArr[n].clipType == "screen,branchClose", hitsArr[n].youngerSibling == false


					// Screen onto a branchPath (before existing screen, not first)
					//	- hitsArr.length == 1..3, hitsArr[n].clipType == "screen", hitsArr[0].youngerSibling == hitsArr[1] || vice versa

					branchOverride = true;

				}




				// Branch onto a blank branchPath
				//	- hitsArr.length == 1..2, hitsArr[n].clipType == "branchPath", hitsArr[0].youngerSibling == hitsArr[1] || vice versa


				// Branch onto a branchPath (after existing)
				//	- hitsArr.length == 1..2, hitsArr[n].clipType == "screen,branchClose", hitsArr[0].youngerSibling == hitsArr[1] || vice versa
				// Branch onto a branchPath (before/between existing)
				//	- hitsArr.length == 1..3, hitsArr[n].clipType == "screen", hitsArr[0].youngerSibling == hitsArr[1] || vice versa	
			    
				
				
				
				
			} 
			
			if (inBranch == false || branchOverride == true) {
				switch (hitsArr.length) {
					case 0: 
						// if there's no hit, leave it where it is.
						trace("Pulling it out of the layout.")
						clip.inSequence = false;
					break;

					case 1: 
						// if there's one hit, (or the multiples are resolved)
						trace("single hit");
						drag_sound("hit");

						// update older and younger variables
						tempClip = hitsArr[0];
						
						if (tempClip.clipType == "branchClose" && clip.inBranch == false) {

							tempBranch = tempClip.olderSibling;
							clip.youngerSibling = tempBranch.youngerSibling;
							tempBranch.youngerSibling = clip;
							clip.olderSibling = tempBranch;
							tempYoungClip = tempClip.youngerSibling;
							if (tempYoungClip == clip) {
								tempYoungClip.youngerSibling = clip.youngerSibling;
							}
							tempYoungClip.olderSibling = clip;
						} else {
							if ( tempClip.youngerSibling !== false && (tempClip.olderSibling != false || tempClip==startScreen) ){
								// it's been dropped on an existing clip. Put it after it.
									trace("it's been dropped on an existing clip. Put it after it.\n:in between" + tempClip + " and " + tempClip.youngerSibling);
									if (tempClip.youngerSibling != false) {
										tempYoungClip = tempClip.youngerSibling;
										if (tempYoungClip == clip) {
											tempYoungClip.youngerSibling = clip.youngerSibling;
										}
										tempYoungClip.olderSibling = clip;
										clip.youngerSibling = tempYoungClip;								
									} else {
										clip.youngerSibling = false;
									}
							} else {
								clip.youngerSibling = false;
							}	
							clip.olderSibling = tempClip;						
							tempClip.youngerSibling = clip;								
						}

						clip.inSequence = true;
					break;

					case 2: 
						drag_sound("hit");
						if (branchOverride==true) {
							tempClip = (hitsArr[0].clipType == "branchPath") ? hitsArr[1] : hitsArr[0];
							if (tempClip.clipType == "branchClose") {
								pathClip = (hitsArr[0].clipType == "branchPath") ? hitsArr[0] : hitsArr[1];
								tempBranch = tempClip.parent;
								clip.youngerSibling = tempBranch.youngerSibling;
								tempBranch.youngerSibling = clip;
								clip.olderSibling = tempBranch;
								tempYoungClip = clip.youngerSibling;
								if (tempYoungClip == clip) {
										clip.youngerSibling = false;
								}
								tempYoungClip.olderSibling = clip;
								
								trace("branchClose inside, tempBranch=" + tempBranch + "\n tempBranch.youngerSibling = " + tempBranch.youngerSibling);
								
								clip.inBranch = tempBranch.inBranch;
								clip.branchSide = pathClip.branchSide;
							} else {
	//							trace("^^ tempClip=" + tempClip + "\n^^ pathClip=" + pathClip);		
								if (tempClip.clipType == "branch") {
									pathClip = (hitsArr[0].clipType == "branchPath") ? hitsArr[0] : hitsArr[1];
									if (pathClip.branchSide === true) {
										clip.youngerSibling = tempClip.youngerSiblingTrue;
										tempClip.youngerSiblingTrue = clip;
									} else {
										clip.youngerSibling = tempClip.youngerSiblingFalse;
										tempClip.youngerSiblingFalse = clip;
									}
									clip.olderSibling = tempClip;
									clip.inBranch = tempClip;

									clip.branchSide = pathClip.branchSide;							
								} else {
									pathClip = (hitsArr[0].clipType == "branchPath") ? hitsArr[0] : hitsArr[1];
									clip.youngerSibling = tempClip.youngerSibling;
									tempClip.youngerSibling = clip;
									clip.olderSibling = tempClip;
									clip.inBranch = pathClip.parent;
									clip.branchSide = tempClip.branchSide;								
								}

								tempYoungClip = clip.youngerSibling;
								tempYoungClip.olderSibling = clip;								
							}

						} else {
							if (hitsArr[0].youngerSibling == hitsArr[1] && hitsArr[1].olderSibling == hitsArr[0]) {
								trace("in between" + hitsArr[0] + " and " + hitsArr[1]);	
								hitsArr[0].youngerSibling = clip;
								clip.olderSibling = hitsArr[0];
								hitsArr[1].olderSibling = clip;
								clip.youngerSibling = hitsArr[1];

							}
							if (hitsArr[1].youngerSibling == hitsArr[0] && hitsArr[0].olderSibling == hitsArr[1]) {
								trace("in between" + hitsArr[1] + " and " + hitsArr[0]);	
								hitsArr[1].youngerSibling = clip;
								clip.olderSibling = hitsArr[1];
								hitsArr[0].olderSibling = clip;
								clip.youngerSibling = hitsArr[0];
							}
						}
					

						clip.inSequence = true;		
						
						
						// etc:  check to see if the length is 2, and the hits are branchPath and screen

						// All Possibilities:
						// No Hits
						// Screen onto end (screen is last)
						// Screen onto end (branchClose is last)
						// Branch onto end (screen is last)
						// Branch onto end (branchClose is last)
						// Screen between 2 screens
						// Screen between a screen and branch
						// Screen between a branch and screen
						// Branch between 2 screens
						// Branch between a screen and branch
						// Branch between a branch and screen
					    // Screen onto a blank branchPath
						// Screen onto a branchPath (after existing screen)
						// Screen onto a branchPath (before existing screen)
						// Branch onto a blank branchPath
						// Branch onto a branchPath (after existing)
						// Branch onto a branchPath (before/between existing)


						// if there's more than one hit, there are two possibilities:
						// 1.  the clip was dropped "in between" two clips.
						// 2.  the clip was dropped somewhere in the branch path.
						// 3.  the clip was dropped on a valid clip, and one that just happens to be sitting there. - this is now trapped for in the hittest.

						// DONE - we trap for #3 by making sure that we're dealing with clips that are in the sequence. (clip.inSequence == true)
						// we can trap for #2 by checking the clipType of the dropset.
						// we can trap for #1 by checking to see if there are 2 relevant hits, and the youngerSibling and olderSiblings match.

						// once we know where it sits, we just update the youngerSibling and olderSiblings and youngerSiblingFalse, etc.

						/*
						// choose to place clip into the middle of the two
							// see if the clips show up in the nav tree.
							var inBranch = 0;
							var branchSide = null;
							var branchClip = null;
							var inBetweenTwo = false;

							var tempObj = startScreen;


						//	while (tempObj.youngerSibling !== false && typeof(tempObj) != "undefined") {
							/*
								for (tempClip in hitsArr) {
									trace("inside, checking "+ hitsArr[tempClip]);
									if (hitsArr[tempClip].clipType == "branch") {
										inBranch++;
										branchClip = hitsArr[tempClip];
									}
									if (hitsArr[tempClip].clipType == "branchPath") {
										branchSide = hitsArr[tempClip].branchSide;
										inBranch++;
									}

								}
								inBranch = (inBranch==2) ? true : false;
								*/
						//		tempObj = tempObj.youngerSibling;
						//	}
					break;	
				}
			}

						
		
		zoom();
}

function add_to_clipArray (newClip) {
	var inArray = true;
	for (j=0; j<clipArray.length; j++) {
		if (clipArray[j] == newClip) {
			inArray = false;
		}
	}
	if (inArray == true) {
		clipArray.push(newClip);
	}
}

function pull_clip_from_survey (clip) {
	// re-adjust its parents and children.
	
	// the method below *should* work.
	if (debugMode) {
		trace("pull_clip_from_survey:\n  clip="+clip+"\n  clip.inBranch=" + clip.inBranch+"\n  clip.branchSide=" + clip.branchSide + "\n  clip.olderSibling=" + clip.olderSibling + "\n  clip.youngerSibling=" + clip.youngerSibling);
	}

		tempObj = clip.olderSibling;
		if (clip.clipType == "branch") {
			// TODO: warn some people!!		
			clip.youngerSiblingTrue = false;
			clip.youngerSiblingFalse = false;
		} 
		
		if (tempObj.clipType == "branch") {
			if (clip.inBranch != false) {
				trace((debugMode)?"pulling out of a branch!":"");
				if (clip.branchSide == true) {
					tempObj.youngerSiblingTrue = clip.youngerSibling;				
				} else {
					tempObj.youngerSiblingFalse = clip.youngerSibling;				
				}				
				clip.inBranch = false;
				clip.branchSide = null;
			} else {
				tempObj.youngerSibling = clip.youngerSibling;
			}
		} else {
			tempObj.youngerSibling = clip.youngerSibling;							
		}

		if (tempObj.olderSibling == clip && clip.olderSibling != tempObj) {
			tempObj.olderSibling = clip.olderSibling;
		} 


	
		if (clip.youngerSibling != false) {
			tempObj = clip.youngerSibling;
			tempObj.olderSibling = clip.olderSibling;
			if (tempObj.youngerSibling == clip && clip.youngerSibling != tempObj) {
				tempObj.youngerSibling = clip.youngerSibling;
			}
		}
	

		if (debugMode) {
			tempOld = clip.olderSibling;
			tempYoung = clip.youngerSibling;
			trace("pulled: _clip_from_survey:\n  clip="+clip+"\n  clip.olderSibling=" + clip.olderSibling + "\n  clip.youngerSibling=" + clip.youngerSibling + "\n  younger.olderSibling="+tempYoung.olderSibling + "\n  older.youngerSibling="+tempOld.youngerSibling);		
		}

	// take it out of the loop
	clip.olderSibling = false;
	clip.youngerSibling = false;

	// re-dash it.
	clip.lockedBorder._visible = false;
	clip.unlockedBorder._visible = true;
	clip.inSequence = false;
	clip.inBranch = false;
	
}

function setMetaData (clip) {
	clip.screenName = clip.title;
	clip.section = clip.section;
	clip.percentText = clip.percentText;
	clip.modulesText = clip.modulesText;
} 


function clearMetaData (clip) {
	
}

function showToolTip(clip) {

//	if (clip.inSequence) {
		// currentDragClip == null && currentScale < 80) {
		branchTipClip._visible = false;
//		toolTipClip._visible = false;
		toolTipClip._y = -4000;
		branchTipShowing = false;
//		toolTipClip.swapDepths(getNextHighestDepth());
		toolTipClip._visible = true;
		toolTipClip.currentClip = clip;
		toolTipClip.screenTitle.text = clip.title;
		toolTipClip.sectionText.text = clip.section;
		toolTipClip.percentText.text = clip.percentDone;
		var modText = "";
		var tempMods = clip.modules;
//		tempMods.sort();
		prevMod = "asdkfj2";
		for (var k=0; k< tempMods.length; k++) {
			var thisMod = clip.modules[k].friendlyName;
			if (thisMod != prevMod) {
				modText += thisMod + ", ";
			}
			prevMod = thisMod;
		}
		modText = "Modules: " + modText.slice(0,-2);
		toolTipClip.modulesText = modText;
		toolTipClip._x = clip._x - branchBaseOffset;
		toolTipClip._y = clip._y - (clip._height/2.6);
		toolTipShowing = true;

//		trace("toolTipClip.getDepth() = " + toolTipClip.getDepth());
//		trace("branchTipClip.getDepth() = " + branchTipClip.getDepth());
	
}

function saveToolTipInfo (clip) {
		trace("clip = " + clip);
		clip.title = toolTipClip.screenTitle.text;
		clip.section = toolTipClip.sectionText.text;
		clip.percentDone = toolTipClip.percentText.text;
		hideToolTip(clip, true);
}


function hideToolTip(clip, override) {
	if (clip != toolTipClip.currentClip || override === true) {
		toolTipClip._y = -4000;
//		toolTipClip._visible = false;
		toolTipShowing = false;
		
	}
	branchTipClip._visible = false;
	branchTipShowing = false;
}


function showBranchTip (clip) {
//		branchTipClip.swapDepths(99999998);	
		branchTipClip._visible = true;
		branchTipClip.currentClip = clip;
		branchTipClip.leftValue = clip.leftValue;
		branchTipClip.rightValue = clip.rightValue;
		branchTipClip.operation = clip.operation;
		branchTipClip._x = clip._x - branchBaseOffset;
		branchTipClip._y = clip._y - clip._height/3;
		branchTipShowing = true;
		toolTipClip._y = -4000;
//		toolTipClip._visible = false;
		toolTipShowing = false;
}

function hideBranchTip (clip, override) {
	if (clip != branchTipClip.currentClip || override === true) {
		branchTipClip._visible = false;
		branchTipShowing = false;	
	}
	toolTipClip._y = -4000;
//	toolTipClip._visible = false;
	toolTipShowing = false;
	
}

function saveBranchData () {
	branchTipClip.currentClip.leftValue = variableChooser1.value;
	branchTipClip.currentClip.rightValue = variableChooser2.value;
	branchTipClip.currentClip.operation = operationsArr[operationsChooser.selectedIndex];
}

function list_screens() {
	// this function needs to run through cliparray, and dump back all screens (not branches)
	// returns an array of hashes:  clipNums => clip.names.
	listOfScreens = new Array();
	for (j=1; j<=clipArray.length; j++) {
		if (clipArray[j].clipType == "screen" && clipArray[j] != currentEditScreen) {
			listOfScreens.push({clipNum:clipArray[j].clipNum,clipName:clipArray[j].title});
		}
	}
	if (listOfScreens == []) {
		listOfScreens = [{clipNum:0,clipName:"No screens in the survey!!"}];
	}

	return listOfScreens;
}


function delete_screen (clip) {
	// check whether it's a screen or branch
	
	// remove it from clipArray
	for (j=0; j<clipArray.length; j++) {
		if (clipArray[j] == clip) {
			clipArray.splice(j,1)
		}
	}


	pull_clip_from_survey(clip);

	// remove it from the stage
	clip.removeMovieClip();
	
}

function new_clip(screenType,loadingOverride) {
	// called when someone clicks on the new screen or branch button.
	// duplicate screen0
	clipNumber++;
	
	baseClip = eval (screenType + "0");
	baseClip.duplicateMovieClip(screenType + clipNumber,get_topLevel());

		
	// set it to 100%
	tempObj = eval(screenType + clipNumber);
	tempObj._visible = true;
	tempObj._xscale = currentScale;
	tempObj._yscale = currentScale;
	
	// offset it a bit
	// This is now handled by locking the drag handler
	/*
	tempObj._x = _root._xmouse - (tempObj._width/3);
	tempObj._y = _root._ymouse - (tempObj._height/3);
	if (screenType == "branch") {
		tempObj._y += 50 * (currentScale/100);
	}
	*/
	
	// add it to clipArray
	add_to_clipArray(tempObj);
	
	init_clip(tempObj, screenType)
	
	if (loadingOverride !== true) {
		// start it dragging: 
		dragging_started(tempObj);		
	} else {
		tempObj._x = 200;
		tempObj._y = 200+clipNumber;
	}
	
	return tempObj;
}


function init_clip (clipObj, clipType) {
	// initialize the screen or branch
	clipObj.olderSibling = false;
	clipObj.youngerSibling = false;
	clipObj.clipNum = clipNumber;
	clipObj.inBranch = false;
	clipObj.branchSide = null;
	clipObj.title = "Untitled " + clipNumber;
	clipObj.percentDone = 0;
	clipObj.section = "";
	clipObj.hasBeenAdded = false;
	clipObj.modules = new Array();
	if (clipType == "screen") {
		clipObj.clipType = "screen";
		clipObj.saveChanges = function () {
			trace("saving for " + clipObj.nameText.text);
			clipObj.title = clipObj.nameText.text;
		}
		
		
	} else {
		clipObj.youngerSiblingTrue = false;
		clipObj.youngerSiblingFalse = false;
		clipObj.branchEndYoungerSibling = false
		clipObj.clipType = "branch";
		clipObj.xBranchTrueOffset = basePathWidth * currentScale/100;
		clipObj.xBranchFalseOffset = basePathWidth * currentScale/100;
		clipObj.operation = "equals";
	}

}

function module (name, friendlyName) {
	this.name = name;
	this.friendlyName = friendlyName;
	this.params = new Array();
}

function parameter (name, value, mode, type, helpText) {
	this.name = name;
	this.value = value;
	this.mode = mode;
	this.type = type;
	this.helpText = helpText;
}

function loadModulesList () {
//	modulesXML = new XML();
//	modulesArr = new Array();

	modulesXML.ignoreWhite = true;
	modulesXML.onLoad = function (status) {
		tempXML = modulesXML.firstChild.firstChild;
//		trace(tempXML);
		do {
			tempModule = new module(tempXML.attributes.name, tempXML.attributes.friendlyName);
			if (tempXML.childNodes.length > 0) {
//				trace("has params");
				tempChild = tempXML.firstChild;
				tempParam = new parameter("internalName", "", "const", "string","The internal name to use for this screen. Useful if you need to refer to the screen in a branch, or for data saving.");
				tempModule.params.push(tempParam);
				do {					 
					tempParam = new parameter(tempChild.attributes.name, tempChild.attributes.defaultValue, tempChild.attributes.mode, tempChild.attributes.type, tempChild.attributes.helpText);
					tempModule.params.push(tempParam);
				} while (tempChild = tempChild.nextSibling);

			}
			modulesArr.push(tempModule);
//			trace("tempMod: " + tempModule.name + ".  Params: " + tempModule.params);
		} while (tempXML = tempXML.nextSibling);
//		trace("modulesArr = " + modulesArr);
	}
	modulesXML.load("./Controls/modules.xml");
}


function loadCurrentScreenModules (modulesArr,doPlay) {
		numModulesToLoad = 0;
		numModulesLoaded = 0;
		unloadModules(true);
		trace("currentEditScreen.modules = " + currentEditScreen.modules);
		// determine layering
		currentEditScreen.modules.sortOn("layer",1);
		for (k=0; k<currentEditScreen.modules.length; k++) {
			if ( typeof(currentEditScreen.modules[k].layer) == "undefined") {
				currentEditScreen.modules[k].layer = k;
			} else {
				if (currentEditScreen.modules[k].layer <= currentEditScreen.modules.length) {
					currentEditScreen.modules[k].layer += currentEditScreen.modules.length;
				} 
			}
			trace("leaving " + currentEditScreen.modules[k].name + " at layer " + currentEditScreen.modules[k].layer);
		}
		currentEditScreen.modules.sortOn("layer",1);

		// do the actual load
		for (k=0; k<currentEditScreen.modules.length; k++) {
			numModulesToLoad ++;
			trace("** currentEditScreen.modules[k] name = " + currentEditScreen.modules[k].name);
			currMod = currentEditScreen.modules[k];
			currMod.tempClip = new MovieClipLoader();
			currMod.tempListener = new Object();
			currMod.tempListener.onLoadInit = function (loadedClip)	{
				// kill listener
				loadedClip.removeListener(tempListener);
				// call counter.  God, I hate flash sometimes.	
				checkScreenLoadingComplete(loadedClip);
			}
			currMod.tempListener.onLoadError = function (loadedClip)	{
				// kill listener
				loadedClip.removeListener(tempListener);
				// call counter.  God, I hate flash sometimes.	
				checkScreenLoadingComplete(loadedClip);
			}

			currMod.tempClip.addListener(currMod.tempListener);
//			trace("("+currMod.name+")currMod.layer = " + currMod.layer);
			currMod.layer = k;
//			trace("("+currMod.name+")currMod.layer = " + currMod.layer);
			newLevel = baseModuleLevel + k;
			currentModuleLevels.push(newLevel);
			_level0.createEmptyMovieClip("layer"+newLevel, newLevel);
			currMod.tempClip.loadClip("Controls/" + currMod.name + ".swf","_level0.layer"+newLevel);
		}		
}



function checkScreenLoadingComplete (newestModule) {
	numModulesLoaded ++;
	if (numModulesLoaded == numModulesToLoad) {
		numModulesLoaded = 0;
		numModulesToLoad = 0;
		screenLayoutInit();
	}
}


clipMouseDownFunction = function () {
	if (!this.locked && this.hitTest( _root._xmouse, _root._ymouse)) {
		this.startDrag(false,leftEdge,topEdge,rightEdge+(loadedClip._width/2),bottomEdge+(loadedClip._height/2)); 	
		this.dragging = true;
		this._alpha = 65;
		// highlight

		hideLayoutInstructions();
	}
}

function screenLayoutInit () {
	// run when all of the clips are loaded.
 		layoutInstructionCounter = 0;
		var curClipMatched = false;
		trace("currentEditScreen = " + currentEditScreen);
		for (k=0; k<currentEditScreen.modules.length; k++) {
			trace("currentModuleLevels["+k+"]=" + currentModuleLevels[k]);
			loadedClip = "_level0.layer" + currentModuleLevels[k];
			loadedClip = eval(loadedClip);
			
			currMod = currentEditScreen.modules[k];
			loadedClip.linkedMod = currentEditScreen.modules[k];

			// set variables
			loadedClip.params = currMod.params;
			loadedClip.name = currMod.name;
			loadedClip.layer = currMod.layer;
			loadedClip.myName = currMod.name;
			loadedClip.EVENT_MODULE_INITALIZE = 0;
						
			// special case for widget_text
			// &lt;font face='Helvetica' size='12'&gt;
			if (loadedClip.name == "widget_text") {
				if (currentEditScreen.modules[k].modified != true) {
					loadedClip.params.splice(1,0,new parameter ("Font", "Helvetica", "variable", "string", "The name of the font you would like to use."));
					loadedClip.params.splice(1,0,new parameter ("Size", "18", "variable", "integer", "The font size you would like to use."));
					loadedClip.params.splice(1,0,new parameter ("Text", "Sample Text\nSample Text\nSample Text", "variable", "cdata", "The text to display. This will update the textValue field below."));
				}
				var foundVal = loadedClip.params.length-1;
				var sizeParam = "";
				var faceParam = "";
				var textParam = "";
				for (m=0; m<loadedClip.params.length; m++) {
					if (loadedClip.params[m].name == "textValue") {
						foundVal = m;
					}
					if (loadedClip.params[m].name == "Size") {
						sizeParam = m;
					}
					if (loadedClip.params[m].name == "Font") {
						faceParam = m;
					}
					if (loadedClip.params[m].name == "Text") {
						textParam = m;
					}
				}
				var parseString = loadedClip.params[textParam].value;
				if (sizeParam != "" || faceParam != "" || textParam != "") {
					var tempIndex = parseString.indexOf("\n");
					if (tempIndex < 0) {
						var tempString = "";
					} else {
						var tempString = parseString.substring(0,tempIndex);
					}
					trace("parseString = " + parseString);
					while (parseString != "" && tempIndex > 0 ) {
						parseString = parseString.substring(tempIndex+1);
						tempString += "<br/>";
						tempIndex = parseString.indexOf("\n");
						tempString += parseString.substring(0,tempIndex-1)
					}
					tempString += parseString;
					trace("sizeParam = " + sizeParam);
					trace("faceParam = " + faceParam);
					loadedClip.params[foundVal].value = "<font " + ((sizeParam != "" && loadedClip.params[sizeParam].value != "" && loadedClip.params[sizeParam].value != null) ? "size=\"" + loadedClip.params[sizeParam].value + "\"" : "") + ((faceParam != "" && loadedClip.params[faceParam].value != "" && loadedClip.params[faceParam].value != null)? " face=\"" + loadedClip.params[faceParam].value + "\"" : "") + "/>" + tempString + "</font>";
				} else {
					//loadedClip.params[foundVal].value = parseString;
				}

				
			}
			currentEditScreen.modules[k].modified = true;
			

			loadedClip.friendlyName = currMod.friendlyName;

			loadedClip._getValue = function (paramName) {
				for (l=0; l< this.params.length; l++) {
					if (this.params[l].name == paramName) {
						tempParam = this.params[l];
						trace("returning " + tempParam.value + " for var " + paramName);
						return tempParam.value;
					}
				} 
			}
			loadedClip.allocNewLevel = function () {
				return _root.get_topLevel();
			}

			
			loadedClip.getValue = function (paramName) {
				for (l=0; l< this.params.length; l++) {
					if (this.params[l].name == paramName) {
						tempParam = this.params[l];
//						trace("returning " + tempParam.value + " for var " + paramName);
						return tempParam.value;
					}
				} 
			}
			
			
			// To automatically load variables.
			for (l=0; l<loadedClip.params.length; l++) {
				loadedClip[loadedClip.params[l].name] = loadedClip.params[l].value
				trace("setting " + loadedClip.params[l].name + " to " + loadedClip.params[l].value + ".");
			}
			//*/
			
			
			// offset x and y

			// set base x, y, layer, scale values
			if (typeof(currMod.scale) == "undefined"  || currMod.scale == null) {				
				loadedClip._xscale = layoutScaling;
				loadedClip._yscale = layoutScaling;
			} else {
				loadedClip._xscale = currMod.scale * layoutScaling/100;
				loadedClip._yscale = currMod.scale * layoutScaling/100;		
				
			}
			if (typeof(currMod.xposition) == "undefined"  || currMod.xposition == null ) {				
				loadedClip._x = 95 + (k*20);
			} else {
				loadedClip._x = Math.round(currMod.xposition * layoutScaling/100) + leftEdge;
			}
			if (typeof(currMod.xposition) == "undefined"  || currMod.yposition == null ) {				
				loadedClip._y = 80 + (k*20);
			} else {
				loadedClip._y = Math.round(currMod.yposition * layoutScaling/100) + topEdge ;
			}
			if (typeof(currMod.locked) == "undefined"  || currMod.locked == null ) {				
				loadedClip.locked = false;
			} else {
				loadedClip.locked = currMod.locked;
				hideLayoutInstructions(true);
			}


			// Highlight Code	
			/*
			loadedClip.moveTo(loadedClip._x,loadedClip._y);
			loadedClip.beginFill(0x88888,25);
			addWidth = loadedClip._width;
			addHeight = loadedClip._height;
			loadedClip.lineTo(loadedClip._x+addWidth,loadedClip._y);
			loadedClip.lineTo(loadedClip._x+addWidth,loadedClip._y+addHeight);
			loadedClip.lineTo(loadedClip._x,loadedClip._y+addHeight);
			loadedClip.lineTo(loadedClip._x,loadedClip._y);	
			loadedClip.endFill();
			//*/

			// drag handlers
			loadedClip.dragging = false;
			loadedClip.onMouseDown = clipMouseDownFunction;
			loadedClip.onMouseMove = function () {
				if (this.hitTest( _root._xmouse, _root._ymouse)) {
					// highlight
					this._alpha = 80;
//					updateTopStats(this);
							
				} else {
					this._alpha = 100;
				}
			}
			loadedClip.onEnterFrame = function () {
				if (typeof(this.numFrames) == "undefined") {
					this.numFrames = 0;
				} else {
					this.numFrames++;
				}
				if (this.numFrames > 1) {
					this.eventHandler(0);
//					this.initalize2();
					this.onEnterFrame = false;					
				}
			}
			loadedClip.onMouseUp = function () {
				this.stopDrag();
				if (this.dragging) {
					// remove highlight
					this.dragging = false;
					this._alpha = 100;
				}
				if (this.hitTest( _root._xmouse, _root._ymouse)) {
					updateTopStats(this);
					loadParams(this);
				}
			}

			trace("loaded " + loadedClip);
			if (loadedClip == topBar.currentClip) {
				curClipMatched = true;
			}
			
			// swap depth to proper.  Somehow, this breaks the dragging.  Flash, I hate you.
			//loadedClip.swapDepths(currentModuleLevels[k]);


		}
		trace("sitting at " + loadedClip.getDepth())
		if (k <= 1) {
			topBar.currentClip = loadedClip;
		}
		if (curClipMatched == false) {
			topBar.currentClip = loadedClip;
		}

		updateTopStats(topBar.currentClip);
		loadParams(topBar.currentClip,true);

		
		trace("############### loaded all clips")
}

function screen () {
	// handled by init_clip
}

function getAllFields () {
	var allFields = new Array();
	// loop through cliparray
	
	// return all fields in the form: [module.name].[fieldName]
	for (j=0; j< clipArray.length; j++) {
		tempClip = clipArray[j];
		for (k=0; k<tempClip.modules.length; k++) {
			tempMod = tempClip.modules[k];
			var title = (typeof(tempClip.title) == "undefined") ? "No-name" : tempClip.title;
			var name = title + "." + tempMod.name;
			for (l=0; l<tempMod.params.length; l++) {
				if (tempMod.params[l].name == "internalName") {
					name = tempMod.params[l].value;
				} 
			}
			for (l=0; l<tempMod.params.length; l++) {
				if (tempMod.params[l].mode == "variable") {
					allFields.push(name + "." + tempMod.params[l].name);					
				}

			}
		}
	}
	
	return allFields
}


function updateTopStats(clip) {
	topBar.currentClip = clip;
	topBar.moduleName = clip.friendlyName;
	clip.linkedMod.xposition = Math.round((clip._x-leftEdge)*100/layoutScaling);
	topBar.moduleX.text = clip.linkedMod.xposition;
	clip.linkedMod.yposition = Math.round((clip._y-topEdge)*100/layoutScaling);
	topBar.moduleY.text = clip.linkedMod.yposition;
	clip.linkedMod.scale = Math.round(clip._xscale * 100/layoutScaling);
	topBar.moduleScale.text = clip.linkedMod.scale;
	if (clip.locked) { topBar.lockIcon.gotoAndStop(1) } else { topBar.lockIcon.gotoAndStop(2); }
	clip.linkedMod.locked = clip.locked

}

var layoutInstructionCounter = 0;
function hideLayoutInstructions (force) {
	layoutInstructionCounter ++;
	if ((layoutInstructionCounter > 2 || force == true) && instructionsShowing == true) {
		play();
		layoutInstructionCounter = -999999999;
	}
}

function unloadModules (keepSidebar) {

	trace("unloading modules..")
	for (k=0; k<currentModuleLevels.length; k++) {
		currMod = currentEditScreen.modules[k];
		currMod.tempClip.unloadClip("_level0.layer" + currentModuleLevels[k]);
/*		loadedClip = "_level" + currentModuleLevels[k];
		trace(" loadedClip = " + loadedClip);
		loadedClip = eval(loadedClip);
		trace(" loadedClip = " + loadedClip);
		removeMovieClip(loadedClip);
		trace(" loadedClip = " + loadedClip);
		*/
	}
	if (keepSidebar !== true) {
		sideBar.removeMovieClip();		
	}
	currentModuleLevels = new Array();
	clearParams();
}

function layerPressed (direction) {
	if (direction == "up") {
		moveUp = true;
	} else {
		moveUp = false;
	}
	
	var clip = topBar.currentClip;
	trace("clip = " + clip + ", " + clip.name);
	var currLayer = clip.layer;
	var newLayer = (moveUp)? currLayer+1: currLayer-1;
	trace("on layer " + currLayer + ", want to be on layer " + newLayer);
	
	// check to see if this layer is occupied.
	currentHost = false;
	for (k=0; k<currentEditScreen.modules.length; k++) {
		tempMod = currentEditScreen.modules[k];
		if (tempMod.layer == newLayer && tempMod != clip.linkedMod) {
			trace("match on layer " + tempMod.layer + " for " + tempMod.name);
			currentHost = currentEditScreen.modules[k];
		}
	}
	
	// if so, swap with its host.
	if (currentHost !== false) {
		trace("existing layer is taken by " + currentHost.name)
		currentHost.layer = currLayer;
		clip.linkedMod.layer = newLayer;
		trace("after swap: " + clip.linkedMod.name + "is now at " + clip.linkedMod.layer + ", and " + currentHost.name + " is now at " + currentHost.layer);
	} else {
		// if not, do nothing, since we should be either at the top or the bottom.	
		trace("no matches found.  It better be on the top or the bottom");
	}
	
	
	// reload.
//	clip.swapDepths(currentHost);
	paramSave(clip);
	loadCurrentScreenModules (modulesArr,false);
	
}


function loadParams(clip, override){
if (currentParamSet !== clip || override === true) {
//	trace("loading params.\n params = " + clip.params);
	currentParamSet = clip;
	params = clip.params;
	var paramOffset = 0;
	clearParams();
	paramClips = new Array();
	for (j=0; j<params.length; j++) {
		if (params[j].name != "lifeCycleState") {
//			trace(" loading " + params[j].name + "   offset=" + paramOffset);
			var tempObj = new Object();
			tempObj.linkedParam = clip.params[j];
			tempObj.title =  params[j].name;
			tempObj.type = params[j].type;
			tempObj.value = (params[j].value == null) ? "" : params[j].value;
			tempObj.helpText = params[j].helpText;
			tempObj._visible = true;

			switch  (params[j].type) {
				case "integer":
					tempObj._y = sideBar.input_int0._y + paramOffset;
					paramOffset += panelIntOffset;
					newClip = sideBar.input_int0.duplicateMovieClip("param"+j,get_topLevel(),tempObj);
				break;
				case "string":
					tempObj._y = sideBar.input_str0._y + paramOffset;
					paramOffset += panelStrOffset;
					newClip = sideBar.input_str0.duplicateMovieClip("param"+j,get_topLevel(),tempObj);
				break;

				case "boolean":
					tempObj._y = sideBar.input_bool0._y + paramOffset;
					paramOffset += panelBoolOffset;
					newClip = sideBar.input_bool0.duplicateMovieClip("param"+j,get_topLevel(),tempObj);
					if (params[j].value == true) {
						newClip.checkBox.gotoAndStop(1);
					} else {
						newClip.checkBox.gotoAndStop(2);
					}
				break;

				case "cdata":
					tempObj._y = sideBar.input_cdata0._y + paramOffset;
					paramOffset += panelCdataOffset;
					newClip = sideBar.input_cdata0.duplicateMovieClip("param"+j,get_topLevel(),tempObj);
				break;
			}
			paramClips.push(newClip);
			newClip.swapDepths(get_topLevel());
		}
	}
	
	if (paramOffset > maxPanelOffset) {
		panelDownEnabled = true;
	} else {
		panelDownEnabled = false;
	}
	panelUpEnabled = false;
	setScrollVis ();
	
	// pull the scroll buttons and covers to the top.
//
 	sideBar.swapDepths(999998);
	sideBar.bottomButtons.swapDepths(get_topLevel());
	sideBar.topButtons.swapDepths(get_topLevel());
	
	
	// pull the bottom nav to the top?
	bottomNav.swapDepths(999999);
}	
}


function paramScroll (direction) {
	if (direction == "up") {
		paramScrollPos -= 1;
	} else {
		paramScrollPos += 1;
	}
//	trace("paramScrollPos = " + paramScrollPos);
	
	// check maxes
	if (paramScrollPos <= 0) { paramScrollPos = 0; panelUpEnabled = false; } 
	else { 
		panelUpEnabled = true;
		if (paramScrollPos > paramClips.length-3) { paramClips = paramClips.length-3;} 
	}
	
	paramOffset = 0;
	for (j=0; j<paramClips.length; j++) {
		tempObj = paramClips[j];		
		if (j<paramScrollPos) {
			// yes, this is cheap, but it doesn't matter - they're hidden and out of the way.
			tempObj._y  = sideBar.input_int0._y + panelCdataOffset;
		} else {
			// add from start
			switch  (tempObj.type) {
				case "integer":
					tempObj._y = sideBar.input_int0._y + paramOffset;
					paramOffset += panelIntOffset;
				break;
				case "string":
					tempObj._y = sideBar.input_str0._y + paramOffset;
					paramOffset += panelStrOffset;
				break;

				case "boolean":
					tempObj._y = sideBar.input_bool0._y + paramOffset;
					paramOffset += panelBoolOffset;
				break;

				case "cdata":
					tempObj._y = sideBar.input_cdata0._y + paramOffset;
					paramOffset += panelCdataOffset;
				break;
			}
		}
	}
	
	
	if (paramOffset > maxPanelOffset) {
		panelDownEnabled = true;
	} else {
		panelDownEnabled = false;
	}
	
	setScrollVis ();
}

function setScrollVis () {
	sideBar.bottomButtons.scrollDown._visible = panelDownEnabled;
	sideBar.topButtons.scrollUp._visible = panelUpEnabled;
}

function paramSave (clip) {
	trace("Saving Parameters, reloading module.")
		for (j=0; j<paramClips.length; j++) {
	//		trace("paramClips[j] = " + paramClips[j]);
			tempObj = paramClips[j];
	//		trace("clearing: tempObj = " + tempObj);

			// save params
			if (tempObj.value == "") { tempObj.value = null;}
			tempObj.linkedParam.value = tempObj.value;
			

		}
	
		loadCurrentScreenModules (modulesArr,false);

}

function clearParams () {
	for (j=0; j<paramClips.length; j++) {
//		trace("paramClips[j] = " + paramClips[j]);
		tempObj = paramClips[j];
//		trace("clearing: tempObj = " + tempObj);
	
		// save params
		if (tempObj.value == "") { tempObj.value = null;}
		tempObj.linkedParam.value = tempObj.value;
		
		
		// remove clip
		removeMovieClip(tempObj);
	}
	paramClips = new Array();
}

function saveParams (clip) {
	// save to clip.linkedMod.params

}


function saveSurvey () {
	saveLoadDialog.gotoAndPlay("saving");
	var fullXML = surveyObjToXML(startScreen);
	// TODO: send this to the server!
	trace(fullXML);
	_root.saveXML = fullXML;
	getURL("javascript:saveSurveyData();");
	saveLoadDialog.gotoAndPlay("saved");
	
}

function saveLoadDialogPlay () {
	saveLoadDialog.gotoAndPlay("saved");
}

function surveyObjToXML (startingPoint) {
	// Note here:  We don't use flash's native XML object because it doesn't support CDATA on the way out.
	// Way to go, Macromedia.
	
	
	var xmlText = "";

	if (startingPoint == startScreen) {
		// set up xml start
	 	xmlText += "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n";
		xmlText += "<impact4>\n";

		xmlText += "<configuration>\n";
		// add all the config constants
		xmlText += "	<display allowback=\"true\" allowquit=\"false\">\n		<screen height=\"800\" width=\"600\" />\n		<titlebar text=\"impact4 Survey\" />\n	</display>\n	<property name=\"defaultModemBuffer\" value=\"100\" type=\"integer\" />\n	<property name=\"defaultIsdnBuffer\" value=\"100\" type=\"integer\" />\n	<property name=\"defaultCableBuffer\" value=\"100\" type=\"integer\" />\n	<property name=\"checkXMLValidity\" value=\"true\" type=\"boolean\" />\n	<property name=\"navType\" value=\"full\" type=\"string\" />\n	<property name=\"showProgressBar\" value =\"true\" type=\"boolean\"/>\n	<property name=\"dumpDatabaseBeforeNavigation\" value=\"false\" type=\"boolean\" />\n	<property name=\"calculateProgressBar\" value=\"true\" type=\"boolean\" />\n	<property name=\"traceSetValue\" value=\"true\" type=\"boolean\" />\n	<property name=\"traceToConsole\" value=\"false\" type=\"boolean\" />\n	<property name=\"enableGarbageCollection\" value=\"false\" type=\"boolean\" />\n";
		xmlText += "</configuration>\n";

		xmlText += "<navigation>\n";
		surveyDepth = 0;
		
	}


	// traverse survey tree
	tempObj = startingPoint;
	counter = 0;

	// for each screen
	while (tempObj.youngerSibling !== false && typeof(tempObj) != "undefined" && (debugMode == false || counter < maxLoops )) {
		var branchCheck = false;
		branchCheck = parse_check_branch_layout(tempObj);		
		if (branchCheck == false) {
			xmlText += createScreenXML(tempObj);
		} else {
			xmlText += branchCheck;
			
		}
		tempObj = tempObj.youngerSibling;
		counter++;
	}

	// final run
	branchCheck = parse_check_branch_layout(tempObj);		
	if (branchCheck == false) {
		xmlText += createScreenXML(tempObj);
	} else {
		xmlText += branchCheck;
		
	}
	
	if (startingPoint == startScreen) {
	
		// close up
		xmlText += "</navigation>\n";	
		xmlText += "</impact4>";
	
	}
	
	return xmlText;
	
}



function parse_check_branch_layout (tempBranchScreen) {
	// check for branches, recurse as necessary
	var tempObj = tempBranchScreen;
	
	if (tempObj.clipType == "branch") {
		var xmlText = "";
		surveyDepth ++;
		// TODO: write out condition tags
		xmlText += "\n\n<condition lval=\"" + tempObj.leftValue + "\" operation=\"" + tempObj.operation + "\" rval=\"" + tempObj.rightValue + "\">";
		
		xmlText += "\n\t<true>";
		if (tempObj.youngerSiblingTrue !== false) {
			xmlText += "\n" + surveyObjToXML(tempObj.youngerSiblingTrue);

		}
		xmlText += "\t</true>";
		
		xmlText += "\n\t<false>";
		if (tempObj.youngerSiblingFalse !== false) {
			xmlText += "\n" + surveyObjToXML(tempObj.youngerSiblingFalse);

		}
		surveyDepth --;
		xmlText += "\t</false>\n";
		xmlText += "</condition>\n";
		
		return xmlText;
	} else {
		return false;
	}
}


function createScreenXML (tempScreen) {

	var xmlText = "";
		
	// if multiple mods, add group tag
	if (tempScreen.modules.length > 1) {
		xmlText += "\t<group";
		if (typeof(tempScreen.title )  != "undefined" && tempScreen.title == "") 	{ xmlText += " title=\"" + 	tempScreen.title + "\""; }
		xmlText +=">\n";
	}

	trace("tempScreen.modules = " + tempScreen.modules);

	// for each mod
	for (j=0; j<tempScreen.modules.length; j++) {
		// params
		
		xmlText += "\t\t<module ";

		var currMod = tempScreen.modules[j];
		xmlText += "type=\"" + currMod.name + "\"";

		// x, y, scale, layer, name
		if (tempScreen.title != "undefined" && tempScreen.modules.length == 1) 		{ xmlText += " title=\"" + 	tempScreen.title + "\""; }

		if (typeof(currMod.xposition) != "undefined") 	{ xmlText += " x=\"" + 	currMod.xposition + "\""; }
		if (typeof(currMod.yposition) != "undefined") 	{ xmlText += " y=\"" + 	currMod.yposition + "\""; }
		if (typeof(currMod.scale) != "undefined") 		{ xmlText += " scale=\""+ currMod.scale + "\""; }
		if (typeof(currMod.layer) != "undefined") 		{ xmlText += " level=\""+ currMod.layer + "\""; }


		var postTagXMLText = "";
		for (k=0; k<currMod.params.length; k++) {
			var currParam = currMod.params[k];
			if (currParam.name == "internalName") {
				if (typeof(currParam.name) != "undefined") 		{ xmlText += " name=\"" + 	currParam.value+ "\""; }
			} else {
				postTagXMLText += "\t\t\t<" + ((currParam.mode=="variable")? "field": currParam.mode);
	 			postTagXMLText += " type=\"" + currParam.type + "\" name=\"" + currParam.name + "\"";
				if(currParam.value != null ) {
					if (currParam.type == "cdata") {
						postTagXMLText += "><![CDATA[" + currParam.value + "]]>"
					} else {
						postTagXMLText += " value=\"" +  "\">"		
					}				
				} else {
					postTagXMLText += ">";
				}
				if (currParam.mode=="variable") {
					postTagXMLText += "</field>\n";
				} else {
					postTagXMLText += "</const>\n";				
				}	
			}
		}
		
		xmlText += ">\n" + postTagXMLText;
		// Params: sectionText, percentDone
		if (j==0) {
			if (tempScreen.percentDone != 0) { xmlText += "\t\t\t<const type=\"integer\" name=\"percentDone\" value=\"" + tempScreen.percentDone + "\" />\n"  }
			if (tempScreen.section != "")	 { xmlText += "\t\t\t<const type=\"string\" name=\"sectionText\" value=\"" + tempScreen.section + "\" />\n" }
		}
		
		xmlText += "\t\t</module>\n";
	}
	
	if (tempScreen.modules.length > 1) {
		xmlText += "\t</group>\n";	
	}
//	trace("xmlText = " + xmlText);
	
	return xmlText;


}

if (debugMode) {
	var textDescription = "";
	var linePrefix = "\n";
}


var prevScreen;
function XMLtoSurveyObj (xmlURLToLoad, segmentMode) {
		surveyXML = new XML();
		surveyXML.ignoreWhite = true;
		trace("xmlURLToLoad = " + xmlURLToLoad);
		surveyXML.onLoad = function (status) {

			// skip the config crap. 
			tempXML = surveyXML.firstChild.childNodes[1];//.firstChild;
			startScreen.inSequence = true;

					
			writeChunk(tempXML,_root.startScreen,false);
			
			
	    	layout_survey();
	    	zoom();
      
	    	layout_survey();
			trace("XML Structure:\n" + textDescription);
		}
		surveyXML.load(xmlURLToLoad);
	

}

var endingBranch = false;
var prevRepObj;
function writeChunk(chunkXML,prevScreen,inBranch,branchSide) {	
	var tempXML = chunkXML.firstChild;
	var screenObj = false;
	loopCount = 0;
	do {
		loopCount ++;
		trace("** clip = " + clip);
		trace("prevScreen = " + prevScreen); 
		trace("In branch? " + inBranch + ", branchSide=" + branchSide); 
//		trace("\ntempXML = " + tempXML);
		trace("first check endingBranch = " + endingBranch);
		if (endingBranch == true && prevRepObj != undefined && prevRepObj != null) {
			trace("true condition met");
			prevScreen = prevRepObj;
		}
		trace("prevScreen = " + prevScreen);
		prevRepObj = null;

		if (tempXML.nodeName != "condition") {

			// check for groups
			if (tempXML.nodeName == "group") {
				// there's more than one!
				tempModuleXML = tempXML.firstChild;
				var screenTitle = (typeof(tempXML.attributes.title  )  != "undefined") ? tempXML.attributes.title : "";
				var group = true;
			} else {
				tempModuleXML = tempXML;
				var screenTitle = (typeof(tempModuleXML.attributes.title  )  != "undefined") ? tempModuleXML.attributes.title : "";
				var group = false;
			}
			textDescription += linePrefix + "screen: " + screenTitle;

			// make a new screen
			var screenObj = new_clip("screen",true);
			// HERE!!!
//			if (1 == 1) {
//			if (prevScreen !== inBranch) {
//				prevScreen.youngerSibling = screenObj;				
//			} else {
//				prevScreen.youngerSibling = false;
//			}
			screenObj.olderSibling = prevScreen;
			screenObj.inSequence = true;
			screenObj.title = screenTitle;
			
			if (inBranch !== false) {
//				trace("inside inBranch condition");
				screenObj.inBranch = inBranch;
				screenObj.branchSide = branchSide;
				if (loopCount == 1) {
					if (branchSide == true) {
						prevScreen.youngerSiblingTrue = screenObj;
					} else {
						if (branchSide == false) {
							prevScreen.youngerSiblingFalse = screenObj;
						}	
					}
				} else {
					prevScreen.youngerSibling = screenObj;
				}
			} else {
				screenObj.inBranch = false;
				screenObj.branchSide = false;
				prevScreen.youngerSibling = screenObj;
			}
			// assign its modules
			do {
				var tempFriendly = findFriendlyName(tempModuleXML.attributes.type);
				screenObj.modules.push(new module(tempModuleXML.attributes.type,tempFriendly.friendlyName));
				tempModule = screenObj.modules[screenObj.modules.length-1];
				if (typeof(tempModuleXML.attributes.name  )  != "undefined") 	{ tempModule.internalName 	  = tempModuleXML.attributes.name; }
//				trace("x and y = " + tempModuleXML.attributes.x + "," + tempModuleXML.attributes.y);
				if (typeof(tempModuleXML.attributes.x	  )  != "undefined") 	{ tempModule.xposition = tempModuleXML.attributes.x*1; }
				if (typeof(tempModuleXML.attributes.y	  )  != "undefined") 	{ tempModule.yposition = tempModuleXML.attributes.y*1; }
				if (typeof(tempModuleXML.attributes.scale)	!= "undefined") 	{ tempModule.scale 	  = tempModuleXML.attributes.scale*1; }
				if (typeof(tempModuleXML.attributes.level)	!= "undefined") 	{ tempModule.layer 	  = tempModuleXML.attributes.level*1; }

			
				// assign their parameters
				tempChild =  tempModuleXML.firstChild;
				// if sectionText or percentDone are used, assign them.						
				do {
					if (tempChild.attributes.name == "sectionText" || tempChild.attributes.name == "percentDone") {
						if (tempChild.attributes.name == "sectionText") {
							screenObj.section = tempChild.attributes.value;
						} else {
							screenObj.percentDone = tempChild.attributes.value;
						}
					} else {
						var tempHelpText = findHelpText(tempModuleXML.attributes.type,tempChild.attributes.name);
						// handle text fields
						if (tempModuleXML.attributes.type == "widget_text" && tempChild.attributes.name == "textValue") {
							// make sure we're dealing with a simple case (one font tag)
							var textString = tempChild.firstChild.nodeValue;
//							trace("textString = " + textString);
							if (textString.indexOf("<font") == textString.lastIndexOf("<font") && textString.lastIndexOf("<") == textString.indexOf("<", textString.indexOf("<")+2)) {
								var sizeStart = textString.indexOf("size=")+6;
								var sizeEnd = textString.indexOf("\"",textString.indexOf("size=")+6);
								sizeEnd = (textString.indexOf("'", textString.indexOf("size=")+6) > 0 && (textString.indexOf("'", textString.indexOf("size=")+6) < sizeEnd || sizeEnd <0)) ? textString.indexOf("'",textString.indexOf("size=")+6) : sizeEnd;
								var size = (sizeStart > 5 && sizeEnd >0) ? textString.slice(sizeStart,sizeEnd) : "";
								var faceStart = textString.indexOf("face=")+6;
								var faceEnd = textString.indexOf("\"",textString.indexOf("face=")+6);
								faceEnd = (textString.indexOf("'", textString.indexOf("face=")+6) > 0 && (textString.indexOf("'", textString.indexOf("face=")+6) < faceEnd || faceEnd <0)) ? textString.indexOf("'",textString.indexOf("face=")+6) : faceEnd;
								var face = (faceStart >5 && faceEnd >0) ? textString.slice(faceStart,faceEnd) : "";
								var text = textString.slice(textString.indexOf(">")+1,textString.lastIndexOf("<"));
/*								trace("size = " + size);
								trace("face = " + face);
								trace("text = " + text);
*/								tempModule.params.splice(0,0,new parameter ("Font", face, "variable", "string", "The name of the font you would like to use."));
								tempModule.params.splice(0,0,new parameter ("Size", size, "variable", "integer", "The font size you would like to use."));
								tempModule.params.splice(0,0,new parameter ("Text", text, "variable", "cdata", "The text to display. This will update the textValue field below."));
							} else {
/*								var attribValue = tempChild.attributes.value;									
								tempParam = new parameter(tempChild.attributes.name, attribValue, ((tempChild.nodeName=="const")?"const":"variable"), tempChild.attributes.type, tempHelpText);
								tempModule.params.push(tempParam);		*/													
							}
							tempModule.modified = true;

						} else {
							if (tempChild.attributes.type == "cdata") {
								var attribValue = tempChild.firstChild.nodeValue;
								if (tempChild.attributes.name == "textValue") {
									textString = attribValue;
								}
							} else {
								var attribValue = tempChild.attributes.value;
							}
	//						trace("attribValue = " + attribValue);
							if (tempChild.attributes.name != "textValue") {
								tempParam = new parameter(tempChild.attributes.name, attribValue, ((tempChild.nodeName=="const")?"const":"variable"), tempChild.attributes.type, tempHelpText);
								tempModule.params.push(tempParam);															
							}
						}
					}
				} while (tempChild = tempChild.nextSibling);
				if (tempModule.modified === true) {
					tempModule.params.push(new parameter ("textValue", textString, "variable", "cdata", "The textValue - this is what will actually be stored in the XML."));
				}

				// load them up from the XML spec.
				var knownMod = false;
				tempModuleListXML = modulesXML.firstChild;
				while (tempModuleListXML = tempModuleListXML.nextSibling) {
					// check to see if the mod is in the spec
					if (tempModuleListXML.attributes.type == tempModuleXML.attributes.name) {
						knownMod = tempModuleXML;
					}
				}
//				trace("\n\nknownMod = " + knownMod + "\n\n");
				if (knownMod != false) {
					// if so, check each param to see if it's already represented. 					
					do {				
						// do check
						var alreadyShown = false;
						var alreadyNamed = false;
						for (m=0; m< tempModule.params.length; m++) {
							if (tempModule.params[m].name == knownMod.attributes.name) {
								alreadyShown = true;
							}

						}
						if (!alreadyShown) {
							// add if missing
							tempParam = new parameter(knownMod.attributes.name, knownMod.attributes.defaultValue, knownMod.attributes.mode, knownMod.attributes.type, knownMod.attributes.helpText);
							tempModule.params.push(tempParam);							
						}
					} while (knownMod = knownMod.nextSibling);
				}

				tempParam = new parameter("internalName", tempModuleXML.attributes.name, "const", "string","The internal name to use for this screen. Useful if you need to refer to the screen in a branch, or for data saving.");
				tempModule.params.splice(0,0,tempParam);

				
				

			} while (group == true && (tempModuleXML = tempModuleXML.nextSibling));



		} else {
			if (tempXML.nodeName == "condition") {
			textDescription += linePrefix + "Branch: ";
			linePrefix += " ";
			// if a branch,
			// make a new branch
			clipObj = new_clip("branch",true)
			tempXML.representedObj = clipObj;
			if (inBranch != false) {

				clipObj.inBranch = inBranch;
				clipObj.branchSide = branchSide;
				if (loopCount == 1) {
					if (branchSide == true) {
						prevScreen.youngerSiblingTrue = clipObj;
					} else {
						if (branchSide == false) {
							prevScreen.youngerSiblingFalse = clipObj;
						}	
					}
				} else {
					prevScreen.youngerSibling = clipObj;
				}
			} else {
				prevScreen.youngerSibling = clipObj;
			}

			createBranchSupportsAndClose(clipObj);
			
			clipObj.olderSibling = prevScreen;
			clipObj.inSequence = true;
//			// this is now being done inline in the writeChunk calls to fix a branch-exit bug.
//			var inBranch = clipObj;
			
//			dragging_stopped(clipObj);
			endingBranch = false;
			
//			clipObj.youngerSiblingTrue = false;
//			clipObj.youngerSiblingFalse = false;

		
			// set the lval, rval, comparison
			clipObj.leftValue = tempXML.attributes.lval;
			clipObj.rightValue = tempXML.attributes.rval;
			clipObj.operation = tempXML.attributes.operation;
		
//			trace("\n\n\n\n");
//			trace("tempXML.firstChild = " + tempXML.firstChild.toString());
//			trace("tempXML.firstChild.nodeName = " + tempXML.firstChild.nodeName);
			// go into the true branch
			if (tempXML.firstChild.nodeName == "true") {
				textDescription += linePrefix + "TRUE: " ;
				linePrefix += " ";
				if (tempXML.firstChild.childNodes.length > 0) {
					writeChunk(tempXML.firstChild,clipObj,clipObj,true)					
				} else {
					clipObj.youngerSiblingTrue = false;
				}
				linePrefix = linePrefix.slice(0,-1);
				textDescription += linePrefix + "FALSE: ";
				linePrefix += " ";
				if (tempXML.firstChild.nextSibling.childNodes.length > 0) {
					writeChunk(tempXML.firstChild.nextSibling,clipObj,clipObj,false);
				}	else {
					clipObj.youngerSiblingFalse = false;
				}
				linePrefix = linePrefix.slice(0,-1);
			} else {
				textDescription += linePrefix + "FALSE: ";
				linePrefix += " ";
				if (tempXML.firstChild.childNodes.length > 0) {
					writeChunk(tempXML.firstChild,clipObj,clipObj,false)
				} else {
					clipObj.youngerSiblingFalse = false;
				}
				linePrefix = linePrefix.slice(0,-1);
				textDescription += linePrefix + "TRUE: ";
				linePrefix += " ";
				if (tempXML.firstChild.nextSibling.childNodes.length > 0) {
					writeChunk(tempXML.firstChild.nextSibling,clipObj,clipObj,true);
				} else {
					clipObj.youngerSiblingTrue = false;
				}
				linePrefix = linePrefix.slice(0,-1);
			}
			
			// IBBITY
			// TODO: this is where the last clip problems are happening.
			// it's probably an initialization problem on recursion.
			
			// I DO not understand this.  The lines noted below cause the problem.
			
			var tempStringy = tempXML.nextSibling.toString();
//			trace("tempStringy = " + tempStringy);
//			trace("tempStringy != undefined = " + (tempStringy != undefined));
			
			trace("endingBranch = " + endingBranch);
			// NOTED.  Change this from != to == and observe. WTF.
//			if (endingBranch != true) { 
				
				screenObj = clipObj;
//			} else {
				prevRepObj = tempXML.representedObj;	
//			}
			
//			trace("finished branch, tempXML=" + tempXML);
//			trace("finished branch, tempXML.nextSibling=" + tempXML.nextSibling);
			trace("tempXML.representedObj = " + tempXML.representedObj);
//			prevRepObj.youngerSibling = false;
//			inBranch.youngerSibling = false;
			trace("screenObj = " + screenObj);
			linePrefix = linePrefix.slice(0,-1);
			textDescription += linePrefix + "Close Branch";
				// prevScreen is the branch(vfy this)
				// TODO - this is not true!!
			
			
				// normal screen layout, (recurse writeChunk)
				// add on branch ownership
				// at the end, lastScreen.youngerSibling is the branch close?  does it have one?
		
			// same for the false branch
		
			}
		}
//	This line is the troublemaker!!
		prevScreen = screenObj;
		trace("ending loop, prevScreen = " + prevScreen);

	} while (tempXML = tempXML.nextSibling);
	trace("ending function, prevScreen = " + prevScreen);
	endingBranch = true;
}


function findFriendlyName (name) {
	var friendlyName = false;
	var j=0;
	while (!friendlyName && j<modulesArr.length) {
		if (modulesArr[j].name == name) {
			friendlyName = modulesArr[j];
		}
		j++;
	}
//	trace("friendlyName.friendlyName = " + friendlyName.friendlyName);
	return friendlyName;
}
function findHelpText (name,param) {
	var mod = findFriendlyName(name);
	var helpText = "";
	for (j=0; j<mod.params.length; j++) {
		if (mod.params[j].name == param) {
			helpText = mod.params[j].helpText;
		}
	}
//	trace("helpText = " + helpText);
	return helpText;
}


function loadSurveyXML (xmlURLToLoad) {
	// TODO: show message, confirm that they want to load
	
	// remove existing clips
	
	// load
	XMLtoSurveyObj(xmlURLToLoad);

}


function reset_topLevel()	{
	/// changes the top level base
	topLevelMultiplier = ((topLevelMultiplier -2) *-1 ) +1;	
}


function get_topLevel() {
	//gives the next level
	topLevel++;
	return topLevel;
}
_global.get_topLevel = get_topLevel;

function allocNewLevel () {
	return get_topLevel();
}


initializeBuilder(); 