//生成代码的信息 所有由ComponentTemplete模板生成的代码继承于此类
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace EditorExtension
{
    [ExecuteInEditMode]
    public class CodeGenerateInfo : MonoBehaviour
    {
        [HideInInspector]
        public string ScriptsFolder = "Assets/Scripts";
        [HideInInspector]
        public string PrefabsFolder = "Assets/Prefabs";
        [HideInInspector]
        public bool GeneratePrefab = false;

    }
}
