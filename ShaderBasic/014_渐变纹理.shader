Shader "Unlit/014"
{
    Properties
    {
		_RampTex("RampTex",2D)="white"{}
        _Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gross("Gross",Range(1,256))=2
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
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _RampTex;
			float4 _RampTex_ST;//自动对应到_MainTex tilling x,y offset x,y
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gross;

			struct v2f
			{
				float4 vertex:SV_POSITION;//必须包含
				fixed3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);

				//把法线转到世界空间上
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal = worldNormal;
				fixed3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldPos = worldPos;
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光源方向
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);//使用Unity库函数

				//纹理采样
				//fixed3 albedo = tex2D(_Ramp,i.uv).rgb;

				fixed3 halfLambert = dot(i.worldNormal,worldLightDir)* 0.5 + 0.5;

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * tex2D(_RampTex,halfLambert);//以 halfLambert 进行纹理采样
				
				//高光反射(Blinn-Phong)
				//视线方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//使用Unity库函数
				//半角方向
				fixed3 halfDir = normalize(viewDir + worldLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(i.worldNormal,halfDir)),_Gross);
				

				fixed3 color =diffuse +ambient +specular;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
}
