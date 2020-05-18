Shader "Unlit/004_Shadow_02_AlphaTest"
{
    Properties
    {
		_MainTex("MainTex",2D) = "white" {}
		_Color("Diffuse Color",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
		_Cutoff("Alpha CutOff",Range(0,1)) = 0.5
	}
		SubShader
	{
		Tags { "RenderType" = "TransparentCutOut" "Queue" = "AlphaTest" "IgnoreProjector"="True"}
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
		#include "AutoLight.cginc"

		fixed4 _Color;
		fixed4 _Specular;
		float _Gloss;
		fixed _Cutoff;
		sampler2D _MainTex;
		float4 _MainTex_ST;


        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
			float3 normal : NORMAL;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float3 vertexLight : TEXCOORD2;
			//阴影相关 下面的(3)等同于TEXCOORD3
			SHADOW_COORDS(3)
			float2 uv : TEXCOORD4;
        };


        v2f vert (appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.uv = TRANSFORM_TEX(v.uv,_MainTex);

			//#ifdef LIGHTMAP_OFF
			//float3 shLight = ShadeSH9(float4(v.normal, 1));//球协函数
			//o.vertexLight = shLight;
			////计算额外光源的顶点光照
			//#ifdef VERTEXLIGHT_ON
			//float3 vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			//	unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb, unity_4LightAtten0, o.worldPos,o.worldNormal);
			//o.vertexLight += vertexLight;
			//#endif
			//#endif

			//获得阴影相关信息
			TRANSFER_SHADOW(o);

            return o;
        }

		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed4 texColor = tex2D(_MainTex,i.uv);

			clip(texColor.a -_Cutoff);

			fixed3 diffuse = texColor*_LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			fixed3 halfDir = normalize(worldLightDir + viewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

			//计算接收阴影
			//fixed shadow = SHADOW_ATTENUATION(i);
			//包含光照衰减以及阴影 atten在宏里面进行了赋值不需要提前定义
			//这个函数计算包含了光照衰减已经阴影,因为ForwardBase逐像素光源一般是方向光，衰减为1，atten在这里实际是阴影值
			UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

            return fixed4(ambient+i.vertexLight+(diffuse+specular)*atten,1);
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
			#pragma multi_compile_fwdadd_fullshadows
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			//光照衰减需要使用
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				//阴影和衰减需要的宏 2，3 对应 TEXCOORD2 TEXCOORD3
				LIGHTING_COORDS(2,3)
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);//包含光照 阴影
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));//UnityWorldSpaceLightDir可以计算不是平行光的情况
				
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); //== normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz)
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(viewDir,halfDir)),_Gloss);

				//衰减
				//fixed atten = LIGHT_ATTENUATION(i);

				//包含光照衰减以及阴影 atten在宏里面进行了赋值不需要提前定义
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4((diffuse+specular)*atten,1.0);

			}
			ENDCG

		}

		//阴影
		Pass {
        Name "Caster"
        Tags { "LightMode" = "ShadowCaster" }

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#pragma multi_compile_shadowcaster
		// allow instanced shadow pass for most of the shaders
		#pragma multi_compile_instancing 
		#include "UnityCG.cginc"

		struct v2f {
			V2F_SHADOW_CASTER;
			float2  uv : TEXCOORD1;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		uniform float4 _MainTex_ST;

		v2f vert( appdata_base v )
		{
			v2f o;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		uniform sampler2D _MainTex;
		uniform fixed _Cutoff;
		uniform fixed4 _Color;

		float4 frag( v2f i ) : SV_Target
		{
			fixed4 texcol = tex2D( _MainTex, i.uv );
			clip( texcol.a*_Color.a - _Cutoff );

			SHADOW_CASTER_FRAGMENT(i)
		}
		ENDCG
		}

    }
	//FallBack "Transparent/Cutout/VertexLit"
}
