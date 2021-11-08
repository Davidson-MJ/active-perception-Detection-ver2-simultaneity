using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class showText : MonoBehaviour
{


    private TextMeshProUGUI textMesh;
    runExperiment runExperiment;
    private string thestring; 
    // Start is called before the first frame update
    void Start()
    {
        textMesh = gameObject.GetComponent<TextMeshProUGUI>();
        runExperiment = GameObject.Find("scriptHolder").GetComponent<runExperiment>();

    }

    //
    public void updateText(int text2show)
    {
        if (text2show == 0)
        {
            // hide text 
            thestring= ""; // blank
        }
        else if (text2show == 1)
        {
            // update at certain points.
             thestring = "Welcome! \n When the orb is green: Left click to start Trial \n\n" +
                " When the orb is grey: Watch for brief flashes." +
                "If you perceive '1' flash, click Left; \n\n" + 
                "If you perceive '2' flashes, click Right.";
        }else if (text2show == 2)
        {
            thestring = "Well done! \n Now, your task is the same, but must be completed while walking." +
                  "Align your back to the edge of the room. \n\n When ready, pull the <left> Trigger to begin. Get ready to follow the arrow!";

        }

        else if (text2show == 3)
        {
            thestring = "Pull the <left> trigger to begin Trial " + runExperiment.TrialCount + 1 + " / " + runExperiment.nAllTrials; ; // blank
        }
        thestring.Replace("\\n", "\n");
        thestring.Replace("\\n", "\n");
        textMesh.text = thestring;
    }
}
