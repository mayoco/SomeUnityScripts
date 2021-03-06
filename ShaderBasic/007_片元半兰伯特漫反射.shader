﻿Shader "Unlit/007"
{//与兰伯特模型相比 黑的地方没有那么黑
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
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

			struct v2f
			{
				float4 vertex:SV_POSITION;//必须包含
				fixed3 worldNormal:TEXCOORD0;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);

				//把法线转到世界空间上
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldNormal=worldNormal;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光源方向
				fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
				//漫反射 frag Lambert diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal,worldLightDir)*0.5 + 0.5);//dot(i.worldNormal,worldLightDir) 结果位于[-1,1] 这里映射到了[0,1] 使结果不会过暗
				fixed3 color =diffuse +ambient;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
	FallBack "Diffuse"
}
