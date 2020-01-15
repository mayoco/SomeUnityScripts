using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;

/// <summary>
/// 读取ini配置文件
/// [Time] 
/// time=10 
/// [Speed] 
/// speed=5 
/// ConfigIni ini=new ConfigIni(Application.StreamingAssets+"/Setting.ini"); 
/// time=ini.ReadIniContent("Time","time");
/// speed=ini.ReadIniContent("Speed","speed");
/// ini.WritePrivateProfileString("Count","count","5");
/// </summary>
public class ConfigIni
{

    public string path;
    public Dictionary<string, string> keyVal = new Dictionary<string, string>();

    //ini文件的路径  
    public ConfigIni(string path)
    {
        this.path = path;

        StreamReader sr = new StreamReader(path, Encoding.Default);
        string line;
        while ((line = sr.ReadLine()) != null)
        {
            if (line.Contains("="))
            {
                string[] kv = line.Split('=');
                string key = kv[0].Trim();
                string v = kv[1].Trim();
                keyVal.Add(key, v);
            }
        }
    }

    [DllImport("kernel32")]
    public static extern long WritePrivateProfileString(string section, string key, string value, string path);
    [DllImport("kernel32")]
    public static extern int GetPrivateProfileString(string section, string key, string deval, StringBuilder stringBuilder, int size, string path);
    [DllImport("User32.dll", SetLastError = true, ThrowOnUnmappableChar = true, CharSet = CharSet.Auto)]
    public static extern int MessageBox(IntPtr handle, String message, String title, int type);

    //写入ini文件
    public void WriteIniContent(string section, string key, string value)
    {
        WritePrivateProfileString(section, key, value, this.path);
    }

    //读取Ini文件
    public string ReadIniContent(string section, string key)
    {
        StringBuilder temp = new StringBuilder(255);
        int i = GetPrivateProfileString(section, key, "", temp, 255, this.path);
        //MessageBox(IntPtr.Zero, this.path+i + ","+temp+","+section+key, "ReadIniContent", 0);
        return temp.ToString();
    }
    //判断路径是否正确
    public bool IsIniPath()
    {
        return File.Exists(this.path);
    }
}
