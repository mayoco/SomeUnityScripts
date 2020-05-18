Shader "Unlit/020"
{//包括描边,分层过渡的颜色处理,法线贴图 雪的效果 编辑器代码使用宏控制开关效果 cs代码全局控制
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Color",Color) = (1,1,1,1)
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",float) = 1 
		_Outline("Outline",Range(0,0.2)) = 0.1
		_OutlineColor("OutlineColor",Color) = (0,0,0,0)
		_Step("Step",Range(1,30))=3
		_ToonEffect("ToonEffect",Range(0,1)) = 0.5
		//_Snow("Snow Level",Range(0,1))=0.5 //注释掉以便通过Snow.cs代码设置
		_SnowColor("SnowColor",Color)=(1,1,1,1)
		_SnowDir("SnowDir",Vector) = (0,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

		UsePass "Unlit/019/Outline"  //复用之前写的019里的Outline描边效果

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			//定义宏 配合编辑器代码Tools.cs控制开关雪的效果  这里是用一个变量表示 也可以用两个 SNOW_OFF SNOW_ON
			#pragma multi_compile __ SNOW_ON

            #include "UnityCG.cginc"
			#include "Lighting.cginc"



            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			float _Step;
			float _ToonEffect;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _SnowColor;//积雪
			float4 _SnowDir;
			float _Snow;
			

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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

				float difLight = dot(lightDir,worldNormal)*0.5 +0.5;
				difLight = smoothstep(0,1,difLight);
				float toon = floor(difLight * _Step)/_Step;
				difLight =lerp(difLight,toon,_ToonEffect);
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * difLight;
				
				fixed4 color = fixed4(ambient + diffuse,1);
				
				#if SNOW_ON
				//积雪效果
				if(dot(worldNormal,_SnowDir.xyz)>lerp(1,-1,_Snow))
				{
					color.rgb = _SnowColor.rgb;
				}else
				{
					color.rgb = color.rgb;
				}
				#endif

                return color;
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
