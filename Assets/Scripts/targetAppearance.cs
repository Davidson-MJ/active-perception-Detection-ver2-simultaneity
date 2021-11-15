using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class targetAppearance : MonoBehaviour
{
    /// <summary>
    /// Handles the co-routine to precisely time changes to target appearance during walk trajectory.
    /// 
    /// Main method called from runExperiment.
   
    
    public bool processNoResponse;
    private float waitTime;
    public int OneorTwoFlashes;
    private float subtr;
    runExperiment runExperiment;
    Renderer rend;
    trialParameters trialParams;
    Staircase ppantStaircase;
    walkParameters motionParams;

    private void Start()
    {
        runExperiment = GameObject.Find("scriptHolder").GetComponent<runExperiment>();
        trialParams = GameObject.Find("scriptHolder").GetComponent<trialParameters>();
        ppantStaircase = GameObject.Find("scriptHolder").GetComponent<Staircase>();
        motionParams = GameObject.Find("scriptHolder").GetComponent<walkParameters>();
        rend = GetComponent<Renderer>(); // change colour of shade, not texture (separate sphere).
        processNoResponse = false;
    }

   public void startSequence()
    {
        StartCoroutine("trialProgress");
    }

    /// <summary>
    /// Coroutine controlling target appearance with precise timing.
    /// </summary>
    /// <returns></returns>

    // the following coroutine controls the timing of stimulus changes.
    IEnumerator trialProgress()
    {
        while (runExperiment.trialinProgress) // this creates a never-ending loop for the co-routine.
        {
            // trial progress:
            /// The timing of trial elements is determined on the fly.
            /// Boundaries set in trialParameters.

            // predetermine target onset times:
            OneorTwoFlashes = 0; // reset this listener.

            float[] preTargISI = new float[runExperiment.TrialType]; // 
            float[] gapsare = new float[runExperiment.TrialType]; // used to calc preTargISI below
            float jitter = Random.Range(0.01f, 0.02f);
            // pseudo randomly space targets, with minimum ITI of responseWindow
            // note that these trial times have been simulated, don't tweak without running another simulation to ensure decent spread.
            
            // shift the intertrial ISI on random trials:
            subtr = Random.Range(0f, .5f);

            if (runExperiment.TrialType == 9)
            {
                gapsare[0] = 8.6f - subtr; // 
                gapsare[1] = 7.5f - subtr;
                gapsare[2] = 6.4f - subtr;
                gapsare[3] = 5.3f - subtr;
                gapsare[4] = 4.2f - subtr;
                gapsare[5] = 3.2f - subtr; 
                gapsare[6] = 2.1f - subtr; 
                gapsare[7] = 0f;
            }
            else if (runExperiment.TrialType == 8)
            {
                gapsare[0] = 7.7f - subtr; // 
                gapsare[1] = 6.6f - subtr;
                gapsare[2] = 5.5f - subtr;
                gapsare[3] = 4.4f - subtr;
                gapsare[4] = 3.3f - subtr;
                gapsare[5] = 2.2f - subtr;
                gapsare[6] = 1.1f - subtr;
                gapsare[7] = 0f;
            }
            else if (runExperiment.TrialType == 7)
            {
                gapsare[0] = 8f - subtr; // 
                gapsare[1] = 6.9f - subtr;
                gapsare[2] = 5.8f - subtr;
                gapsare[3] = 4.7f - subtr;
                gapsare[4] = 3.6f - subtr;
                gapsare[5] = 2.5f;
                gapsare[6] = 0f;
            }
            else if (runExperiment.TrialType == 6)
            {
                gapsare[0] = 5.75f-subtr; // 
                gapsare[1] = 4.75f - subtr;
                gapsare[2] = 3.75f - subtr;
                gapsare[3] = 2.75f - subtr;
                gapsare[4] = 1.75f - subtr;
                gapsare[5] = 0f;

            } else if (runExperiment.TrialType == 5)
            {
                gapsare[0] = 4.25f - subtr;
                gapsare[1] = 3.25f - subtr;
                gapsare[2] = 2.25f - subtr;
                gapsare[3] = 1.25f - subtr;
                gapsare[4] = 0f;
            } else if (runExperiment.TrialType == 4)
            {
                gapsare[0] = 3.75f - subtr;
                gapsare[1] = 2.5f - subtr;
                gapsare[2] = 1.5f - subtr;
                gapsare[3] = 0.5f - subtr;
            }

            // now prefill the preTargISI
            for (int itargindx = 0; itargindx < gapsare.Length; itargindx++)
            {
                if (itargindx == 0) // start at trial beginning. targRange[0]
                {
                    preTargISI[itargindx] = Random.Range(trialParams.targRange[0], trialParams.targRange[1] - gapsare[itargindx] * (trialParams.minITI + jitter));

                } else // use prev targ presentation as earliest point:
                {
                    preTargISI[itargindx] = Random.Range(preTargISI[itargindx-1], trialParams.targRange[1] - gapsare[itargindx] * (trialParams.minITI + jitter));

                }
                
            }

            runExperiment.detectIndex = 0; // listener, to assign correct responses per target [0 = FA, 1 = targ1, 2 = targ 2]

            // change target colour to indicate trial prep ("Get Ready!")
            setColour(ppantStaircase.preTrialColor);

            //now change colour and wait before target Onset.
            yield return new WaitForSecondsRealtime(trialParams.preTrialsec);
            setColour(ppantStaircase.probeColor);




            // show target [use duration or colour based on staircase method].
            // show target on present trials.
            if (trialParams.trialTypeList[runExperiment.TrialCount] == "present") // all targ types (1 incl).
            {
                //// however many targets we have to present this trial, cycle through and present


                // set at chance whether 1 or 2 will be presented.
                for (int itargindx = 0; itargindx < gapsare.Length; itargindx++)
                {


                    // coin flip:

                    if (Random.value < 0.5f)
                    {
                        OneorTwoFlashes = 1;
                        print("One flash incoming");
                    }
                    else
                    {
                        OneorTwoFlashes = 2;
                        print("Two flashes incoming");
                    }

                    // first target has no ISI adjustment
                    if (itargindx == 0)
                    {
                        waitTime = preTargISI[0];
                    }
                    else
                    {// adjust for time elapsed.
                        waitTime = preTargISI[itargindx] - runExperiment.trialTime;
                    }

                    // wait before presenting target:
                    yield return new WaitForSecondsRealtime(waitTime);

                    // change colour - detect window begins.
                    runExperiment.pauseRW = 1; // pause RW of target (so single and double flashes are in same location).
                    setColour(ppantStaircase.targetColor);
                    runExperiment.targState = 1; // target is shown
                    runExperiment.detectIndex = itargindx + 1; //  click responses collected in this response window will be 'correct'
                    runExperiment.hasResponded = false;  //switched if targ detected.
                    trialParams.targOnsetTimeList.Add(runExperiment.trialTime);
                    //how long to show target for?
                    yield return new WaitForSecondsRealtime(trialParams.targDurationsec);
                    setColour(ppantStaircase.probeColor); // return to original colour:
                    runExperiment.targState = 0; // target is removed

                    if (OneorTwoFlashes == 2)
                    {

                        /// we will also jitter the second flash ( so contrast isn't repeated).
                        float jit = Random.Range(-0.025f, 0.025f);
                        ppantStaircase.targetColor = new  Color(ppantStaircase.targetColor[1] + jit, ppantStaircase.targetColor[1] + jit, ppantStaircase.targetColor[1] + jit, ppantStaircase.targetAlpha);

                        // wait gap dur, then present another target.
                        yield return new WaitForSeconds(ppantStaircase.targetGap);
                        // change colour - detect window begins. 
                        setColour(ppantStaircase.targetColor);
                        runExperiment.targState = 1; // target is shown
                        yield return new WaitForSecondsRealtime(trialParams.targDurationsec);

                        // note the trial type (nflashes) passed to recordData.
                        setColour(ppantStaircase.probeColor); // return to original colour:
                        runExperiment.targState = 0; // target is removed
                       
                    }
                    runExperiment.pauseRW = 0;


                    yield return new WaitForSecondsRealtime(trialParams.responseWindow);

                    // if no click in time, count as a miss.
                    if (!runExperiment.hasResponded) // no response 
                    {
                        processNoResponse = true;
                    }
                    runExperiment.detectIndex = 0; //clicks from now  counted as incorrect (too slow).
                    runExperiment.targCount++;
                }


            } //if present
            // after for loop, wait for trial end:
            while (runExperiment.trialTime < motionParams.walkDuration)
            {
                yield return null;  // wait until next frame. 
            }
        } //while in trial

    } //enumerator
                

     
    // color change method.
    public void setColour(Color newCol)
    {
        // because we are changing the sphere shaders colour, keep the alpha.
        //print("New Color: " + newCol);
        rend.material.SetColor("_Color", newCol);


    }
}
