using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;


public class runExperiment : MonoBehaviour
{
    /// <summary>
    /// /// Imports parameters and handles the flow of the experiment.
    /// e.g. Trial progression, listeners etc.
    /// 
    /// 
    ///  This is the simultaneity judgement version (two brief flashes, staircase the gap between them).
    /// /// </summary>/// 
    
    // basic experiment structure
    public string participant;
    public int TrialCount; //walk trajectories
    public int TrialType;  // targ absent, n present
    public int targCount; // targs presented (acculative), used to track data.
    public bool isPractice=true; // determines walking guide motion (stationary during practice).
    public int nAllTrials; // staircase + ntrials (defined in Start())

    public int nStaircaseTrials;// = 40; // aka practice, used to calibrate target difficulty
    public int nTrials; // = 100; // after practice

    // flow managers
    public bool trialinProgress; // handles current state within experiment 
    private bool FAthistrial; // listen for FA in no targ trials, pass to update staircase/recording data.
    private bool SetUpSession; // for alignment of walking space.
    private int usematerial;  // change walk image (stop sign and arrows).

    // passed to other scripts (couroutine, record data etc).
    public bool collectTrialSummary; // passed to recordData.
    public float trialTime; // clock within trial time, for RT analysis.
    public int targState; // targ currently on screen, used to synchron recordings in recordData (frame by frame).
    public int detectIndex; // index to allocate response to correct target within walk.
    public bool hasResponded; //listener for trigger responses after target onset < respone Window.

    //trial  
    public List<float> FA_withintrial = new List<float>(); // collect RT of FA within each trial (wipes every trial) passed to RecordData.



    // speak to.
   
    ViveInput viveInput;
    recordData recordData;
    Staircase ppantStaircase;
    randomWalk randomWalk;
    walkParameters motionParams;
    walkingGuide walkingGuide;
    trialParameters trialParams;
    showText showText;
    changeDirectionMaterial changeMat;
    targetAppearance targetAppearance;

    // declare public GObjs.
    public GameObject hmd;
    public GameObject effector;
    public GameObject SphereShader;

    void Start()
    {
        // dependencies
        targetAppearance = GameObject.Find("SphereShader").GetComponent<targetAppearance>();
        viveInput = GameObject.Find("scriptHolder").GetComponent<ViveInput>();
        recordData = GameObject.Find("scriptHolder").GetComponent<recordData>();
        randomWalk = GameObject.Find("Sphere").GetComponent<randomWalk>();
        motionParams = GameObject.Find("scriptHolder").GetComponent<walkParameters>();
        walkingGuide = GameObject.Find("motionPath").GetComponent<walkingGuide>();
        trialParams = GameObject.Find("scriptHolder").GetComponent<trialParameters>();
        ppantStaircase = GameObject.Find("scriptHolder").GetComponent<Staircase>();
        showText = GameObject.Find("Instructions (TMP)").GetComponent<showText>();
        changeMat = GameObject.Find("directionCanvas").GetComponent<changeDirectionMaterial>();

        // params, storage
        // make sure nAllTrials is divisible by 10.
        nStaircaseTrials = 40;
        nTrials = 160;
        nAllTrials = nStaircaseTrials + nTrials;
       

        //flow managers
        TrialCount = 0;
        targCount = 0;
        trialinProgress = false;
        SetUpSession = true;
        collectTrialSummary = false; // send info after each target to be written to a csv file
        usematerial = 0; // 0=show stop sign, later changed to arrows for walk guide.

        changeMat.update(0); // render stop sign
        showText.updateText(1); // pre trial exp instructions


        print("setting up ... Press <space>  or <click> to confirm origin location");
    }


    private void Update()
    {

        // set up origin.
        if (SetUpSession)
        {

            CalibrateStartPos(); // align motion origin to player.
            

            targetAppearance.setColour(ppantStaircase.preTrialColor); // indicates ready for click to begin trial
           
        }


        // check for startbuttons, but only if not in trial.
        if (!trialinProgress && viveInput.clickLeft && TrialCount < nAllTrials) 
        {

            //remove text and wait a moment.

            showText.updateText(0);


            startTrial(); // starts coroutine, changes listeners, presets staircase.
            

        }


        // query end of calibration = walking phase, calibrate only before trial onset.
        if (TrialCount == nStaircaseTrials && !SetUpSession && trialTime==0 && !trialinProgress)
        {
            SetUpSession = true; // passed to calibrate walk guide.
            showText.updateText(2); // walk instructions.
            usematerial = 1; //green arrow material.
            changeMat.update(usematerial);  //show green arrow material.
        }

        if (!SetUpSession && trialTime == 0 && !trialinProgress)
        {

            showText.updateText(3); // Trial count.

        }

        // increment within trial time.
        if (trialinProgress)
        {
            trialTime += Time.deltaTime;
            //print("Trial Time: " + trialTime);
        }
     
        // check for target detection.(indicated by  L/R trigger click).
        if (trialinProgress && viveInput.clickState)
        {
            collectDetect(); // places RTs within an array. [ function will determine correct or no]
           
        }
        // If no response recorded by end of response window, update trial summary data accordingly:
        if (targetAppearance.processNoResponse) 
        {
            collectOmit();
            targetAppearance.processNoResponse = false;

        }


        // check for trial end.
        if (trialinProgress && (trialTime >= motionParams.walkDuration)) // use duration (rather than distance), to account for stationary trials.
        {

            trialinProgress = false;
            trialTime = 0;

            // safety, these should already have been stopped in walkingGuide
            randomWalk.walk = randomWalk.phase.stop;
            recordData.recordPhase = recordData.phase.stop;
            // also stop guide, and start return rotation
            walkingGuide.walkMotion = walkingGuide.motion.idle;
            walkingGuide.returnRotation = walkingGuide.motion.start;
            print("End of Trial " + TrialCount);
            


            // if absent trial has just ended - pass that to Record data too.
            if (TrialType ==0 )
            {
                if (!FAthistrial)
                {
                    print("Correct Rejection!"); // do not update staircase.
                    trialParams.targCorrectList.Add(1); // successfully correct rejection
                }
                else
                {
                    print("FA recorded...");
                    trialParams.targCorrectList.Add(0); // this trial should be marked as incorrect (FA)
                }
                // pass to Record Data (after every absent trial)
                trialParams.targGapDuration.Add(ppantStaircase.targetGap); // match the counts
                recordData.collectTrialSummary(); // appends information to text file.
            }



            targetAppearance.setColour(ppantStaircase.preTrialColor); // indicates ready for click to begin trial

            // write trial summary to text file (in debugging).
            //recordData.writeTrialSummary(); // writes text to csv after each trial.
            TrialCount++;
        }
           
        if (TrialCount == nAllTrials)
        {
            print("Experiment Over");
            targetAppearance.setColour(new Color(1, 0, 0));
        }
    }

    // cleaning up the Update() function. 
    void CalibrateStartPos()
    {

        GameObject motionOrigin = GameObject.Find("motionOrigin");
        Vector3 environmentPosition = motionOrigin.transform.position;
        Vector3 headPosition = hmd.transform.position;

        // because we start Motion path in the middle, offset this to reposition at HMD.
        environmentPosition.x = headPosition.x  - motionParams.guideDistance; // - stimParams.guideDistance;
        environmentPosition.z = headPosition.z;

        motionOrigin.transform.position = environmentPosition;


        // check for key press to confirm new position.
        if (Keyboard.current.spaceKey.wasPressedThisFrame || viveInput.clickState)
        {
            
            print("Location confirmed, beginning experiment");

            SetUpSession = false;
            walkingGuide.fillStartPos(); // update start pos in WG.
        }
       
       
    }


    private void startTrial()
    {

        // define distance based on trial type:
        if (TrialCount <= (nStaircaseTrials - 1))
        {
            // set for outside(randomWalk) listeners. When practice, motion guide is stationary.
            isPractice = true;

            changeMat.update(usematerial); // Render green arrow.
        }
        else
        {
            isPractice = false; // start the motion path.
            usematerial = 1;

        }

        // align motion paths at trial onset:

        randomWalk.transform.localPosition = motionParams.cubeOrigin;
        randomWalk.origin = motionParams.cubeOrigin;
        randomWalk.lowerBoundaries = motionParams.cubeOrigin - motionParams.cubeDimensions;
        randomWalk.upperBoundaries = motionParams.cubeOrigin + motionParams.cubeDimensions;
        randomWalk.stepDurationRange = motionParams.stepDurationRange;
        // can't use   = stepDistanceRange; as the string is rounded to 1f precision.
        // so access the dimensions directly:
        randomWalk.stepDistanceRange.x = motionParams.stepDistanceRange.x;
        randomWalk.stepDistanceRange.y = motionParams.stepDistanceRange.y;
       
        // set fields in randomWalk and recordData to begin exp:
        randomWalk.walk = randomWalk.phase.start;
        recordData.recordPhase = recordData.phase.collectResponse;
        walkingGuide.walkMotion = walkingGuide.motion.start;
        walkingGuide.returnRotation = walkingGuide.motion.idle;


        trialinProgress = true; // for coroutine (handled in targetAppearance.cs).

        // Establish (this) trial parameters:
        trialTime = 0;  // clock accurate reacton time from time start      
        targState = 0;
        TrialType = trialParams.trialTypeArray[TrialCount]; //[0, 1 or 2 targs]
        FAthistrial = false; // boolean passed to Update() to confirm whether absent types were correct or not.
        // temp file for any FAs:
        FA_withintrial.Clear();



        //start coroutine to control target onset and target behaviour:
        print("Starting Trial " + TrialCount + " of " + nTrials + ", " + TrialType + " to discriminate");
       
        targetAppearance.startSequence(); // co routine in another script.

    }

    // method for collecting responses to target presentation, assigning correct or not.
    private void collectDetect()
    {

        // L click for one targ perceived.
        if (viveInput.clickLeft)
        {
            // we have different critical windows, based on trial type. [0 ,1 ,2 targets];

            // first place the click into an array
            trialParams.clickOnsetTimeList.Add(trialTime);

            //determine if this RT was within response window of targ.
            // we have a listener in the coroutine (detectIndex). this determines whether RT was appropriate.

            if (detectIndex != 0 && !hasResponded)  // within allocated response window
            {
                // if this targ = 2 (50 % likelihood, set in targetAppearance).
                if (targetAppearance.OneorTwoFlashes == 1)
                {
                    trialParams.targCorrectList.Add(1); // left click is correct.

                    print("Correct!");
                }
                else
                {
                    trialParams.targCorrectList.Add(0); // left click is incorrect.
                    print("Error!");
                }

                trialParams.targResponseList.Add(1);
                trialParams.targResponseTimeList.Add(trialTime); // passed to recordData.
                                                                 //targ onset times already appended, within coroutine.


                ppantStaircase.corrCount++;

                hasResponded = true; // passed to coroutine, avoids processing omitted responses.
                // 
                // set up  contrast for the next target:
                if (TrialCount > 0 && TrialCount <= nStaircaseTrials)
                {
                    updateTargGapDuration(trialParams); // based on staircase.

                }
                else // also need to update trial contrast on prestaircase init
                {
                    trialParams.targGapDuration.Add(ppantStaircase.targetGap); // fixed after staircase.
                }

                recordData.collectTrialSummary();// pass to Record Data (after every hit targ)
            }
            else
            {
                print("False alarm");
                trialParams.FA_OnsetTimeList.Add(trialTime); // add FA to total list of FA
                FA_withintrial.Add(trialTime);
                ppantStaircase.errCount++;
                FAthistrial = true;
            }

        }
        //// same again, for R clicks
            //Record click - R click for 2 targs perceived,                     
        if (viveInput.clickRight)
        {

            // we have different critical windows, based on trial type. [0 ,1 ,2 targets];

            // first place the click into an array
            trialParams.clickOnsetTimeList.Add(trialTime);
           
            //determine if this RT was within response window of targ.
            // we have a listener in the coroutine (detectIndex). this determines whether RT was appropriate.

            if (detectIndex != 0 && !hasResponded)  // within allocated response window
            {
               // if this targ = 2 (50 % likelihood, set in targetAppearance).
               if (targetAppearance.OneorTwoFlashes == 2)
                {
                    trialParams.targCorrectList.Add(1); // right click is correct.

                    print("Correct!");
                } else
                {
                    trialParams.targCorrectList.Add(0); // right click is incorrect.
                    print("Error!");
                }

                trialParams.targResponseList.Add(2);
                trialParams.targResponseTimeList.Add(trialTime); // passed to recordData.
                //targ onset times already appended, within coroutine.
               

                ppantStaircase.corrCount++;
                
                hasResponded = true; // passed to coroutine, avoids processing omitted responses.
                // 
                // set up  contrast for the next target:
                if (TrialCount > 0 && TrialCount <= nStaircaseTrials)
                {
                    updateTargGapDuration(trialParams); // based on staircase.

                } else // also need to update trial contrast on prestaircase init
                {
                    trialParams.targGapDuration.Add(ppantStaircase.targetGap); // fixed after staircase.
                }

                recordData.collectTrialSummary();// pass to Record Data (after every hit targ)
            }
            else
            {
                print("False alarm");
                trialParams.FA_OnsetTimeList.Add(trialTime); // add FA to total list of FA
                FA_withintrial.Add(trialTime);
                ppantStaircase.errCount++;
                FAthistrial = true;
            }
        }
    }

    private void collectOmit() // only relevant to response window following targs.
    {

       
                                                
        if (trialParams.trialTypeList[TrialCount] == "present")
        {
            // Miss
            trialParams.targCorrectList.Add(0);
            trialParams.targResponseTimeList.Add(0);
            trialParams.targResponseList.Add(0); 
            print("Miss!");
            // 
            // set up  contrast for the next target:
            if (TrialCount > 0 && TrialCount <= nStaircaseTrials)
            {
                updateTargGapDuration(trialParams); // based on staircase.
            }
            else // also update targContrast store, pre staircase init.
            {
                trialParams.targGapDuration.Add(ppantStaircase.targetGap);
            }

            recordData.collectTrialSummary();// pass to Record Data (after every missed targ)

        }
    
       
    }



    private void updateTargGapDuration(trialParameters trialParams)
    {
        // last response
        int last = trialParams.targCorrectList.Count;
        int prevAcc = trialParams.targCorrectList[last-1];

        // update the targetColor within Staircase:
        ppantStaircase.UpdateStaircase(prevAcc, ppantStaircase.targetGap, trialParams.trialTypeList[TrialCount]);

        // store newly updated target contrast
        trialParams.targGapDuration.Add(ppantStaircase.targetGap);
        
    }
    
}

