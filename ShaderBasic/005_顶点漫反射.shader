Shader "Unlit/005"
{
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
				fixed3 color:Color;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);

				//计算光照
				//光源在世界空间 法线在模型空间 需要把法线转到世界空间上 才能计算
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//顶点兰伯特漫反射 vert Lambert diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//saturate(x) 把x限制到[0,1]之间 这里用max(0,x)也可
				
				o.color=diffuse +ambient;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
