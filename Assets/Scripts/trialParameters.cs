using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class trialParameters : MonoBehaviour
{
    // predefine the stimulus parameters to be used on each trial, that are not updated based on staircase.

    // within trial data params and storage [ move to scriptable object?]

    public float preTrialsec = 0.5f; // buffer for no targ onset. (1 step)
    public float responseWindow = 1.5f; // this is the response window to record detection (after target onset).
    public float targDurationsec = 0.02f; // 20 ms
    public float minITI; //response window + targDursec

    // to be filled on Start():
    private float trialDur;
    private float nTrials;
    private float nUniqueConditions;
    private int trialsperCondition;
    public int[] trialTypeArray;
    //private float startBuffer_sec = 1f; // hard minimum before walk START that targ can appear.
    //private float end_Buffer_sec = 1f; // hard minimum before walk duration END that targ can appear.
    //public float[] targ1rangelims = { 0.6f, 1.2f }; // targ 1 can appear in here, relative to walk Onset.
    //public float[] targ2rangelims = { 1.8f, 2.4f }; // targ 2 can appear in here, relative to walk Onset.
    //public float[] targ3rangelims = { 3f, 3.6f };
    //public float[] targ4rangelims = { 4.2f, 4.4f }; // short window at end with enough time for response.
    public float[] targRange;
    private int[] targsPresented; // 0,4,or 8 for the A19 walk space, set per trial.


    // TODO: autogenerate pseudo random targ intervals based on the walkDuration. With minimum spacing between targs as responseWindow+small jitter.


    // import other settings:
    walkParameters walkParameters;
   runExperiment runExperiment;

    // create public lists of for accessing in runExperiment. TODO: Must be an easier way to store different types - like a dict or struct?
    //these increment on walk traj.
    public List<string> trialTypeList = new List<string>();
    public List<int> walkCountList = new List<int>();
    //these increment on targets:
    public List<float> targResponseList = new List<float>();
    public List<int> targCorrectList = new List<int>();
    public List<float> targResponseTimeList = new List<float>();
    public List<float> targOnsetTimeList = new List<float>();

    public List<float> targGapDuration = new List<float>();
    //this increments on every click (check for False alarms offline).

    public List<float> clickOnsetTimeList = new List<float>();
    public List<float> FA_OnsetTimeList = new List<float>(); // collect all false alarms, over whole exp

    public List<int> trialsper = new List<int>(); 
    

    void Start()
    {
        walkParameters = GameObject.Find("scriptHolder").GetComponent<walkParameters>();
        runExperiment = GameObject.Find("scriptHolder").GetComponent<runExperiment>();
        // gather presets
        trialDur = walkParameters.walkDuration; // in second, determines how many targets we can fit in.

        minITI = responseWindow + 2*targDurationsec+  .15f; //be conservative with ntargs, since gap might be large (starts at .07s)

        float availTime = trialDur - (preTrialsec + responseWindow); // when can targets appear in walk?
        float nTargPres = Mathf.Floor(availTime / minITI); // how many targs in this window

        nTrials = runExperiment.nAllTrials;

        nUniqueConditions = nTargPres - 1;// no targ, up to nTarg (indexed at 0,1,2...)

        // % split. for the n conditions.
        trialsperCondition = (int)Mathf.Floor(nTrials / 10); // 5% of trials as catch, 
        print("creating trial allocation for max " + (nUniqueConditions - 1) + " targets");

        // next, we will determine how many targets to present in our given walk duration (max 3 for home testing).
        // prefill the trialTypeArrayy as we go:

        // prefill target information (present or absent trial types).
        trialTypeArray = new int[(int)nTrials];
        
        int icounter = 0;
        // just fit the max in:
        trialsper.Add(trialsperCondition*3); // *10% of trials
        trialsper.Add(trialsperCondition * 3); //
        trialsper.Add(trialsperCondition * 4); //max target case
       


        targRange = new float[2];
        targRange[0] = preTrialsec + responseWindow; // minimum targ onset time.
        targRange[1] = trialDur - responseWindow - 0.3f; // max onset time, w/ extra buffer for late targets to be detected.

        // prefill array:
        targsPresented = new int[3];
        // have removed the 'absent' condition, pointless.
        targsPresented[1] = 4;
        targsPresented[2] = 5;
        targsPresented[3] = 6;

        // prefill array:
        for (int icond= 0; icond <3; icond++)
        {
            for (int itrial = 0; itrial < trialsper[icond]; itrial++)
            {
                trialTypeArray[icounter] = targsPresented[icond];
                icounter++;
            }

        }
        

        // now shuffle this array:
        shuffleArray(trialTypeArray);

        ////// Now populate are lists.


        for (int itrial = 0; itrial < nTrials; itrial++) // for every walk trajectory.
        {
            // how many targs this walk?
            int thisN = trialTypeArray[itrial];
            if (thisN == 0)
            {
                trialTypeList.Add("absent");
            }else
            {
                trialTypeList.Add("present");
            }
         



        }


    }
    // shuffle array once populated.
    void shuffleArray(int[] a)
    {
        int n = a.Length;


        for (int id = 0; id < n; id++)
        {
            swap(a, id, id + Random.Range(0, n - id));
        }
    }
    void swap(int[] inputArray, int a, int b)
    {
        int temp = inputArray[a];
        inputArray[a] = inputArray[b];
        inputArray[b] = temp;

    }
}



