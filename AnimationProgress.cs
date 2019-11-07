using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationProgress : MonoBehaviour{
    public Animator animatorA;//drag reference in inspector
    
    public void PlayAnimation(){
        animatorA.speed=1;
    }
    
    public void PauseAnimation(){
        animatorA.speed=0;
    }
    
    public float GetAnimationProgress(){//return value 0-1 ; start to finish.
        return animatorA.GetCurrentAnimatorStateInfo(0).normalizedTime;
    }

}
