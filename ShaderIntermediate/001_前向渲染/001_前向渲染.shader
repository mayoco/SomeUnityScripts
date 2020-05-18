Shader "Unlit/001"
{
    Properties
    {
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
        _MainTex ("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		//ForwardBase
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			//ForwardBase 用于前向渲染。该pass会计算环境光，最重要的平行光，逐顶点/SH光源和Lightmaps

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
		// make fog work
		#pragma multi_compile_fog

		#include "UnityCG.cginc"
		#include "Lighting.cginc"

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
            float4 vertex : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float3 vertexLight : TEXCOORD2;
        };


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			#ifdef LIGHTMAP_OFF
			float3 shLight = ShadeSH9(float4(v.normal, 1));//球协函数
			o.vertexLight = shLight;
			#ifdef VERTEXLIGHT_ON//计算额外光源的顶点光照
			float3 vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb, unity_4LightAtten0, o.worldPos,o.worldNormal);
			o.vertexLight += vertexLight;
			#endif
			#endif


            return o;
        }

		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			fixed3 halfDir = normalize(worldLightDir + viewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

            return fixed4(ambient+diffuse+specular+i.vertexLight,1);
        }
        ENDCG
        }

		//ForwardAdd
		Pass
		{
			Tags{"LightMode"="ForwardAdd"}
			//用于前向渲染。该pass会计算额外的逐像素光源，每个pass对应一个光源。

			Blend One One

			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			//光照衰减需要使用
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float worldPos:TEXCOORD1;
				//阴影和衰减需要的宏 2，3 对应 TEXCOORD2 TEXCOORD3
				LIGHTING_COORDS(2,3)
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 normal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//UnityWorldSpaceLightDir可以计算不是平行光的情况
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(normal,worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); //== normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz)
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(viewDir,halfDir)),_Gloss);

				//衰减
				fixed atten = LIGHT_ATTENUATION(i);

				return fixed4((diffuse+specular)*atten,1.0);

			}


			ENDCG

		}
    }
}
