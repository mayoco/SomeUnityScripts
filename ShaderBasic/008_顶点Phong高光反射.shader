Shader "Unlit/008"
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
				fixed3 color:Color;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);

				//fixed3 worldPos = UnityObjectToWorldDir(v.vertex);//UnityObjectToWorldDir unity2018.3.7f1库中默认进行归一化 算出的位置是错误的
				fixed3 worldPos = mul(unity_ObjectToWorld,v.vertex);

				//计算光照
				//光源在世界空间 法线在模型空间 需要把法线转到世界空间上 才能计算
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLight = UnityWorldSpaceLightDir(worldPos);//使用Unity库函数
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//顶点兰伯特漫反射 vert Lambert diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));//saturate(x) 把x限制到[0,1]之间 这里用max(0,x)也可
				
				//高光反射(Phong) 反射光向量与视线向量点积
				//反射光方向
				fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));//reflect 所对应的光线方向是 由光源方向到入射点的向量 与unity中的默认光线方向的表示是相反的 故加上"-"
				//视线方向
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - UnityObjectToWorldDir(v.vertex));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));//使用Unity库函数
				//fixed3 viewDir = normalize(WorldSpaceViewDir(v.vertex));//传入模型空间顶点坐标

				fixed3 specular = _LightColor0*_Specular*pow(max(0,dot(reflectDir,viewDir)),_Gross);

				o.color=diffuse +ambient +specular;

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
