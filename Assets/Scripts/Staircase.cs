using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Staircase : MonoBehaviour
{
    /// <summary>
    ///  Controls the gap duration between target flashes, based on previous trial history.
    ///  target appearnce changes are performed in the coroutine of targetAppearance.cs;
  
    /// </summary>
    // working with 2AFC (1/2 targs perceived) discrim responses, so can simplify:

    [Header("Difficulty setting:")]
    public string curUpdate;
    public float PercentDetect2flash; 
    public int  prevResp, callCount, nCorrReverse, nErrReverse, corrCount, errCount, numCorrect, numError, reverseCount, corrInrow;
    //public bool ascending, initialAscending, updateStepSize = false; // initially going up/down?

    private float targetTestgapDuration;
   
    public float probeContrast, targetGap, stepSize;
   
    // colors [ contrast is updated within staircase]
    public Color preTrialColor; // green, to show ready/idle state
    public Color probeColor; // grey
    public Color targetColor; // white, set at high contrast
    public float targetDuration; // flash duration, DV is the gap
    public float targetAlpha;
    public float targetContrast;
    
    private void Start()
    {
        // get nStaircasetrials and other 


        //float stepSize = .01f; // needs to be pilotted
        //int nCorrReverse = 2; // adjust the contrast values if 2 correct in a row (increase difficulty).
        //int nErrReverse = 1;  // adjust the contrast values if 1 error (decrease difficulty)
        stepSize = .005f; //  in sec
        callCount = 0;
        reverseCount = 0;
        corrInrow = 0;
        corrCount = 0; errCount = 0;
        numCorrect = 0;
        numError = 0;
       
        curUpdate = null;
        nCorrReverse = 3; // 3 down 1 up approximates 80% cor (1/2)^(1/3)
        //nCorrReverse = 2; // 2 down 1 up approximates 74% cor (1/2)^(1/3)
        nErrReverse = 1;
        PercentDetect2flash = 0f;
        targetAlpha = .8f;
        // set colours
         preTrialColor= new Color(0f, 0.5f, 0f, targetAlpha); //drk green
         probeColor = new Color(0.4f, 0.4f, 0.4f, targetAlpha); // dark grey

        // now, we will update target colour for each target, jittering about 0.7 (see below).
        targetColor= new Color(.7f, .7f, .7f, targetAlpha); // bright grey (fixed).


        probeContrast = probeColor[1];
        targetGap = 0.07f; // start at 70 ms.
        targetDuration = 0.05f; //50 ms. (fixed).



    }


    public void UpdateStaircase(int responseAcc, float prvTargGap, string trialType)
    {

        callCount++;
        // work through options:
        // correct detects first (staircase isn't updated after correct rejections).
        if (reverseCount == 5 && numError < 10) // reduce step size only once.
        {
            //print("reducing step size");
            stepSize = stepSize /2;
            reverseCount = 0;

        }
        

        if (responseAcc == 1)
        {
            corrCount++;
            numCorrect++;

            if (corrCount >= nCorrReverse)
            {
                // if response was correct n times in a row, decrease gap size
                corrCount = 0; // reset
                curUpdate = "Increasing difficulty.";
                targetTestgapDuration = prvTargGap - stepSize;
                corrInrow++;

                if (targetTestgapDuration < 0)
                {
                    targetTestgapDuration = stepSize; //avoid overshooting.
                    //stepSize = stepSize / 2;
                }

            }  else
            {
                // maintain difficulty.
               
                curUpdate = "corr (no change)";
                targetTestgapDuration = prvTargGap;

            }
        }
            

        // incorrect:
        if (responseAcc == 0)
        {

            errCount++; // running total, resets on reverse
            numError++; // grand total

            if (errCount >= nErrReverse)
            {
                // if response was incorrect nErrReverse times in a row,  decrease difficulty.
                errCount = 0; //reset counter
                
                reverseCount++; // keep track of how many times, to update staircase step size
                curUpdate = "Decreasing difficulty"; //.
                targetTestgapDuration = prvTargGap + stepSize;
            } else
            {
                // do something. since nErrReverse is 1, 

                targetTestgapDuration = prvTargGap;
                curUpdate = "errNochange";
            }
        }


        PercentDetect2flash = ((float)numCorrect / (float)callCount)*100; // total correct detect divide amount of targs presented.

        prevResp = responseAcc;

        print(curUpdate);
        print("Targ Gap: " + targetTestgapDuration);
        // update public target color:
        // display public params:
       
        targetGap = targetTestgapDuration;
        probeContrast = probeColor[1];

        // to increase difficulty of the task, jitter the targetColour so that luminance summation cannot be used
        //(relibaly) to estimate 2flashes.
         float targJitter =  Random.Range(0.65f, 0.75f);

        //targetColor = new Color(.7f, .7f, .7f, targetAlpha); // bright grey (fixed).
        targetColor = new Color(targJitter, targJitter, targJitter, targetAlpha);
        targetContrast = targetColor[0];

    }
}
