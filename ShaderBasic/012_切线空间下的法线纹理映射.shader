Shader "Unlit/012"
{
    Properties
    {
		_MainTex("MainTex",2D)="white"{}
		_BumpMap("NormalMap",2D)="bump"{}
		_BumpScale("Bump Scale",float) = 1
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
			float4 _MainTex_ST;//自动对应到_MainTex tilling x,y offset x,y
			float4 _BumpMap_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gross;
			float _BumpScale;

			struct v2f
			{
				float4 vertex:SV_POSITION;//必须包含
				fixed3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float2 uv:TEXCOORD2;
				float2 normalUv:TEXCOORD3;
			};

			
			v2f vert (appdata_tan v)//appdata_tan包含切线 appdata_base不含
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.normalUv = TRANSFORM_TEX(v.texcoord, _BumpMap);

				//把光照计算的向量转换到切线空间
				////求旋转矩阵
				////求副切线向量 (同时垂直于由法线与切线的向量)
				////float3 binormal = cross(v.normal,v.tangent.xyz)*v.tangent.w;//v.tangent.w 值为-1或者1,由DCC软件中的切线自动生成,和顶点的环绕顺序有关。
				////float3x3 rotation =float3(v.tangent.xyz, binormal, v.normal);

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

				fixed4 packedNormal = tex2D(_BumpMap,i.normalUv);

				//依照_BumpMap在切线空间下进行法线的采样
				//当_BumpMap为Default而不是normalmap时
				//fixed3 tangentNormal;
				//tangentNormal.xy = (packedNormal.xy*2 -1)*_BumpScale ;//(0,-1) -> (-1,1)*_BumpScale
				//tangentNormal.z = sqrt(1 - saturate( dot(tangentNormal.xy,tangentNormal.xy)));

				//_BumpMap设置成normalmap时
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale ;//UnpackNormal已包含tangentNormal.z的计算
				//tangentNormal.z = sqrt(1-saturate(dot(normal.xy,normal.xy))) ;//在有的平台上需要加上这一句

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//纹理采样
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb;

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (dot(tangentNormal,tangentLightDir)* 0.5 + 0.5);
				
				//高光反射(Blinn-Phong) 半角向量与法线向量点积
				//半角方向
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gross);

				fixed3 color =diffuse +ambient +specular;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
}
