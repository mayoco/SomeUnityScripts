Shader "Unlit/004"
{//调试方法 1.直接输出颜色 2.Window -> Frame Debugger 逐步骤渲染
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color)=(1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma target 5.0 //Shader Target  Shader Mode

			#include "UnityCG.cginc"//使用基本库

			//只有在CGPROGRAM内再次定义一个与属性块内名字与类型相同的变量 属性块对应的变量才能起作用
			fixed4 _Color;

			struct a2v// a:application ; 2:to ; v:vert  //类似UnityCG 中定义的 appdata_base
			{
				//用模型顶点填充v变量
				float4 vertex:POSITION;  //unity准备好的输入 可以直接使用 //SV_POSITION 包含POSITION的情况 兼容性更好
				//用模型法线填充n变量
				float3 normal:NORMAL;
				//用模型的第一套uv填充texcoord变量
				float4 texcoord:TEXCOORD0;
			};

			struct v2f//vert to frag
			{
				//SV_POSITION 语义告诉unity: pos为裁剪空间中的位置信息 
				float4 pos:SV_POSITION;//必要
				//COLOR0语义可以储存颜色信息
				fixed3 color:COLOR0;
			};


			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线 直接输出颜色来Debug 红1,0,0 绿 0,1,0 蓝 0,0,1  
				o.color=v.normal*0.5+fixed3(0.5,0.5,0.5);//将范围 [-1,1] -> [0,1]   x/2+0.5
				//切线
				o.color=v.tangent.xyz*0.5+fixed3(0.5,0.5,0.5);
				//UV
				o.color=fixed4(v.texcoord.xy,0,1);
				//顶点颜色
				o.color =v.color;
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET//SV_TARGET相当于DX9中的COLOR SV_TARGET的兼容性更好
			{
				return fixed4(i.color,1);
			}
			ENDCG
		}
	}
}
