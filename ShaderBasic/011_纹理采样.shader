Shader "Unlit/011"
{
    Properties
    {
		_MainTex("MainTex",2D)="white"{}
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

			sampler2D _MainTex;
			float4 _MainTex_ST;//自动对应到_MainTex tilling x,y offset x,y
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
				//o.worldPos = UnityObjectToWorldDir(v.vertex);//UnityObjectToWorldDir unity2018.3.7f1库中默认进行归一化 算出的位置是错误的
				o.worldPos = worldPos;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);//相当于 o.uv = v.texcoord.xy *_MainTex_ST.xy + _MainTex_ST.zw;//_MainTex_ST.xy缩放 _MainTex.zw偏移
						//TRANSFORM_TEX主要作用是拿顶点的uv去和材质球的tiling和offset作运算， 确保材质球里的缩放和偏移设置是正确的。 （v.texcoord就是顶点的uv）
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光源方向
				//fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);//使用Unity库函数

				//纹理采样
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb;

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (dot(i.worldNormal,worldLightDir)* 0.5 + 0.5);
				
				//高光反射(Blinn-Phong) 半角向量与法线向量点积
				//视线方向
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
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
