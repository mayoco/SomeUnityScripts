//编辑器扩展案例2.代码生成器 (与之相关代码还有 CodeGenerateInfo, Bind, BindInfo, ComponentDesignerTemplete, CodeGenerateInfoInspector)
/*
--如何使用？-- (各步骤均设置了快捷键)
1.在主物体上添加CodeGenerateInfo 并设置路径等信息 ，菜单上编辑器扩展下可以设置命名空间
2.在想要关联的子物体上添加Bind 
3.在主物体上右键生成代码 
之后会按照模板生成代码与预制体存放与指定路径

--详细需求--
@1.在 Hierarchy 上生成菜单	
@2.生成脚本
@3.添加标记
@4.搜索并生成脚本
@改进
    @分两个脚本	
    @命名空间
    @命名空间设置的一个面板
    @生成的路径选择，和存储
    @创建 Prefab
    @自动触发编译
    @快捷键支持
    @类型支持
    @自定义面板
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.Callbacks;
using System;
using System.Linq;

namespace EditorExtension
{
    public class CreateComponentCode : EditorWindow
    {
        [MenuItem("编辑器扩展/2.NamespaceSetting")]
        static void Open()
        {
            var window = GetWindow<CreateComponentCode>();
            window.Show();
        }

        private void OnGUI()
        {
            GUILayout.BeginHorizontal();//开始横向布局
            GUILayout.Label("Namespace");
            NamespaceSettingData.Namespace = GUILayout.TextField(NamespaceSettingData.Namespace);
            GUILayout.EndHorizontal();
        }

        private static List<BindInfo> bindInfoList = new List<BindInfo>();

        [MenuItem("GameObject/@EditorExtension-Bind [Alt+T] &t", false, 0)]//&t Alt+T快捷键
        static void Bind()//附在想要用于生成脚本中其他引用的物体上
        {
            var SelectedObj = Selection.objects.First() as GameObject;
            if (SelectedObj == null) { Debug.LogWarning("需要选择gameobject!"); return; }

            if (SelectedObj.GetComponent<Bind>() == null) SelectedObj.AddComponent<Bind>();
        }

        [MenuItem("GameObject/@EditorExtension-Add CodeGenerateInfo [Alt+G] &g", false, 0)]//&g Alt+G快捷键
        static void AddCodeGenerateInfo() //附在想要生成脚本的主物体上
        {
            var SelectedObj = Selection.objects.First() as GameObject;
            if (SelectedObj == null) { Debug.LogWarning("需要选择gameobject!"); return; }

            if (SelectedObj.GetComponent<CodeGenerateInfo>() != null) return;
            SelectedObj.AddComponent<CodeGenerateInfo>();
        }


        [MenuItem("GameObject/@EditorExtension-CreateCode[Alt+C] &c", false, 0)]//0-菜单上的最高优先级 //&c Alt+C快捷键
        static void CreateCode()
        {
            var SelectedObj = Selection.objects.First() as GameObject;
            if (SelectedObj == null) { Debug.LogWarning("需要选择gameobject!"); return; }

            //生成脚本
            //设置生成路径
            var scriptsFolder = Application.dataPath + "/Scripts";
            var generateInfo = SelectedObj.GetComponent<CodeGenerateInfo>();
            if (generateInfo)
            {
                scriptsFolder = generateInfo.ScriptsFolder;
            }

            if (!Directory.Exists(scriptsFolder))
            {
                Directory.CreateDirectory(scriptsFolder);
            }

            //查找其下Bind的子物体 以便写入将要生成的代码里面
            bindInfoList.Clear();
            SearchBinds("", SelectedObj.transform, bindInfoList);

            ComponentTemplete.Write(SelectedObj.name, scriptsFolder);
            ComponentDesignerTemplete.Write(SelectedObj.name, scriptsFolder, bindInfoList);

            EditorPrefs.SetString("GENERATE_CLASS_NAME", SelectedObj.name);

            AssetDatabase.Refresh();//刷新Asset目录

            //触发编译 调用 AddComponent2GameObject

        }

        static void SearchBinds(string basePath, Transform transform, List<BindInfo> bindInfos)
        {//遍历其下所有子物体 存储所有有Bind组件的子物体的路径
            var bind = transform.GetComponent<Bind>();
            var isRoot = string.IsNullOrWhiteSpace(basePath);
            if (bind && !isRoot)
            {
                bindInfos.Add(new BindInfo()
                {
                    FindPath = basePath,
                    Name = transform.name,
                    ComponentName = bind.ComponentName
                });
            }

            foreach (Transform childTrans in transform)
            {
                basePath = isRoot ? basePath : basePath + "/";//顶端时往下找的路径前面不需要加'/'
                SearchBinds(basePath + childTrans.name, childTrans, bindInfos);
            }
        }


        [DidReloadScripts]//namespace UnityEditor.Callbacks 系统的事件 编辑完成之后就会调用
        static void AddComponent2GameObject() //处理将代码挂在到gameobject上
        {
            //Debug.Log("DidReloadScripts");
            string generateClassName = EditorPrefs.GetString("GENERATE_CLASS_NAME");
            //Debug.Log(generateClassName);

            if (string.IsNullOrWhiteSpace(generateClassName))
            {
                Debug.Log("不继续操作");
                EditorPrefs.DeleteKey("GENERATE_CLASS_NAME");//使用后删除，防止其他情况有值时触发后面的代码
            }
            else
            {
                Debug.Log("继续操作");
                //获取生成代码的类型信息 挂载到物体上
                var assembliescs = AppDomain.CurrentDomain.GetAssemblies();
                var defaultAssembly = assembliescs.First(assemblies => assemblies.GetName().Name == "Assembly-CSharp");
                //Debug.Log(defaultAssembly);

                var typeName = NamespaceSettingData.Namespace + "." + generateClassName;

                var type = defaultAssembly.GetType(typeName);

                if (type == null) { Debug.Log("编译失败"); return; }

                var selectedObj = GameObject.Find(generateClassName);

                var scriptComponent = selectedObj.GetComponent(type);
                if (!scriptComponent) scriptComponent = selectedObj.AddComponent(type);//防止反复添加
                Debug.Log("尝试取得序列化");
                //Debug.Log(scriptComponent.ToString());
                //取得序列化
                var serializedScript = new SerializedObject(scriptComponent);

                //----------------

                //查找其下Bind的子物体 通过序列化给生成的脚本赋值
                bindInfoList.Clear();
                SearchBinds("", selectedObj.transform, bindInfoList);

                foreach (var bindInfo in bindInfoList)
                {
                    //Debug.Log(bindInfo.Path);
                    var name = bindInfo.Name;
                    serializedScript.FindProperty(name).objectReferenceValue = selectedObj.transform.Find(bindInfo.FindPath).GetComponent(bindInfo.ComponentName);
                }

                //取得设置信息 生成预制体
                var codeGenerateInfo = selectedObj.GetComponent<CodeGenerateInfo>();

                if (codeGenerateInfo)
                {
                    serializedScript.FindProperty("ScriptsFolder").stringValue = codeGenerateInfo.ScriptsFolder;
                    serializedScript.FindProperty("PrefabsFolder").stringValue = codeGenerateInfo.PrefabsFolder;
                    serializedScript.FindProperty("GeneratePrefab").boolValue = codeGenerateInfo.GeneratePrefab;

                    bool generatePrefab = codeGenerateInfo.GeneratePrefab;
                    string prefabFolder = codeGenerateInfo.PrefabsFolder;
                    string fullPrefabFoloder = prefabFolder.Replace("Assets", Application.dataPath);

                    if (codeGenerateInfo.GetType() == type)
                    {

                    }
                    else
                    {
                        DestroyImmediate(codeGenerateInfo, false);
                    }

                    serializedScript.ApplyModifiedPropertiesWithoutUndo();
                    if (generatePrefab)
                    {
                        if (!Directory.Exists(fullPrefabFoloder)) Directory.CreateDirectory(fullPrefabFoloder);

                        PrefabUtility.SaveAsPrefabAssetAndConnect(selectedObj, fullPrefabFoloder + $"/{selectedObj.name}.prefab", InteractionMode.AutomatedAction);
                    }
                }
                else
                {
                    serializedScript.FindProperty("ScriptsFolder").stringValue = "Assets/Scripts";
                    serializedScript.ApplyModifiedPropertiesWithoutUndo();

                }


                EditorPrefs.DeleteKey("GENERATE_CLASS_NAME");

            }

        }


    }
}
