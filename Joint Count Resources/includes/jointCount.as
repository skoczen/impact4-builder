// This is the ActionScript code for the HAQ.
// Copyright VA/UCSD, 2001-2002.
// Last update: 4-10-2002, Steven Skoczen
// 
// 

/* THIS CODE NEEDS TO BE UPDATED FOR i4.  
   A decision needs to be made as to how to implement the Dr. addition to the module (separate module?).
   
   */


// ---- Initializing Variables ----

function eventHandler(event, text)
{
	switch(event)
	{
		case EVENT_MODULE_INITALIZE:
			initialize();
			break;
		case EVENT_MODULE_FINALIZE:
			finalize();
			break;
		case EVENT_NAVIGATION_ADVANCEFAILED:
			trace(this.myName + " finalize failed on me " + text);
			userActions.currentState = 3;
			break;
	}
}



	var arrItem = new Array;
	var arrSequence = new Array;
	var arrAnswers = new Array;
	var jointNames = new Array;
	var jointResponseHash = "";
	var numQuestions = 16;
	var currentQuestion = 1;
	var itemAnswer = "";

// For Homunculus
	var numPainful = 0;
	var numSwollen = 0;
	var numPainAndSwelling = 0;
	var arrJointResponses = new Array;
	var numJoints;

	// Initialize Arrays
	for (j=0; j<=numQuestions; j++) {
			arrItem = [j,j];
			arrSequence[j] = arrItem;
			arrAnswers[j] = "";
		}	
	
// ---- Begin Questions ----
// 
// Array Structure:
// [0] - Question Type (see the flash movie for each type)
// [1-5] - Question, and Options (varies between types)
//
	
	
	arrSequence[0][0] = "";
	arrSequence[0][1] = "";
	arrSequence[1][0] = "A";
	arrSequence[1][1] = "Dress yourself, including tying shoelaces and doing buttons?";
	arrSequence[1][2] = "Unable to Do";
	arrSequence[1][3] = "With Much Difficulty";
	arrSequence[1][4] = "With Some Difficulty";
	arrSequence[1][5] = "Without any Difficulty";
	arrSequence[2][0] = "A";
	arrSequence[2][1] = "Get in and out of bed?";
	arrSequence[2][2] = "Unable to Do";
	arrSequence[2][3] = "With Much Difficulty";
	arrSequence[2][4] = "With Some Difficulty";
	arrSequence[2][5] = "Without any Difficulty";
	arrSequence[3][0] = "A";
	arrSequence[3][1] = "Lift a full cup or glass to your mouth?";
	arrSequence[3][2] = "Unable to Do";
	arrSequence[3][3] = "With Much Difficulty";
	arrSequence[3][4] = "With Some Difficulty";
	arrSequence[3][5] = "Without any Difficulty";
	arrSequence[4][0] = "A";
	arrSequence[4][1] = "Walk outdoors on flat ground?";
	arrSequence[4][2] = "Unable to Do";
	arrSequence[4][3] = "With Much Difficulty";
	arrSequence[4][4] = "With Some Difficulty";
	arrSequence[4][5] = "Without any Difficulty";
	arrSequence[5][0] = "A";
	arrSequence[5][1] = "Wash and dry your entire body?";
	arrSequence[5][2] = "Unable to Do";
	arrSequence[5][3] = "With Much Difficulty";
	arrSequence[5][4] = "With Some Difficulty";
	arrSequence[5][5] = "Without any Difficulty";
	arrSequence[6][0] = "A";
	arrSequence[6][1] = "Bend down to pick up clothing from the floor?";
	arrSequence[6][2] = "Unable to Do";
	arrSequence[6][3] = "With Much Difficulty";
	arrSequence[6][4] = "With Some Difficulty";
	arrSequence[6][5] = "Without any Difficulty";
	arrSequence[7][0] = "A";
	arrSequence[7][1] = "Turn regular faucets on and off?";
	arrSequence[7][2] = "Unable to Do";
	arrSequence[7][3] = "With Much Difficulty";
	arrSequence[7][4] = "With Some Difficulty";
	arrSequence[7][5] = "Without any Difficulty";
	arrSequence[8][0] = "A";
	arrSequence[8][1] = "Get in and out of a car, bus, train, or airplane?";
	arrSequence[8][2] = "Unable to Do";
	arrSequence[8][3] = "With Much Difficulty";
	arrSequence[8][4] = "With Some Difficulty";
	arrSequence[8][5] = "Without any Difficulty";
	arrSequence[9][0] = "A";
	arrSequence[9][1] = "Walk two miles?";
	arrSequence[9][2] = "Unable to Do";
	arrSequence[9][3] = "With Much Difficulty";
	arrSequence[9][4] = "With Some Difficulty";
	arrSequence[9][5] = "Without any Difficulty";
	arrSequence[10][0] = "A";
	arrSequence[10][1] = "Participate in sports and games as you would like?";
	arrSequence[10][2] = "Unable to Do";
	arrSequence[10][3] = "With Much Difficulty";
	arrSequence[10][4] = "With Some Difficulty";
	arrSequence[10][5] = "Without any Difficulty";
	arrSequence[11][0] = "B";
	arrSequence[11][1] = "How much pain have you had because of your condition <b>over the past week</b>?";
	arrSequence[11][2] = "No Pain";
	arrSequence[11][3] = "Extreme Pain";
	arrSequence[12][0] = "B";
	arrSequence[12][1] = "How much of a problem has <b>unusual</b> fatigue or tiredness been for you <b>over the past week</b>?";
	arrSequence[12][2] = "Not a Problem";
	arrSequence[12][3] = "An Extreme Problem";
	arrSequence[13][0] = "B";
	arrSequence[13][1] = "Consider all the ways in which illness and health conditions may affect you at this time. <br>Then, please use the scale below to indicate how you are doing.";
	arrSequence[13][2] = "Very Poorly";
	arrSequence[13][3] = "Very Well";
	arrSequence[14][0] = "F";
	arrSequence[14][1] = "I often do not take my medicines as directed.";
	arrSequence[14][2] = "Strongly Disagree";
	arrSequence[14][3] = "Disagree";
	arrSequence[14][4] = "Neither<br>Agree nor<br>Disagree";
	arrSequence[14][5] = "Agree";
	arrSequence[14][6] = "Strongly Agree";
	arrSequence[15][0] = "D";
	arrSequence[15][1] = "When you get up in the morning, do you feel stiff?";
	arrSequence[15][2] = "Yes";
	arrSequence[15][3] = "No";
	arrSequence[15][4] = "Hours";
	arrSequence[15][5] = "Minutes";
	arrSequence[16][0] = "G";
	

	jointNames[0] = ""
	jointNames[1] = "Left Pinky Toe, 2nd Joint";
	jointNames[2] = "Left Ring Toe, 2nd Joint";
	jointNames[3] = "Left Middle Toe, 2nd Joint";
	jointNames[4] = "Left Index Toe, 2nd Joint";
	jointNames[5] = "Left Big Toe, 2nd Joint";
	jointNames[6] = "Right Big Toe, 2nd Joint";
	jointNames[7] = "Right Index Toe, 2nd Joint";
	jointNames[8] = "Right Middle Toe, 2nd Joint";
	jointNames[9] = "Right Ring Toe, 2nd Joint";
	jointNames[10] = "Right Pinky Toe, 2nd Joint";
	jointNames[11] = "Left Pinky Toe, Base Joint";
	jointNames[12] = "Left Ring Toe, Base Joint";
	jointNames[13] = "Left Middle Toe, Base Joint";
	jointNames[14] = "Left Index Toe, Base Joint";
	jointNames[15] = "Left Big Toe, Base Joint";
	jointNames[16] = "Right Big Toe, Base Joint";
	jointNames[17] = "Right Index Toe, Base Joint";
	jointNames[18] = "Right Middle Toe, Base Joint";
	jointNames[19] = "Right Ring Toe, Base Joint";
	jointNames[20] = "Right Pinky Toe, Base Joint";
	jointNames[21] = "Left Foot, Midfoot Joints";
	jointNames[22] = "Neck";
	jointNames[23] = "Right Foot, Midfoot Joints";
	jointNames[24] = "Left Ankle";
	jointNames[25] = "Upper Back";
	jointNames[26] = "Right Ankle";
	jointNames[27] = "Left Knee";
	jointNames[28] = "Lower Back";
	jointNames[29] = "Right Knee";
	jointNames[30] = "Left Hip";
	jointNames[31] = "Right Hip";
	jointNames[32] = "Left Elbow";
	jointNames[33] = "Right Elbow";
	jointNames[34] = "Left Breastbone Joint";
	jointNames[35] = "Right Breastbone Joint";
	jointNames[36] = "Left Shoulder";
	jointNames[37] = "Right Shoulder";
	jointNames[38] = "Left Jaw Joint";
	jointNames[39] = "Right Jaw Joint";
	jointNames[40] = "Left Pinky Finger, 2nd Joint";
	jointNames[41] = "Left Ring Finger, 2nd Joint";
	jointNames[42] = "Left Middle Finger, 2nd Joint";
	jointNames[43] = "Left Index Finger, 2nd Joint";
	jointNames[44] = "Left Thumb, 2nd Joint";
	jointNames[45] = "Right Thumb, 2nd Joint";
	jointNames[46] = "Right Index Finger, 2nd Joint";
	jointNames[47] = "Right Middle Finger, 2nd Joint";
	jointNames[48] = "Right Ring Finger, 2nd Joint";
	jointNames[49] = "Right Pinky Finger, 2nd Joint";
	jointNames[50] = "Left Pinky Finger, Middle Joint";
	jointNames[51] = "Left Ring Finger, Middle Joint";
	jointNames[52] = "Left Middle Finger, Middle Joint";
	jointNames[53] = "Left Index Finger, Middle Joint";
	jointNames[54] = "Left Thumb, Middle Joint";
	jointNames[55] = "Right Thumb, Middle Joint";
	jointNames[56] = "Right Index Finger, Middle Joint";
	jointNames[57] = "Right Middle Finger, Middle Joint";
	jointNames[58] = "Right Ring Finger, Middle Joint";
	jointNames[59] = "Right Pinky Finger, Middle Joint";
	jointNames[60] = "Left Pinky Finger, Knuckle Joint";
	jointNames[61] = "Left Ring Finger, Knuckle Joint";
	jointNames[62] = "Left Middle Finger, Knuckle Joint";
	jointNames[63] = "Left Index Finger, Knuckle Joint";
	jointNames[64] = "Left Thumb, Hand Joint";
	jointNames[65] = "Right Thumb, Hand Joint";
	jointNames[66] = "Right Index Finger, Knuckle Joint";
	jointNames[67] = "Right Middle Finger, Knuckle Joint";
	jointNames[68] = "Right Ring Finger, Knuckle Joint";
	jointNames[69] = "Right Pinky Finger, Knuckle Joint";
	jointNames[70] = "Left Wrist";
	jointNames[71] = "Right Wrist";


// End Data

// Begin Functions


function forward() 
{
	// If the answer isn't an empty string,
	if (verifyAndStoreAnswer())
		{	
			// If not the last question,
			if (currentQuestion < numQuestions-1)
				{
					// Go to the next question.
					currentQuestion++;
					displayQuestion();
				}
			else
				{
					if (currentQuestion == numQuestions -1)
						{
							currentQuestion ++;
							// remove the previous question
							removeMovieClip(currentClip);
							// displayQuestion();
							gotoAndStop("homunculus");
						}
					else
						{
							// Done with last question.
							removeMovieClip(currentClip);
							CompileJoints();
							SendDataBack();

						}
				}
		}
}

function back() 
{
	//Store whatever answer is there now.
	arrAnswers[currentQuestion] = currentClip.currentAnswer;

	// If not the first, go to the previous question.
	if (currentQuestion > 1)
		{
			currentQuestion --;
			displayQuestion();
		} else {
			displayQuestion();
		}

}

function displayQuestion () 
{

	
	
	// load previous answer
	thisAnswer = arrAnswers[currentQuestion];

	// remove the previous question
	removeMovieClip(currentClip);

	// duplicate the new question
	questType = arrSequence[currentQuestion][0];
	tempObj = "smartQuestion" + questType;
	duplicateMovieClip(tempObj,"currentClip",4000);
	currentClip._x = 400.0
	currentClip._y = 195.0
	
	// note: the SmartClips automatically fill in their data.

}



function verifyAndStoreAnswer ()
{
	//trace ("arrAnswers = " + arrAnswers);
	//trace ("currentQuestion = " + currentQuestion);
	
	trace("questType = " + questType);
	if ( questType=="G" )
		return true;


	if (currentClip.currentAnswer == "")
		{
			// If they haven't answered, trigger the "please answer" message.
			pleaseAnswer.gotoAndStop("show");

			return false;
		}
	else 
		{
			// Hide the please answer clip
			pleaseAnswer.gotoAndStop("hide");
			// Store the answer.
			arrAnswers[currentQuestion] = currentClip.currentAnswer;
			return true;
		}

}

function CompileJoints ()
{
	// The purpose of this function:
	// 1. Crunch the Joints into an array.
	// 2. Put that array in the main array.
	// 3. Count the number of Painful Joints.
	// 4. Count the number of Swollen Joints.
	// 5. Count the number of Joints with both pain and swelling.
	//
	// Legend:
	// 0 - No Pain, No Swelling
	// 1 - Swelling Only
	// 2 - Pain Only
	// 3 - Both Pain and Swelling
	//
  // Note: Some data structures are defined as global structures at the top.
	
	numJoints = jointNames.length;
	trace ("numJoints = " + numJoints);

	var tempResponse;

	for (j=1; j<numJoints; j++) 
	{
		// Fills the array
		var tempObj = "smartQuestionG.homunculus.Joint" + j + ".symbols";
		var tempObj = eval (tempObj);
		tempResponse = tempObj._currentframe - 1;
	//	trace("tempResponse[" + j + "] = " + tempResponse);
		arrJointResponses[j] = tempResponse;
		jointResponseHash += "," + tempResponse;
		if (tempResponse == 1) {
			numSwollen++;
		} else {
			if (tempResponse == 2) {
					numPainful++;
			} else {
				if (tempResponse == 3) {
					numPainAndSwelling++;
					numPainful++;
					numSwollen++;
				}// end both
			} // end two
		} // end one
	} // end loop

//	trace("arrJointResponses = " + arrJointResponses);
	trace("jointResponseHash = " + jointResponseHash);
//	trace("numPainAndSwelling = " + numPainAndSwelling);
//	trace("numPainful = " + numPainful);
//	trace("numSwollen = " + numSwollen);


}

function doneWithCount () {
	CompileJoints();
	finalize();
	selfFinalizable();
//	sendEventToModules("navigation", EVENT_NAVIGATION_ATTEMPTFORWARD, "Next Clicked");
}

function finalize () {
	setValue ("jointResponseHash", jointResponseHash);	
	setValue("numPainAndSwelling", numPainAndSwelling);
	setValue("numPainful", numPainful);
	setValue("numSwollen", numSwollen);	
}

function setDoctorJoints (tempClip) {

   var newFrame;
   var tempObj;
   
	for (j=1; j<numJoints; j++) 
	{
		// Fills the array
		var tempObj = tempClip + ".joint" + j;
		tempObj = eval (tempObj);
		
		//trace("tempObj during set joints = " + tempObj);
		
		newFrame = arrJointResponses[j] + 1;
		
		tempObj.gotoAndStop(newFrame);
		

	} // end loop



}

function SendDataBack () {
	// This function is called when all the questions are done. 
	// It compiles the data, and sends it back to JavaScript.


			trace("answers = " + arrAnswers);
			trace("Joints = " + arrJointResponses);
			trace("numPainAndSwelling = " + numPainAndSwelling);
			trace("numPainful = " + numPainful);
			trace("numSwollen = " + numSwollen);
			
			
         // vars for doctors:
         // # Joints Affected
         // HAQ Score
         // Pain Scale / 10
         // Fatigue Scale /10
         // Health Scale / 10
         // Adherence
         // Stiffness
         
         jointsAffected = numPainful + numSwollen - numPainAndSwelling;
         haqScore = 0;
         for (j = 1; j<=10; j++){
              
            haqScore = haqScore + Math.abs(3 - (arrAnswers[j].charCodeAt(0) - 65) );
            //trace("Char Code " + j + " = " + arrAnswers[j].charCodeAt(0));
            //trace("Char is " + arrAnswers[j]);
         }
         haqScore = haqScore / 10;
         painScore = (Math.round(arrAnswers[11])/10);
         if (painScore %1 == 0 && painScore != 10)
            painScore = painScore + ".0";
         
         fatigueScore = (Math.round(arrAnswers[12])/10);
         if (fatigueScore %1 == 0 && fatigueScore != 10)
            fatigueScore = fatigueScore + ".0";
            
         healthScore = (Math.round(arrAnswers[13])/10);
         if (healthScore %1 == 0 && healthScore != 10)
            healthScore = healthScore + ".0";
         
         if (arrAnswers[14] == "A") {
           adherenceString = "No Problems";
         } else {
            if (arrAnswers[14] == "B" || arrAnswers[14] == "C") {
             adherenceString = "Potential Problems";
            } else {
               adherenceString = "Reported Problems";
            } 
         }
         stiffnessTime= arrAnswers[15] * 60
        
         trace("------- FOR DOCTORS ------------"); 
         trace("jointsAffected = " + jointsAffected);
         trace("haqScore = " + haqScore);
         trace("painScore = " + painScore);
         trace("fatigueScore = " + fatigueScore);
         trace("healthScore = " + healthScore);
         trace("adherenceString = " + adherenceString);
         trace("stiffnessTime = " + stiffnessTime + " min.");
         


         gotoAndStop("doctors");



}
