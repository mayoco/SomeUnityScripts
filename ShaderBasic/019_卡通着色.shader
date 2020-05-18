Shader "Unlit/019"
{//包括描边,分层过渡的颜色处理,边缘光,被遮挡的地方显示xRay效果
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Color",Color) = (1,1,1,1)
		_Outline("Outline",Range(0,0.2)) = 0.1
		_OutlineColor("OutlineColor",Color) = (0,0,0,0)
		_Steps("Steps",Range(1,30)) =5
		_ToonEffect("ToonEffect",Range(0,1)) = 0.5
		_RampTex("RampTex",2D)="white"{}//渐进纹理 
		_RimColor("RimColor",Color) = (0,0,0,0)//边缘光
		_RimPower("RimPower",Range(0.001,3)) = 1
		_XRayColor("XRayColor",Color) = (0,0,0,0)//Xray边缘光
		_XRayPower("XRayPower",Range(0.001,3)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Geometry+1000" "RenderType"="Transparent" }
        LOD 100

		//每个Pass 一个Batch

		//Xray效果 当物体被遮挡时(这个通道的深度测试的条件设为大于等于,并且不写入深度)，显示边缘光
		Pass
		{
			Name "XRay"
			Tags{"ForceNoShadowCasting" = "true"}
			Blend SrcAlpha One //将透明的效果进行叠加
			ZWrite Off //若写入深度,会影响到后面通道绘制的深度测试,造成混乱
			ZTest Greater //只有当被遮挡时才绘制这个Pass

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 viewDir : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			fixed4 _XRayColor;
			float _XRayPower;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;//漫反射需要求法线
				o.viewDir = ObjSpaceViewDir(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normal = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);
				//边缘光
				float xRay = 1 - dot(normal,viewDir);

				//fixed4 xRayColor = _XRayColor * pow(xRay,1/_XRayPower);
				//return xRayColor;
				
				return _XRayColor * xRay *(1+ _XRayPower);
			}
			ENDCG
		}

		//描边 绘制反面并外拓 达到描边效果 (1.物体空间外拓 2.视角空间外拓 3.裁剪空间外拓)
		Pass
		{
			Name "Outline"//起名 方便重复使用
			Cull Front//不画正面

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				float _Outline;
				fixed4 _OutlineColor;

				struct v2f
				{
					float4 vertex : SV_POSITION;
					
				};

				v2f vert(appdata_base v){
					v2f o;
					//物体空间法线外拓
					//v.vertex.xyz +=v.normal * _Outline;
					//o.vertex =  UnityObjectToClipPos(v.vertex);

					//视角空间法线外拓
					//float4 pos = mul(UNITY_MATRIX_V,mul(unity_ObjectToWorld,v.vertex));
					//float3 normal = normalize(mul(UNITY_MATRIX_IT_MV,v.normal));//IT-转置
					//pos = pos + float4(normal,0) * _Outline;
					//o.vertex =  mul(UNITY_MATRIX_P,pos);

					//裁剪空间法线外拓
					o.vertex =  UnityObjectToClipPos(v.vertex);
					float3 normal = normalize(mul(UNITY_MATRIX_IT_MV,v.normal));
					float2 viewNormal = TransformViewToProjection(normal.xy);
					o.vertex.xy+=viewNormal*_Outline;

					return o;
				}

				float4 frag(v2f i):SV_Target
				{
					return _OutlineColor;
				}


			ENDCG

		}

		//绘制主体
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct v2f
            {
				float4 vertex : SV_POSITION;//必须
                float2 uv : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _RampTex;
            //float4 _RampTex_ST;//这里不需要调整tilling, offset就不加了
			float4 _Diffuse;
			float _Steps;
			float _ToonEffect;
			fixed4 _RimColor;
			float _RimPower;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);//漫反射需要求法线
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed4 albedo = tex2D(_MainTex, i.uv);

				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//光源方向
				fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
				//漫反射
				float difLight = dot(worldLightDir,i.worldNormal)*0.5+0.5;
				////1. 卡通颜色 通过渐进纹理采样
				//fixed4 rampColor = tex2D(_RampTex, difLight);
				//fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * rampColor ;

				//2. 卡通颜色 通过smoothstep 和 floor ,  _Steps控制色阶数 , _ToonEffect控制卡通化的程度
				//颜色平滑在[0,1]之间
				difLight = smoothstep(0,1,difLight);//smoothstep用于求解两个值之间的样条插值
				//颜色离散化
				float toon = floor( difLight * _Steps )/_Steps;
				difLight = lerp(difLight,toon,_ToonEffect);//按权重_ToonEffect 从difLight toon 之间 设置最终效果
				fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * difLight ;

				//边缘光
				float rim = 1 - dot(i.worldNormal,viewDir);//垂直时dot(i.worldNormal,viewDir)=0 rim=1
				fixed4 rimColor = _RimColor * pow(rim,1/_RimPower);

                return float4(ambient+diffuse+rimColor,1);
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
