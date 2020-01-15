using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class ConfigReadTest : MonoBehaviour
{
    float a;
    // Start is called before the first frame update
    void Start()
    {
        // 从配置文件读取
        string configFile = Application.dataPath + "/config.ini";//打包好的“xxx_Data”目录貌似没有读取里面的文件权限
                                                                 //所以对于打包的程序，需要把配置文件config.ini放在exe同目录下
        Debug.Log("Read image setting from :" + configFile);
#if !UNITY_EDITOR
    configFile = System.Environment.CurrentDirectory + "/config.ini";
#endif
        if (File.Exists(configFile))
        {
            ConfigIni ini = new ConfigIni(configFile);

            a = float.Parse(ini.keyVal["TopLeftX"]);
            Debug.Log("ConfigReadTest a : " + a);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
