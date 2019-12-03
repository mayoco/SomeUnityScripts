using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class UnityEventExample : MonoBehaviour
{
    UnityEvent m_MyEvent;//can invoke outside this scope

    void Start()
    {
        if (m_MyEvent == null)
            m_MyEvent = new UnityEvent();

        m_MyEvent.AddListener(Ping);
    }

    void Update()
    {
        if (Input.anyKeyDown && m_MyEvent != null)
        {
            m_MyEvent.Invoke();
        }
    }

    void Ping()
    {
        Debug.Log("Ping");
    }
}
