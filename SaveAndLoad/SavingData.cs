using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;//2.Serializable: Need for binary input/output
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;

//-- show two ways for save/load data  1.PlayerPrefs 2.Serializable(including PlayerData.cs) --
public class SavingData : MonoBehaviour
{
    private string DATA_PATH = "/MyGame.dat";

    private PlayerData myPlayer;

    // Start is called before the first frame update
    void Start()
    {
        ////1. PlayerPrefs
        //PlayerPrefs.SetInt("score", 40);
        //int s = PlayerPrefs.GetInt("score", 0);

        //PlayerData p = new PlayerData();
        //p.Name = "Amy";

        print("DATA PATH IS:" + Application.persistentDataPath + DATA_PATH);

        //SaveData();

        LoadData();

        if (myPlayer != null)
        {
            print("Player Name " + myPlayer.Name);
            print("Player Power " + myPlayer.Power);
            print("Player Health " + myPlayer.Health);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void SaveData()//2.
    {
        FileStream file = null;

        try
        {
            BinaryFormatter bf = new BinaryFormatter();

            file = File.Create(Application.persistentDataPath + DATA_PATH);

            PlayerData p = new PlayerData("Warrior", 67, 100);

            //encrypt and save the data
            bf.Serialize(file, p);

        }
        catch (Exception e)
        {
            if (e != null)
            {
                //handle exception

            }
        }
        finally
        {
            if (file != null)
            {
                file.Close();//prevent memory leak
            }
        }

    }

    void LoadData()
    {
        FileStream file = null;

        try
        {
            BinaryFormatter bf = new BinaryFormatter();

            file = File.Open(Application.persistentDataPath + DATA_PATH, FileMode.Open);

            //decrypting and loading data
            myPlayer = bf.Deserialize(file) as PlayerData;
        }
        catch (Exception e)
        {
            if (e != null)
            {
                //handle exception

            }
        }
        finally
        {
            if (file != null)
            {
                file.Close();
            }
        }
    }
}
