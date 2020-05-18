Shader "Unlit/002Pass2"
{
    Properties
    {

    }
    SubShader
    {	

        Pass
        {
			//屏幕后处理
			ZWrite Off//关闭深度写入
			Blend [_SrcBlend] [_DstBlend]//由代码传入或系统设置 LDR的情况 Blend DstColor Zero ; HDR的情况 Blend One One
			//ps : Unity Shader-深度相关知识总结与效果实现（LinearDepth，Reverse Z，世界坐标重建，软粒子，高度雾，运动模糊，扫描线效果）

            CGPROGRAM
			#pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
			//后处理需要添加
            #pragma multi_compile_lightpass
			//排除不支持MRT的硬件
			#pragma exclude_renderers norm
			#pragma multi_compile __ UNITY_HDR_ON

			#include "UnityCG.cginc"
			//后处理需要添加 (ps "UnityDeferredLibrary.cginc" 与 计算衰减可使用的"AutoLight.cginc" 冲突)
			#include "UnityDeferredLibrary.cginc"
			#include "UnityGBuffer.cginc"

			sampler2D _CameraGBufferTexture0;
			sampler2D _CameraGBufferTexture1;
			sampler2D _CameraGBufferTexture2;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			//struct v2f
			//{
			//	float4 pos : SV_POSITION;
			//	float4 uv : TEXCOORD0;
			//	float3 ray : TEXCOORD1;
			//};

			unity_v2f_deferred vert(a2v i)
			{
				unity_v2f_deferred o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = ComputeScreenPos(o.pos);//屏幕空间的uv
				o.ray = UnityObjectToViewPos(i.vertex) * float3(-1,-1,1);//从屏幕空间到世界空间的方向向量 与UnityObjectToViewPos(i.vertex)获得的相反，需要按z轴翻转
				//_LightAsQuad 当在处理四边形时,也就是直射光时返回1,否则返回0 ps:四边形的直射光指的是,根据四边形获取光源
				o.ray = lerp(o.ray,i.normal,_LightAsQuad);
				return o;
			}

			//依照 低动态光照渲染/高动态光照渲染 进行返回值设置
			#ifdef UNITY_HDR_ON
			half4
			#else
			fixed4
			#endif
			frag(unity_v2f_deferred i) : SV_Target
			{
				//1.使用Unity库函数进行光照计算
				float3 worldPos;
				float2 uv;
				half3 lightDir;
				float atten;
				float fadeDist;
				UnityDeferredCalculateLightParams(i,worldPos,uv,lightDir,atten,fadeDist);
				
				
				//2.直接计算 
				//float2 uv = i.uv.xy/i.uv.w;

				////通过深度和方向重新构建世界坐标 (即已经拿到屏幕空间的图反过来计算对应点的世界坐标等)
				//float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,uv);//_CameraDepthTexture在UnityCG.cginc中,摄像机为延迟渲染时可直接获得 否则需要脚本进行设置
				//depth = Linear01Depth(depth);//将屏幕空间的深度值还原为视空间的深度值后再除以远裁剪面的大小，将视空间深度映射到（0,1）区间。
				
				////https://blog.csdn.net/puppet_master/article/details/77489948
				////ray 只能表示方向，长度不一定 _ProjectionParams.z表示远平面,因为xyz都是等比例,所以_ProjectionParams.z / i.ray.z就是rayToFarPlane和ray向量的比值
				//float3 rayToFarPlane = i.ray * (_ProjectionParams.z / i.ray.z);

				//float4 viewPos = float4(rayToFarPlane * depth,1);//视角空间下当前像素点所在的位置

				//float3 worldPos = mul(unity_CameraToWorld,viewPos).xyz;//得到该点的世界坐标

				//float fadeDist = UnityComputeShadowFadeDistance(worldPos,viewPos.z);

				////对不同的光进行光衰减,阴影计算
				////聚光灯(区域光)
				//#if defined(SPOT)
				//	float3 toLight = _LightPos.xyz - worldPos;
				//	half3 lightDir = normalize(toLight);
				//	float4 uvCookie = mul(unity_WorldToLight,float4(worldPos,1));
				//	float atten = tex2Dbias(_LightTexture0,float4(uvCookie.xy/uvCookie.w,0,-8)).w;

				//	atten * = uvCookie < 0;//方向判断
				//	atten * = tex2D(_LightTextureB0,dot(toLight,toLight) * _LightPos.w).r;
				//	atten * = UnityDeferredComputeShadow(worldPos,fadeDist,uv);

				////方向光
				//#elif defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
				//	half3 lightDir = -_LightDir.xyz;
				//	float atten = 1.0;

				//	atten *= UnityDeferredComputeShadow(worldPos,fadeDist,uv);

				//	#if defined(DIRECTIONAL_COOKIE)
				//	float4 uvCookie = mul(unity_WorldToLight,float4(worldPos,1));
				//	atten *= tex2Dbias(_LightTexture0,float4(uvCookie.xy,0,-8)).w;//方向光非透视 不用/uvCookie.w
				//	#endif

				////点光源
				//#elif defined(POINT) || defined(POINT_COOKIE)
				//	float3 toLight = _LightPos.xyz - worldPos;
				//	half3 lightDir = normalize(toLight);

				//	float atten = tex2D(_LightTextureB0,dot(toLight,toLight) * _LightPos.w).r;

				//	atten *= UnityDeferredComputeShadow(worldPos,fadeDist,uv);

				//	#if defined(POINT_COOKIE)
				//		float4 uvCookie = mul(unity_WorldToLight,float4(worldPos,1));
				//		atten *= texCUBEbias(_LightTexture0,float4(uvCookie.xyz,-8)).w;
				//	#endif
				//#else
				//half3 lightDir = 0;
				//float atten = 0;
				//#endif

				half3 lightColor = _LightColor.rgb * atten;

				half4 gbuffer0 = tex2D(_CameraGBufferTexture0,uv);
				half4 gbuffer1 = tex2D(_CameraGBufferTexture1,uv);
				half4 gbuffer2 = tex2D(_CameraGBufferTexture2,uv);

				half3 diffuseColor = gbuffer0.rgb;
				half3 specularColor = gbuffer1.rgb;
				float gloss = gbuffer1.a * 50;
				half3 worldNormal = normalize(gbuffer2.xyz * 2 -1);

				half3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
				half3 halfDir = normalize(lightDir + viewDir);

				half3 diffuse = lightColor * diffuseColor * max(0,dot(worldNormal,lightDir));
				half3 specular = lightColor * specularColor * pow(max(0,dot(worldNormal,halfDir)),gloss);

				half4 color = float4(diffuse + specular, 1);

				#ifdef UNITY_HDR_ON
				return color;
				#else
				return exp2(-color);
				#endif

			}

            ENDCG
        }

		Pass//转码 主要是对于LDR转码 (低动态光照渲染/高动态光照渲染 有关)
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Stencil
			{
				ref[_StencilNonBackground] //天空盒遮罩
				readMask[_StencilNonBackground]

				compback equal
				compfront equal
			}

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers nomrt

			#include "UnityCG.cginc"

			sampler2D _LightBuffer;
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			v2f vert(float4 vertex:POSITION,float2 texcoord :TEXCOORD0)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(vertex);
				o.texcoord = texcoord.xy;
				#ifdef UNITY_SINGLE_PASS_STEREO
				o.texcoord = TransformStereoScreenSpaceTex(o.texcoord,1.0);
				#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return -log2(tex2D(_LightBuffer,i.texcoord));
			}

			ENDCG
		}
    }
}
