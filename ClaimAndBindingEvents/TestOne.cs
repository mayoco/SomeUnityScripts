using System;
using UnityEngine;


public class TestOne : MonoBehaviour
{//声明事件 claim events

    #region Action 表式无参数无返回值
    /// <summary>
    ///这个式子等同于
    /// public delegate void Mydelegate();
    /// publid static event Mydelegate myEvent;
    /// </summary>
    public static event Action myEvent;
    #endregion

    #region Action<> 带参数
    /// <summary>
    ///这个式子等同于
    /// public delegate void Mydelegate(string str);
    /// publid static event Mydelegate myEventTwo;
    /// </summary>
    public static event Action<String> myEventTwo;
    /// <summary>
    ///这个式子等同于
    /// public delegate void Mydelegate(string str,int num,bool isFuc);
    /// publid static event Mydelegate myEventThree;
    /// </summary>
    public static event Action<String, int, bool> myEventThree;
    #endregion

    #region Func<string> 带返回值，无参数
    /// <summary>
    ///这个式子等同于
    /// public delegate string Mydelegate();
    /// publid static event Mydelegate myEventFour;
    public static event Func<string> myEventFour;
    #endregion

    #region Func<string,int> string参数 int返回值
    /// <summary>
    ///这个式子等同于
    /// public delegate string Mydelegate(int num);
    /// publid static event Mydelegate myEventFive;
    public static event Func<int, string> myEventFive;
    /// <summary>
    ///这个式子等同于
    /// public delegate string Mydelegate(int num,bool isFuc);
    /// publid static event Mydelegate myEventFive;
    public static event Func<int, bool, string> myEventSix;
    #endregion

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            if (myEvent != null)
            {
                myEvent();
            }

            if (myEventTwo != null)
            {
                myEventTwo("Action<String>");
            }

            if (myEventThree != null)
            {
                myEventThree("Action<String,int.bool>", 10, true);
            }

            if (myEventFour != null)
            {
                print(myEventFour());
            }

            if (myEventFive != null)
            {
                print(myEventFive(1));
            }

            if (myEventSix != null)
            {
                print(myEventSix(10, true));
            }
        }

    }

}
