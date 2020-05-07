using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using ZXing;
using ZXing.QrCode;

public class TestWWWForm : MonoBehaviour
{//take screenshot as image and upload to a web server,then generate a QrCode which can jump to the URL of the screenshot
//attach this to any gameobject in scenes, then add the reference ui image for where you want the QrCode to show
    public RawImage image;
    public Texture defaultImage=null;
    public Texture transparentTex;
    string screenShotURL = "https://www.server.com/photos/upload.php?folderName=ccycy&photo_type=jpg";//upload to server
    string result;
    GameObject instructionText;

    Texture2D encoded;

    //void Awake()
    //{
    //    image = GameObject.Find("RawImage").transform.GetComponent<RawImage>();
    //    encoded = new Texture2D(256, 256);
    //}
    void Start()
    {
        //StartCoroutine(UploadPNG());
        instructionText = image.gameObject.transform.GetChild(0).gameObject;
    }

    // Update is called once per frame
    void Update()
    {

    }



    public void GenerateQR()
    {
        instructionText.SetActive(false);
        image.texture = transparentTex;
        encoded = new Texture2D(256, 256);
        StartCoroutine(UploadPNG());
    }

    public void SetImageToDefault() 
    {
        image.texture = defaultImage;
    }

    IEnumerator UploadPNG()
    {
        // We should only read the screen after all rendering is complete
        yield return new WaitForEndOfFrame();

        // Create a texture the size of the screen, RGB24 format
        int width = Screen.width;
        int height = Screen.height;
        //var tex = new Texture2D(width, height, TextureFormat.RGB24, false);
        var tex = new Texture2D(608, 1080, TextureFormat.RGB24, false);

        // Read screen contents into the texture
        //tex.ReadPixels(new Rect(0, 0, width, height), 0, 0);//screen shot for full screen
        tex.ReadPixels(new Rect(652, 0, 608f, 1080f), 0, 0);//Screen Zoom: (PosX,PosY,Width,Height)
        tex.Apply();

        // Encode texture into PNG
        byte[] bytes = tex.EncodeToPNG();
        Destroy(tex);

        // Create a Web Form
        WWWForm form = new WWWForm();
        form.AddField("user", "shengyilai");
        form.AddField("password", "fyz123456");
        form.AddField("photoNameqsy24"+Time.time.ToString(), "currentScore1");
        form.AddBinaryData("photoData", bytes);

        // Upload to a cgi script
        using (var w = UnityWebRequest.Post(screenShotURL, form))
        {
            yield return w.SendWebRequest();

            if (w.isNetworkError || w.isHttpError)
            {
                print(w.error);
            }
            else
            {
                print("Finished Uploading Screenshot");
                print(w.downloadHandler.text);
                string s = w.downloadHandler.text.Split(',')[1].Split('"')[3];

                print("***" + s);
                yield return new WaitForSeconds(0.5f);
                Btn_CreatQr(s);
            }
        }

    }

    private IEnumerator downLoad(string s)
    {
        WWW www = new WWW(s);
        yield return www;
        if (www.isDone && www.error == null)
        {
            print(www);
            Texture2D tt = www.texture;
            image.texture = tt;
        }
        else
        {
            print(www.error);
        }
        image.texture = www.texture;
    }


    /// <summary>
    /// 定义方法生成二维码 
    /// </summary>
    /// <param name="textForEncoding">需要生产二维码的字符串</param>
    /// <param name="width">宽</param>
    /// <param name="height">高</param>
    /// <returns></returns>       
    private static Color32[] Encode(string textForEncoding, int width, int height)
    {
        var writer = new BarcodeWriter
        {
            Format = BarcodeFormat.QR_CODE,
            Options = new QrCodeEncodingOptions
            {
                Height = height,
                Width = width
            }
        };
        return writer.Write(textForEncoding);
    }


    /// <summary>  
    /// 生成二维码  
    /// </summary>  
    public void Btn_CreatQr(string s)
    {


        //二维码写入图片    
        var color32 = Encode(s, encoded.width, encoded.height);
        encoded.SetPixels32(color32);
        encoded.Apply();
        //生成的二维码图片附给RawImage    
        image.texture = encoded;
        //二维码生成完成
        instructionText.SetActive(true);
    }
}
