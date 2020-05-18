Shader "Unlit/015"
{
    Properties
    {
		_MainTex("MainTex",2D)="white"{}
		_BumpMap("NormalMap",2D)="bump"{}//"bump" 放置贴图时会提示转成normal map
		_BumpScale("Bump Scale",float) = 1
		_SpecularMask("Specular Mask",2D) = "white"{}
		_SpecularScale("Specular Scale",float) = 1
        _Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gross("Gross",Range(1,256))=2
		//转换成法线贴图 ps中 滤镜>3D>法线图
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
			sampler2D _BumpMap;
			sampler2D _SpecularMask;
			float4 _MainTex_ST;//自动对应到_MainTex tilling x,y offset x,y
			float4 _BumpMap_ST;
			float4 _SpecularMask_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gross;
			float _BumpScale;
			float _SpecularScale;

			struct v2f
			{
				float4 vertex:SV_POSITION;//必须包含
				fixed3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float4 uv:TEXCOORD2;
				float2 maskUv :TEXCOORD3;
			};

			
			v2f vert (appdata_tan v)//appdata_tan包含切线 appdata_base不含
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.maskUv = TRANSFORM_TEX(v.texcoord, _SpecularMask);

				TANGENT_SPACE_ROTATION;//宏 相当于进行了切线空间的转换 定义了某些变量

				//求切线空间光源方向及视角方向
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//获取切线空间下的光照计算所需向量
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//法线纹理采样
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);

				//_BumpMap设置成normalmap时
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale ;//UnpackNormal已包含tangentNormal.z的计算
				//tangentNormal.z = sqrt(1-saturate(dot(normal.xy,normal.xy))) ;//在有的平台上需要加上这一句

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//纹理采样
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb;

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (dot(tangentNormal,tangentLightDir)* 0.5 + 0.5);
				
				//高光反射(Blinn-Phong) 半角向量与法线向量点积
				//半角方向
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				
				//高光遮罩采样
				fixed3 specularMask = tex2D(_SpecularMask,i.maskUv).r * _SpecularScale;

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gross)*specularMask;

				fixed3 color = diffuse +ambient +specular;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
}
