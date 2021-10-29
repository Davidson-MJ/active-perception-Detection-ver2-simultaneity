using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class showText : MonoBehaviour
{


    private TextMeshProUGUI textMesh; 
    
    private string thestring; 
    // Start is called before the first frame update
    void Start()
    {
        textMesh = gameObject.GetComponent<TextMeshProUGUI>();

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
            // update at certain points.
            thestring = "Prepare walk route: \n Align your back to the room edge, \n\n Get ready to follow the arrow!";
        }
        thestring.Replace("\\n", "\n");
        textMesh.text = thestring;
    }
}
