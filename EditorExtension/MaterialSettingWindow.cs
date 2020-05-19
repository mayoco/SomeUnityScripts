//菜单上出现 编辑器扩展/MaterialSetting 可以设置预设的材质和Shader 在Hierarchy面板上选中物体右键设置其所有子物体为指定材质,Shader
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

public class MaterialSettingWindow : EditorWindow
{
    static Material mat=null;
    static string shadername = "Standard";

    [MenuItem("编辑器扩展/MaterialSetting")]
    static void SettingWindow()
    {
        var window = GetWindow<MaterialSettingWindow>();

        window.position = new Rect(300, 150, 300, 200);//设置窗口宽高

        window.Show();
    }

    private void OnGUI()//渲染IMGUI
    {
        GUILayout.BeginVertical();
        //GUILayout.Label("material", GUILayout.Width(35));
        mat = EditorGUILayout.ObjectField("materialToSet", mat, typeof(Material), true) as Material;
        shadername = EditorGUILayout.TextField("shaderToSet", shadername);

        GUILayout.EndVertical();
    }

    [MenuItem("GameObject/SetMaterial", false, 0)]//设置为指定材质
    static void SetMat()
    {
        var SelectedObj = Selection.objects.First() as GameObject;
        if (SelectedObj == null) { Debug.LogWarning("需要选择gameobject!"); return; }

        MeshRenderer[] meshRenderers = SelectedObj.GetComponentsInChildren<MeshRenderer>();

        foreach(MeshRenderer renderer in meshRenderers)
        {
            //Debug.Log(renderer.gameObject.name + " renderer found! ");

            Material[] mats = new Material[renderer.sharedMaterials.Length];

            for (var i =0;i< mats.Length; i++)
            {
                mats[i] = mat;
            }

            renderer.sharedMaterials = mats;
        }

    }

    [MenuItem("GameObject/SetShader", false, 0)]//设定为指定Shader
    static void SetShader()
    {
        var SelectedObj = Selection.objects.First() as GameObject;
        if (SelectedObj == null) { Debug.LogWarning("需要选择gameobject!"); return; }

        MeshRenderer[] meshRenderers = SelectedObj.GetComponentsInChildren<MeshRenderer>();

        foreach (MeshRenderer renderer in meshRenderers)
        {
            var mats = new List<Material>();

            renderer.GetSharedMaterials(mats);

            for (var i = 0; i < mats.Count; i++)
            {
                mats[i].shader= Shader.Find(shadername);
            }
            renderer.sharedMaterials = mats.ToArray();
        }

    }
}
