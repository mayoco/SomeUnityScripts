//设定CodeGenerateInfo的Inspector面板 自定义面板样式等
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


namespace EditorExtension
{
    [CustomEditor(typeof(CodeGenerateInfo),editorForChildClasses:true,isFallback =false)]
    public class CodeGenerateInfoInspector : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            CodeGenerateInfo codeGenerateInfo = target as CodeGenerateInfo;

            GUILayout.BeginVertical("box");

            GUILayout.Label("Code Generate Setting", new GUIStyle
            {
                fontStyle = FontStyle.Bold,
            });

            GUILayout.BeginHorizontal();
            GUILayout.Label("Scripts Generate Folder:",GUILayout.Width(150));
            codeGenerateInfo.ScriptsFolder = GUILayout.TextField(codeGenerateInfo.ScriptsFolder);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            codeGenerateInfo.GeneratePrefab = GUILayout.Toggle(codeGenerateInfo.GeneratePrefab, "Generate Prefab");
            GUILayout.EndHorizontal();

            if (codeGenerateInfo.GeneratePrefab) 
            {
                GUILayout.BeginHorizontal();
                GUILayout.Label("Prefabs Generate Folder:", GUILayout.Width(150));
                codeGenerateInfo.PrefabsFolder = GUILayout.TextField(codeGenerateInfo.PrefabsFolder);
                GUILayout.EndHorizontal();
            }

            GUILayout.EndVertical();
        }
    }
}
