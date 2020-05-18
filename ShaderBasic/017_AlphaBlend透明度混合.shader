Shader "Unlit/017"
{
    Properties
    {
		_MainTex("MainTex",2D)="white"{}
        _Diffuse("Diffuse",Color)=(1,1,1,1)
		_AlphaScale("AlphaScale",Range(0,1))=1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}//指定Queue 提高性能
        LOD 100
		
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha //正常（Normal）透明度混合

        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;//自动对应到_MainTex tilling x,y offset x,y
			fixed4 _Diffuse;
			float _AlphaScale;

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
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//光源方向
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);//使用Unity库函数

				//纹理采样
				fixed4 texColor = tex2D(_MainTex,i.uv);

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * texColor.rgb * _Diffuse.rgb * (dot(i.worldNormal,worldLightDir)* 0.5 + 0.5);
				
				
				fixed3 color =diffuse +ambient;

				return fixed4(color,texColor.a*_AlphaScale);
			}
            ENDCG
        }
    }
	FallBack "Transparent/VertexLit"
}
