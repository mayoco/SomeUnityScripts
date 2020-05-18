//添加到物体上用于标记 生成代码的时候被标记的物体会被添加到代码的引用中
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace EditorExtension
{
    [AddComponentMenu("EditorExtension/Bind")]
    public class Bind : MonoBehaviour
    {
        public string ComponentName //指定绑定的物体所获取的组件类型
        {
            get
            {
                if (GetComponent<MeshRenderer>()) 
                {
                    return "MeshRenderer";
                }

                return "Transform";
            }
        }
    }
}
