using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]//enable binary input/output to encrypt data
public class PlayerData
{
    private string _name;
    private int _power;
    private float _health;

    public PlayerData() { }

    public PlayerData(string name,int power,float health)
    {
        _name = name;
        _power = power;
        _health = health;
    }

    public string Name
    {
        get { return _name; }
        set { _name = value; }
    }

    public int Power
    {
        get { return _power; }
        set { _power = value; }
    }

    public float Health
    {
        get { return _health; }
        set { _health = value; }
    }

}
