using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class TestTwo : MonoBehaviour
{//事件绑定方法 events binding functions

    // Use this for initialization
    void Start()
    {
        TestOne.myEvent += FucOne;
        TestOne.myEventTwo += FucTwo;
        TestOne.myEventThree += FucThree;
        TestOne.myEventFour += FucFour;
        TestOne.myEventFive += FucFive;
        TestOne.myEventSix += FucSix;
    }

    void FucOne()
    {
        print("【Action】：无参数，无返回值");
    }

    void FucTwo(string str)
    {
        print("参数1：" + str);
    }

    void FucThree(string str, int num, bool isFuc)
    {
        print("参数1:" + str + "\n参数2：" + num + "\n参数3:" + isFuc);
    }

    string FucFour()
    {
        return "【Func<String>】";
    }

    string FucFive(int num)
    {
        print("参数：" + num);
        return "返回值：【Func<int,string>】";
    }

    string FucSix(int num, bool isFuc)
    {
        print("参数1：" + num + "\n参数2：" + isFuc);
        return "返回值：【Func<int,bool,string>】";
    }

}
