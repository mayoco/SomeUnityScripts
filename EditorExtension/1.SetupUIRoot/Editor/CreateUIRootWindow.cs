//编辑器扩展案例1.菜单上增加一栏，点击后出现设置窗口,设置完成生成一个UIRoot(有相应的层级结构和组件,且相应代码UIRoot.cs已经赋值),并且生成相应的预制体

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System.IO;

namespace EditorExtension
{
    public class CreateUIRootWindow : EditorWindow//窗口
    {
        [MenuItem("编辑器扩展/1.SetupUIRoot", true)]//true->标记为"编辑器扩展/1.SetupUIRoot" 的 ValidateFuction,返回值为true的时候有效
        static bool ValidateUIRoot()
        {
            return GameObject.Find("UIRoot") == null; //不存在的时候才有效
        }

        [MenuItem("编辑器扩展/1.SetupUIRoot &u")]//菜单栏 &u 添加快捷键 Alt+U %u Ctrl+U
        static void SetupUIRoot()
        {
            var window = GetWindow<CreateUIRootWindow>();

            window.position = new Rect(300, 150, 300, 200);//设置窗口宽高

            window.Show();

        }
        string mWidth = "1920";
        string mHeight = "1080";
        private void OnGUI()//渲染IMGUI
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("width", GUILayout.Width(35));
            mWidth = GUILayout.TextField(mWidth);//输入值保存到mWidth
            GUILayout.Label("x", GUILayout.Width(10));
            GUILayout.Label("height", GUILayout.Width(40));
            mHeight = GUILayout.TextField(mHeight);
            GUILayout.EndHorizontal();
            if (GUILayout.Button("Setup"))
            {
                var width = float.Parse(mWidth);
                var height = float.Parse(mHeight);
                Setup(width, height);
                GetWindow<CreateUIRootWindow>().Close();
            }
        }

        static void Setup(float width, float height)
        {
            //UIRoot
            var uiRootObj = new GameObject("UIRoot");

            uiRootObj.layer = LayerMask.NameToLayer("UI");

            var uiRootScript = uiRootObj.AddComponent<UIRoot>();

            //Canvas (UIRoot下)
            var canvas = new GameObject("Canvas");

            canvas.layer = LayerMask.NameToLayer("UI");

            canvas.transform.SetParent(uiRootObj.transform);

            canvas.AddComponent<Canvas>().renderMode = RenderMode.ScreenSpaceOverlay;
            var canvasScaler = canvas.AddComponent<CanvasScaler>();
            canvasScaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            canvasScaler.referenceResolution = new Vector2(width, height);

            canvas.AddComponent<GraphicRaycaster>();

            //EventSystem (UIRoot下)
            var eventSystem = new GameObject("EventSystem");

            eventSystem.layer = LayerMask.NameToLayer("UI");

            eventSystem.transform.SetParent(uiRootObj.transform);

            eventSystem.AddComponent<EventSystem>();
            eventSystem.AddComponent<StandaloneInputModule>();

            //在Canvas下创建 Bg Common PopUI Forward
            var bgObj = new GameObject("Bg");
            bgObj.AddComponent<RectTransform>();
            bgObj.transform.SetParent(canvas.transform);
            bgObj.transform.localPosition = Vector3.zero;
            uiRootScript.Bg = bgObj.transform;

            var commonObj = new GameObject("Common");
            commonObj.AddComponent<RectTransform>();
            commonObj.transform.SetParent(canvas.transform);
            commonObj.transform.localPosition = Vector3.zero;
            uiRootScript.Common = commonObj.transform;

            var popUpObj = new GameObject("PopUp");
            popUpObj.AddComponent<RectTransform>();
            popUpObj.transform.SetParent(canvas.transform);
            popUpObj.transform.localPosition = Vector3.zero;
            uiRootScript.PopUp = popUpObj.transform;

            var forwardObj = new GameObject("Forward");
            forwardObj.AddComponent<RectTransform>();
            forwardObj.transform.SetParent(canvas.transform);
            forwardObj.transform.localPosition = Vector3.zero;
            uiRootScript.Forward = forwardObj.transform;

            //通过序列化给代码的私有属性赋值
            var uiRootScriptSerializedObj = new SerializedObject(uiRootScript);
            uiRootScriptSerializedObj.FindProperty("RootCanvas").objectReferenceValue = canvas.GetComponent<Canvas>();
            uiRootScriptSerializedObj.ApplyModifiedPropertiesWithoutUndo();

            //生成预制体Prefab
            var savedFolder = Application.dataPath + "/Resources";
            if (!Directory.Exists(savedFolder))
            {
                Directory.CreateDirectory(savedFolder);
            }
            var savedFilePath = savedFolder + "/UIRoot.prefab";
            PrefabUtility.SaveAsPrefabAssetAndConnect(uiRootObj, savedFilePath, InteractionMode.AutomatedAction);

        }

    }
}
