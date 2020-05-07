using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackGroundVideo : MonoBehaviour
{//设置长时间不操作后自动显示待机视频
    public float waitTime = 30f;
    public GameObject BackGroundVideoUI;
    private float curWaitTime = 0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        curWaitTime += Time.deltaTime;
        if (Input.GetMouseButtonDown(0)) 
        {
            //BackGroundVideoUI.SetActive(false);//点击屏幕后隐藏待机视频
            curWaitTime = 0;
        }
        if (curWaitTime + Time.deltaTime > waitTime && curWaitTime<waitTime) 
        {
            BackGroundVideoUI.SetActive(true);
        }
    }

    public void SetWaitTime(float newTime) 
    {
        waitTime = newTime;
    }
}
