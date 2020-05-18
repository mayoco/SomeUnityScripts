using UnityEditor;
using UnityEngine;

namespace EditorExtension
{
    class NamespaceSettingData
    {
        readonly static string NAMESPACE_KEY = Application.productName + "@NAMESPACE";

        //=> 这是C#6的一个新特性，称为表达式体成员，它允许您使用lambda类函数定义getter仅属性。说明 http://www.imooc.com/wenda/detail/566851
        public static string Namespace
        {
            get
            {
                var retNamespace = EditorPrefs.GetString(NAMESPACE_KEY, "DefaultNamespace");
                return string.IsNullOrWhiteSpace(retNamespace) ? "DefaultNamespace" : retNamespace;
            }
            set => EditorPrefs.SetString(NAMESPACE_KEY, value); 
        }

        public static bool IsDefualtNNamespace => Namespace == "DefaultNamespace";

    }
}
