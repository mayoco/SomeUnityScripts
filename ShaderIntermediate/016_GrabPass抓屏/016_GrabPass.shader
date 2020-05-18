Shader "Unlit/016_GrabPass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Color",Color) = (1,1,1,1)
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",float) = 1 
		_Cubemap("CubeMap",Cube) = "_Skybox"{}
		_Distortion("Distortion",Range(0,100)) = 10
		_RefractAmount("RefractAmount",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+100"}//Transparent+100 保证在其他物体渲染完之后再渲染
        LOD 100

		GrabPass{"GrabPass"}//抓屏 产生一个RenderTexture 使用这个名字可以在其他地方使用该GrabPass,只渲染一次 并且不能按照UsePass的方法来使用

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"



            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				float4 scrPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D GrabPass;
			float4 GrabPass_TexelSize;//获得GrabPass的像素值 宽高
			float _Distortion;
			samplerCUBE _Cubemap;
			float _RefractAmount;

            v2f vert (appdata_tan v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeGrabScreenPos(o.vertex);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);
				//取得世界坐标下的光照计算向量 (顶点位置,法线,切线,副法线)
				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
				//求得旋转矩阵并传给TtiW0,TtiW1,TtiW2 前3x3是按列摆放得到从切线空间到世界空间的转换矩阵 为了节省寄存器空间 最后一位存worldPos
				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

                fixed4 albedo = tex2D(_MainTex, i.uv);

				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

				fixed3 lightDir = UnityWorldSpaceLightDir(worldPos);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				//求法线
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *=_BumpScale;

				fixed3 worldNormal = normalize(float3(dot(i.TtoW0.xyz,tangentNormal),dot(i.TtoW1.xyz,tangentNormal),dot(i.TtoW2.xyz,tangentNormal)));

				//采样抓屏贴图
				//计算偏移
				float2 offset = tangentNormal.xy * _Distortion * GrabPass_TexelSize;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D(GrabPass,i.scrPos.xy/i.scrPos.w).rgb;//折射
				fixed3 reflCol = texCUBE(_Cubemap,reflect(-viewDir,worldNormal)).rgb *albedo ;//反射

				fixed3 color = reflCol * (1-_RefractAmount) + refrCol * _RefractAmount;
				
                return fixed4(color,1);
            }
            ENDCG
        }
    }
}
