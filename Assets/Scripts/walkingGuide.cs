using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class walkingGuide : MonoBehaviour
{
    // this Script is attached to the motionPath GameObject.
    //public static stimulusParameters.stimulusAttributes parameter =
    //    new stimulusParameters.stimulusAttributes(); // experimental parameters class

    walkParameters walkParameters; // call Component on Start.
    changeDirectionMaterial changeDirectionMaterial;

    Vector3[] accelerationStartPoint, startPoint, endPoint;
    int whichPointSet;
    public bool flipDirection = false;
    public float remainingDistance;

    // set phases of guide motion.
    public enum motion
    {
        idle,
        start,
        inMotion
    };
    //start in idle.
    public motion walkMotion = motion.idle;
    public motion returnRotation = motion.idle;

    public enum motionProfile
    {
        idle,
        acceleration,
        linear
    };
    motionProfile motionPhase = motionProfile.idle;
    Vector3 startPosition, rotatingPosition;

    public float radius = 1.5f; //0.5f seems to be the path for the Wguide to trace before next trial.
    float xAdjustment; // for updating position at trial end (about-face)
    float speed = 1;
    int direction;

    float tDelta = 0;
    float tFin = 0;
    // we need the public bool for staircase or not, to control walkig guide.
    runExperiment runExp;
    void Start()
    {
        // access parameters for this experiment (set in separate script).
        walkParameters = GameObject.Find("scriptHolder").GetComponent<walkParameters>();
        runExp = GameObject.Find("scriptHolder").GetComponent<runExperiment>();
        changeDirectionMaterial = GameObject.Find("directionCanvas").GetComponent<changeDirectionMaterial>();
        // update local position height if necessary
        Vector3 updatePosition = new Vector3(0, walkParameters.reachHeight, 0);
        transform.localPosition = updatePosition;


        accelerationStartPoint = new Vector3[2]; // creates 3D vector, stopping at index 2. so [0 , 1] are 3D arrays
        startPoint = new Vector3[2];
        endPoint = new Vector3[2];

        fillStartPos(); // this method also called at beginning of walk session.
    }

    void Update()
    {

        if (!runExp.isPractice) // if not a calibration trial. begin motion.
        {

            if (walkMotion == motion.start) // update sesssion flow:
            {
                flipDirection = !flipDirection;
                tDelta = 0;
                remainingDistance = walkParameters.walkingPathDistance;

                if (flipDirection)
                {
                    whichPointSet = 0;
                }
                else
                {
                    whichPointSet = 1;
                }

                walkMotion = motion.inMotion;
                motionPhase = motionProfile.linear; // was acceleration.
            }

            if (walkMotion == motion.inMotion)
            {
                // acc or linear motion
                applyMotion();
            }

            if (returnRotation == motion.start)
            {
                // change arrow guide every return rotation.?
                setReturnDestination();


            }

            if (returnRotation == motion.inMotion)
            {
                // motion guide traverses the radius 180 degrees to align with new destination
                aboutFace();

            }
        }

    }
    /// <summary>
    /// methods
    /// </summary>
    private void applyMotion()
    {

        //print(motionPhase);
        
        //if (motionPhase == motionProfile.acceleration)
        //{
            //tDelta += Time.deltaTime;



            //Vector3 updatePosition =
            //Vector3.Lerp(accelerationStartPoint[whichPointSet], startPoint[whichPointSet], tDelta/walkParameters.walkDuration);
            //Vector3 updatePosition =
            //Vector3.Lerp(accelerationStartPoint[whichPointSet], startPoint[whichPointSet], ((Mathf.Sin(tDelta) + 1) / Mathf.Sin(Mathf.PI / 2)));
           
            //Vector3 updatePosition = Vector3.Lerp(startPoint[whichPointSet], endPoint[whichPointSet], tDelta / walkParameters.walkDuration);
            //transform.localPosition = updatePosition;


            //transform.localPosition = updatePosition;

            //if (tDelta >= walkParameters.rampDuration) //(3 * (Mathf.PI / 2) + (Mathf.PI / 2))) // what's going on here? mjd tDelta ~ 6.2 ?
            //{
            //    tDelta = 0;
            //    motionPhase = motionProfile.linear;
            //}
        //}

        if (motionPhase == motionProfile.linear)
        {
            tDelta += Time.deltaTime;
            //print("CurrentPos:" + transform.localPosition + " heading to " + endPoint[whichPointSet]);
            //print("whichpointset:" + whichPointSet);

            Vector3 updatePosition = Vector3.Lerp(startPoint[whichPointSet], endPoint[whichPointSet], tDelta / walkParameters.walkDuration);
            transform.localPosition = updatePosition;

            // 
           
                remainingDistance = Mathf.Abs(Mathf.Abs(updatePosition.x) - Mathf.Abs(endPoint[whichPointSet].x));
            
          
            //print("remaining distance:" + remainingDistance);

            //// check trial length (based on duraton)
            //if (remainingDistance <= .001f)
            //{
            //    walkMotion = motion.idle;
            //    motionPhase = motionProfile.idle;
            //    print("trial over (distance): idle");
            //}

            // check trial length (based on duraton)
            if (tDelta >= walkParameters.walkDuration)
            {
                walkMotion = motion.idle;
                motionPhase = motionProfile.idle;
                print("trial over (duration): idle");
            }

        }
    }

    private void setReturnDestination()
    {
        // flip arrow guide:
        // if not practice, flip arrow to match walk direction.
        changeDirectionMaterial.flipArrow();
        
        startPosition = transform.localPosition;
        rotatingPosition = Vector3.zero;

        if (flipDirection)
        {
            tDelta = 3 * (Mathf.PI / 2);
            xAdjustment = radius;
            direction = 1;
        }
        else
        {
            tDelta = 3 * (Mathf.PI / 2);
            xAdjustment = -radius;
            direction = -1;
        }

        tFin = tDelta + Mathf.PI;
        returnRotation = motion.inMotion;
    }

    private void aboutFace() // motion guide traverses the radius 180 degrees to align with new destination
    {
        
        

        float theta = tDelta * direction ;

        rotatingPosition.x = (Mathf.Sin(theta) * radius);// xAdjustment;
        rotatingPosition.z = Mathf.Cos(theta) * radius;

        transform.localPosition = startPosition + rotatingPosition;

        tDelta += Time.deltaTime * speed; // speed set to 1. what was this for?

        if (tDelta > tFin)
        {
            returnRotation = motion.idle;
        }
    }

    public void fillStartPos()
    {

        // fill the above 3D pos. (based on coords in world space).
        for (int i = 0; i < 2; i++)
        {
            accelerationStartPoint[i] = transform.localPosition; // local position, relative to origin.
            startPoint[i] = transform.localPosition;
            endPoint[i] = transform.localPosition;
        }

        // update above vectors.
        // we want to start at the current position.

        //startPoint[0].x = accelerationStartPoint[0].x;
        endPoint[0].x = startPoint[0].x - walkParameters.walkingPathDistance; // need to account for radius.
        // then turn and come back.

        startPoint[1].x = endPoint[0].x;
        endPoint[1].x = startPoint[0].x;


    }
}
