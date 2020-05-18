using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubeMap : ScriptableWizard
{//创建Cubemap的编辑器代码
    public Transform renderPos;
    public Cubemap cubemap;

    [MenuItem("Tools/CreateCubemap")]
    static void CreateCubemap() 
    {
        ScriptableWizard.DisplayWizard<RenderCubeMap>("Render Cube", "Create"); //"Render Cube" "Create" 抬头 和 按钮
    }
    private void OnWizardUpdate()
    {
        helpString = "选择渲染位置并且确定需要设置的Cubemap";
        isValid = (renderPos != null) && (cubemap != null);
    }

    private void OnWizardCreate()//运行生成时 cubemap 需要设为 Readable, 平时使用该Cubemap时建议取消Readable勾选,不然会占用较大显存
    {
        GameObject go = new GameObject("CubemapCam");
        Camera camera = go.AddComponent<Camera>();
        go.transform.position = renderPos.position;
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }
}
