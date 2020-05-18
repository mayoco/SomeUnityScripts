Shader "Unlit/001"
{
	Properties
	{	//基本类型 这里相当于定义变量  添加_与其他变量相区别
		_Int("Int",Int)=2
		_Float("Float",float) =1.5
		_Range("Range",Range(0.0,2.0))=1.0
		_Color("Color",Color)=(0,0,0,0)
		_Vector("Vector",Vector)=(1,4,3,8)//常用在矩阵或者多个变量传递
		_MainTex ("Texture", 2D) = "white" {}//2D图片类型
		_Cube("Cube",Cube)="white"{}//可直接在资源里面创建CubeMap Unity2017create的legacy下面
		_3D("3D",3D)="black"{}
	}
	SubShader//可以有多个 选择第一个能在目标平台运行的SubShader块 都不支持时走Fallback
	{
		//标签 可选 (key = value) 写在这里表示应用在所有pass通道，也可写在pass通道里
		Tags 
		{ 
			"Queue"="Transparent"//渲染顺序 ps Transparent 高
			"RenderType"="Opaque" //着色器替换功能
			"DisableBatching"="True"//关闭合批 比如做旗子飘动动画时
			"ForceNoShadowCasting"="True"//是否投射阴影
			"IgnoreProjector"="True"//受不受Projector影响 通常用于透明物体 Projector->Unity中用于绘制阴影
			"CanUseSpriteAltas"="False"//是否用于图片 通常用于UI
			"PreviewType"="Plane"//用作shader面板预览的类型 默认是个球
		}

		//渲染设置 Render设置 可选
		//Cull off//Cull off 裁剪关闭/back裁掉背面/front裁掉前面
		//ZTest Always//Always/Less Greater/LEqual默认小于等于/Equal/NotEqual 深度测试
		//Zwrite off//深度写入
		//Blend SrcFactor DstFactor//混合
		//LOD 100//不同情况下使用不同的LOD，达到性能提升

		//必须
		Pass//可以有多个 按顺序渲染 多一个pass多一个drawcall 尽量不要多个
		{
			//Name "Default"  //Pass通道名称 便于在其他shader中重复使用->使用时必须全大写

			//Tags{} 可以在每个Pass通道里面进行定义 若同一个值外面也定义了，以外面的为准
			Tags//除了上面介绍的，还有以下的:
			{
				"LightMode"="ForwardBase"//该Pass通道在Unity渲染流水中的角色
				"RequireOptions"="SoftVegetation"//满足某些条件时才渲染该Pass通道 可以有多个value 用空格分隔
			}
			//渲染设置 也可以在每个Pass通道里面进行定义

			//CG语言所写的代码 主要是顶点片元着色器
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}

	//Fallback "Legacy Shaders/Transparent/VertexLit"  Fallback Off //都不支持时走Fallback
}
