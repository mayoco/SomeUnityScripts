Shader "Unlit/002Pass1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,50)) = 20
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		//延迟渲染

		//第一个Pass用于渲染G缓冲。在这个Pass中，我们会把物体的漫反射颜色、高光发射颜色、平滑度、法线、自发光和深度等信息渲染到屏幕空间的G缓冲区中。
		//对于每个物体来说，这个Pass仅会执行一次。
		pass
		{
			Tags{"LightMode" = "Deferred"}

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			//排除不支持MRT的硬件
			#pragma exclude_renderers norm
			#pragma multi_compile __ UNITY_HDR_ON


			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			struct DeferredOutput
			{
				float4 gBuffer0 : SV_TARGET0;
				float4 gBuffer1 : SV_TARGET1;
				float4 gBuffer2 : SV_TARGET2;
				float4 gBuffer3 : SV_TARGET3;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}

			DeferredOutput frag(v2f i)
			{
				DeferredOutput o;
				fixed3 color = tex2D(_MainTex,i.uv).rgb * _Diffuse.rgb;
				o.gBuffer0.rbg = color;
				o.gBuffer0.a = 1;//遮罩纹理 目前没有 设为1
				o.gBuffer1.rgb = _Specular.rbg;
				o.gBuffer1.a = _Gloss/50.0;//高光系数Range(8.0,50) 这里只能存(0,1) 进行归一化
				o.gBuffer2 = float4(i.worldNormal*0.5 + 0.5,1);//法线 范围在(-1,1) 这里只能存(0,1) 进行归一化
				#if !defined(UNITY_HDR_ON)
					color.rgb = exp2(-color.rgb);
				#endif
				o.gBuffer3 = fixed4(color,1);
				return o;
			}

			ENDCG
		}
		
		//第二个Pass用于计算真正的光照模型。->后处理
		//默认情况下使用Unity内置的Standard 光照模型。(Project Settings>Graphics>Build-in Shader Settings 自定义设置)

    }
}
