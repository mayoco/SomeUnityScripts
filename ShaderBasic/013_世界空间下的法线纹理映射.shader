Shader "Unlit/013"
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
				float4 uv:TEXCOORD0;//存了两个uv _MainTex _BumpMap
				float4 TtiW0 : TEXCOORD1;
				float4 TtiW1 : TEXCOORD2;
				float4 TtiW2 : TEXCOORD3;

			};

			
			v2f vert (appdata_tan v)//appdata_tan包含切线 appdata_base不含
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				//取得世界坐标下的光照计算向量 (顶点位置,法线,切线,副法线)
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

				//求得旋转矩阵并传给TtiW0,TtiW1,TtiW2 前3x3是按列摆放得到从切线空间到世界空间的转换矩阵 为了节省寄存器空间 最后一位存worldPos
				o.TtiW0 = float4(worldTangent.x,worldTangent.x,worldNormal.x,worldPos.x);
				o.TtiW1 = float4(worldTangent.y,worldTangent.y,worldNormal.y,worldPos.y);
				o.TtiW2 = float4(worldTangent.z,worldTangent.z,worldNormal.z,worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//世界坐标
				float3 worldPos =float3(i.TtiW0.w,i.TtiW1.w,i.TtiW2.w);

				//计算世界空间下的光照和视角
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				//获得法线纹理(切线空间)
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale ;
				//tangentNormal.z = sqrt(1-saturate(dot(normal.xy,normal.xy))) ;//在有的平台上需要加上这一句

				//切线空间转换到世界坐标
				fixed3 worldNormal = normalize(float3(dot(i.TtiW0.xyz,tangentNormal),dot(i.TtiW1.xyz,tangentNormal),dot(i.TtiW2.xyz,tangentNormal)));//相当于矩阵乘法

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//纹理采样
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb;

				//漫反射 半兰伯特
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * (dot(worldNormal,lightDir)* 0.5 + 0.5);
				
				//高光反射(Blinn-Phong) 半角向量与法线向量点积
				//半角方向
				fixed3 halfDir = normalize(viewDir + lightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gross);

				fixed3 color =diffuse +ambient +specular;

				return fixed4(color,1);
			}
            ENDCG
        }
    }
}
