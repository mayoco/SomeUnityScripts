//编辑器扩展案例3.一键重启项目 需要登陆账号使用
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace EditorExtension
{
    public class ReopenProject
    {
        [MenuItem("编辑器扩展/3.ReopenProject &r")]
        public static void DoReopenProject() 
        {
            EditorApplication.OpenProject(Application.dataPath.Replace("Assets",string.Empty));
        }

    }
}
