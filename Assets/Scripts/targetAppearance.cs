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
            float jitter = Random.Range(0.01f, 0.02f);
            // pseudo randomly space targets, with minimum ITI of responseWindow

            if (runExperiment.TrialType == 8)
            {
                // 8 targets squeezed in quick succession:
                preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1] - 7 * (trialParams.minITI + jitter));

                // next target 2/8:
                preTargISI[1] = Random.Range(preTargISI[0] + trialParams.minITI, trialParams.targRange[1] - 6 * (trialParams.minITI + jitter));

                // targ 3/8
                preTargISI[2] = Random.Range(preTargISI[1] + trialParams.minITI, trialParams.targRange[1] - 5 * (trialParams.minITI + jitter));

                // targ 4/8
                preTargISI[3] = Random.Range(preTargISI[2] + trialParams.minITI, trialParams.targRange[1] - 4 * (trialParams.minITI + jitter));

                // targ 5/8
                preTargISI[4] = Random.Range(preTargISI[3] + trialParams.minITI, trialParams.targRange[1] - 3 * (trialParams.minITI + jitter));


                preTargISI[5] = Random.Range(preTargISI[4] + trialParams.minITI, trialParams.targRange[1] - 2 * (trialParams.minITI + jitter));


                preTargISI[6] = Random.Range(preTargISI[5] + trialParams.minITI, trialParams.targRange[1] - (trialParams.minITI + jitter));

                //targ 8/8
                preTargISI[7] = Random.Range(preTargISI[6] + trialParams.minITI, trialParams.targRange[1]);


            }
            else if (runExperiment.TrialType == 6) // increased spacing between targs
            {
                //restricted range to ensure spacing.
                // need to leave room for 3 targ and response after the first.
                preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1] - 8 * (trialParams.minITI + jitter));
                // next target 2/4:
                preTargISI[1] = Random.Range(preTargISI[0] + trialParams.minITI, trialParams.targRange[1] - 6 * (trialParams.minITI + jitter));
                // targ 3/4
                preTargISI[2] = Random.Range(preTargISI[1] + trialParams.minITI, trialParams.targRange[1] - 4 * (trialParams.minITI + jitter));

                preTargISI[3] = Random.Range(preTargISI[1] + trialParams.minITI, trialParams.targRange[1] - 3 * (trialParams.minITI + jitter));

                preTargISI[4] = Random.Range(preTargISI[1] + trialParams.minITI, trialParams.targRange[1] -  (trialParams.minITI + jitter));
               
                preTargISI[5] = Random.Range(preTargISI[2] + trialParams.minITI, trialParams.targRange[1]);
            }
            else if (runExperiment.TrialType == 4) // increased spacing between targs
            {
                //restricted range to ensure spacing.
                // need to leave room for 3 targ and response after the first.
                preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1] - 6 * (trialParams.minITI + jitter));
                // next target 2/4:
                preTargISI[1] = Random.Range(preTargISI[0] + trialParams.minITI, trialParams.targRange[1] - 4 * (trialParams.minITI + jitter));
                // targ 3/4
                preTargISI[2] = Random.Range(preTargISI[1] + trialParams.minITI, trialParams.targRange[1] - 2*(trialParams.minITI + jitter));

                preTargISI[3] = Random.Range(preTargISI[2] + trialParams.minITI, trialParams.targRange[1]);
            }
            else if (runExperiment.TrialType == 3)
            {
                //restricted range to ensure spacing.
               // need to leave room for 2 targ and response after the first.
               preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1] - (2*trialParams.minITI + 2*jitter));
                // next target after time has elapsed to respond to first:
               preTargISI[1] = Random.Range(preTargISI[0]+trialParams.minITI, trialParams.targRange[1] - (trialParams.minITI + jitter));
                // remaining window:
               preTargISI[2] = Random.Range(preTargISI[1]+trialParams.minITI, trialParams.targRange[1]);

            }
            else if (runExperiment.TrialType == 2) // place 2 targets in trial, separated by min spacing.
            {
                //first targ just needs to leave enough room for the second (after a response)
                preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1]-(trialParams.minITI+jitter));
                // second can come anywhere after the first.
                preTargISI[1] = Random.Range(preTargISI[0]+trialParams.minITI, trialParams.targRange[1]);

            }
            else if (runExperiment.TrialType == 1) // use full range of trial to decrease predictability.
            {
                preTargISI[0] = Random.Range(trialParams.targRange[0], trialParams.targRange[1]);

            }
            else if (runExperiment.TrialType == 0) // no targets
            {
                trialParams.targOnsetTimeList.Add(-1); // place holder so that the onset, response, and corr, lists remain the same length.
                trialParams.targResponseTimeList.Add(-1);
                trialParams.targResponseList.Add(-1);
                //targCorrList appended after (see Update()), based on whether clicks recorded (FAthistrial)
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
                for (int itargindx = 0; itargindx < runExperiment.TrialType; itargindx++)
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
                    setColour(ppantStaircase.targetColor);
                    runExperiment.targState = 1; // target is shown
                    runExperiment.detectIndex = itargindx + 1; //  click responses collected in this response window will be 'correct'
                    runExperiment.hasResponded = false;  //switched if targ detected.
                    trialParams.targOnsetTimeList.Add(runExperiment.trialTime);
                    //how long to show target for?
                    yield return new WaitForSecondsRealtime(trialParams.targDurationsec);
                    setColour(ppantStaircase.probeColor); // return to original colour:
                    runExperiment.targState = 0; // target is removed

                    if  (OneorTwoFlashes==2)
                    {
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

                    
                    
                    yield return new WaitForSecondsRealtime(trialParams.responseWindow);

                    // if no click in time, count as a miss.
                    if (!runExperiment.hasResponded) // no response 
                    {
                        processNoResponse = true;
                    }
                    runExperiment.detectIndex = 0; //clicks from now  counted as incorrect (too slow).
                    runExperiment.targCount++;
                }

               
            }
            // after for loop, wait for trial end:
            while (runExperiment.trialTime < motionParams.walkDuration)
            {
                yield return null;  // wait until next frame. 
            }

        }

    }

    // color change method.
    public void setColour(Color newCol)
    {
        // because we are changing the sphere shaders colour, keep the alpha.
        //print("New Color: " + newCol);
        rend.material.SetColor("_Color", newCol);


    }
}
