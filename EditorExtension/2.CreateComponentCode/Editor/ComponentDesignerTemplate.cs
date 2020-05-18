//生成代码的模板 ComponentDesignerTemplete部分每次生成代码时都会写入 ComponentTemplete部分只在第一次生成时写入 以便在上面写功能不被覆盖
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;
using System;

namespace EditorExtension
{
    public class ComponentDesignerTemplete
    {//每次CreateComponentCode的时候都会写入
        public static void Write(string name, string scriptsFolder, List<BindInfo> bindInfos)
        {
            var scriptFile = scriptsFolder + $"/{name}.Designer.cs";//在字符串前加$相当于对string.format()的简化
            var writer = File.CreateText(scriptFile);

            writer.WriteLine($"//Generate Id:{Guid.NewGuid().ToString()}");//强制触发编译功能
            writer.WriteLine("using UnityEngine;");
            writer.WriteLine();
            if (NamespaceSettingData.IsDefualtNNamespace)
            {
                writer.WriteLine("//1.请在菜单 编辑器扩展/Namespace Settings 里设置命名空间");
                writer.WriteLine("//2.命名空间更改后，生成代码之后，需要把逻辑代码文件(非 Designer)的命名空间手动更改");
            }
            writer.WriteLine($"namespace {NamespaceSettingData.Namespace}");
            writer.WriteLine("{");
            writer.WriteLine($"\tpublic partial class {name}");//\t缩进
            writer.WriteLine("\t{");

            foreach (var bindInfo in bindInfos)
            {
                writer.WriteLine($"\t\tpublic {bindInfo.ComponentName} {bindInfo.Name};");
            }

            writer.WriteLine();
            writer.WriteLine("\t}");
            writer.WriteLine("}");

            writer.Close();
        }
    }

    public class ComponentTemplete
    {//只在第一次CreateComponentCode生成的时候写入 防止修改被覆盖
        public static void Write(string name, string scriptsFolder)
        {
            var scriptFile = scriptsFolder + $"/{name}.cs";//在字符串前加$相当于对string.format()的简化

            if (File.Exists(scriptFile)) return;

            var writer = File.CreateText(scriptFile);

            writer.WriteLine("using UnityEngine;");
            writer.WriteLine("using EditorExtension;");
            writer.WriteLine();
            if (NamespaceSettingData.IsDefualtNNamespace)
            {
                writer.WriteLine("//1.请在菜单 编辑器扩展/Namespace Settings 里设置命名空间");
                writer.WriteLine("//2.命名空间更改后，生成代码之后，需要把逻辑代码文件(非 Designer)的命名空间手动更改");
            }
            writer.WriteLine($"namespace {NamespaceSettingData.Namespace}");
            writer.WriteLine("{");
            writer.WriteLine($"\tpublic partial class {name} : CodeGenerateInfo");
            writer.WriteLine("\t{");
            writer.WriteLine("\t\t void Start()");
            writer.WriteLine("\t\t {");
            writer.WriteLine("\t\t // Code Here");
            writer.WriteLine("\t\t }");
            writer.WriteLine();
            writer.WriteLine("\t}");
            writer.WriteLine("}");

            writer.Close();
        }
    }


}
