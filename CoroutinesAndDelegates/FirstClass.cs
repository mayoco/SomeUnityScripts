using UnityEngine;
using System.Collections;

public class FirstClass: MonoBehaviour{
    //public delegate void Print();
    public delegate void Print(string message);
    public static event Print print;
    
    
    //Trick for Data Encapsulation: Visible in inspector and can drag reference to it and keep it private
    [SerializeField]
    private GameObject someRef;
    
    void Start(){
    //StartCoroutine (DelayTime());
    
        if(print!=null){
            //print();
            print("Handling the event again");
        }
    }
    
    void Update(){
    
    }
    
    IEnumerator DelayTime(){
    
    yield return new WaitForSeconds(2f);
    
    Debug.Log("Waited 2 seconds");
    
    }
}
