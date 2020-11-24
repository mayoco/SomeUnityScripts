using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Text;
using UnityEngine.UI;

public class ReadWriteToFile : MonoBehaviour
{//读写txt到hololens文件系统中 具体路径为 User Folders \ LocalAppData \ 相应app文件夹 \ LocalState \
    //通过windows device portal 可以删除并上传新的txt文件,达到类似修改配置文件的效果
    public Text debugText;
    public TcpClient tcpClient;//tcp客户端脚本
    // Start is called before the first frame update
    void Start()
    {
        string path = Application.persistentDataPath+ @"\MyTest.txt";

        // This text is added only once to the file.
        if (!File.Exists(path))
        {
            // Create a file to write to.
            string createText = "192.168.137.243" + Environment.NewLine;
            File.WriteAllText(path, createText, Encoding.UTF8);
        }

        // This text is always added, making the file longer over time
        // if it is not deleted.
        //string appendText = "This is extra text" + Environment.NewLine;
        //File.AppendAllText(path, appendText, Encoding.UTF8);

        // Open the file to read from.
        string readText = File.ReadAllText(path);
        if (debugText) debugText.text = readText;
        if (tcpClient) tcpClient.ip = readText.Substring(0,15);//从文件中读取ip地址进行设置
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
