Shader "Unlit/002"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert //定义 顶点着色器 片元着色器 的名称
			#pragma fragment frag
			
			//POSITION SV_POSITION 语义 表示它所指代的东西是什么 从哪里读数据 输出到哪里

			float4 vert(float4 v:POSITION) :SV_POSITION
			{
				//return mul(UNITY_MATRIX_MVP,v);//以前的方法
				return UnityObjectToClipPos(v);
			}

			fixed4 frag():SV_TARGET//输入到render target 中
			{
				return fixed4(1,1,1,1);
			}

			ENDCG
		}
	}
}
