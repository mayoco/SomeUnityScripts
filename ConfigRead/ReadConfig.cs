using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
public class ReadConfig : MonoBehaviour
{//从配置文件中 读取分辨率 待机时间 并设置
    int width = 1920;
    int height = 1080;
    float waitTime = 60;
    //public CanvasScaler canvasScaler;
    // Start is called before the first frame update
    void Start()
    {
        // 从配置文件读取
        string configFile = Application.dataPath + "/config.ini";//打包好的“xxx_Data”目录貌似没有读取里面的文件权限
        //所以对于打包的程序，需要把配置文件config.ini放在exe同目录下
#if !UNITY_EDITOR
    configFile = System.Environment.CurrentDirectory + "/config.ini";
#endif
        if (File.Exists(configFile))
        {
            ConfigIni ini = new ConfigIni(configFile);
            width = int.Parse(ini.keyVal["width"]);
            height = int.Parse(ini.keyVal["height"]);
            waitTime = float.Parse(ini.keyVal["waittime"]);
        }
        else
        {
            Debug.Log("没找到 "+configFile+"自动生成");
            File.WriteAllText(configFile, "width = 1920\nheight = 1080\nwaittime = 60");
        }
        Screen.SetResolution(width, height, true);
        //SetScale(width,height);
        GetComponent<BackGroundVideo>().SetWaitTime(waitTime);//设置待机视频的等待时间
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //void SetScale(float widthFromConfig, float heightFromConfig)//屏幕UI适配 以宽度为准缩放 等效于在canvas下设置Scale with Screen Size
    //{
    //    float wScale = Screen.width / widthFromConfig;
    //    float hScale = Screen.height / heightFromConfig;

    //    canvasScaler.scaleFactor = wScale;
    //}

}
