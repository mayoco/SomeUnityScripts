Shader "Unlit/009"
{
    Properties
    {
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

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gross;

			struct v2f
			{
				float4 vertex:SV_POSITION;//必须包含
				fixed3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
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
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光源方向
				//fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);//使用Unity库函数
				//漫反射 frag Lambert diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal,worldLightDir));//dot(i.worldNormal,worldLightDir) 结果位于[-1,1] saturate 将<0的值设为0
				
				//高光反射(Phong) 反射光向量与视线向量点积
				//反射光方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
				//视线方向
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//使用Unity库函数

				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(reflectDir,viewDir)),_Gross);
				
				fixed3 color =diffuse +ambient +specular;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
	FallBack "Diffuse"
}
