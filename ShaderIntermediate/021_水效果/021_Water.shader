Shader "Custom/021_Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_WaterShallowColor("WaterShallowColor",Color) =(1,1,1,1)
		_WaterDeepColor("WaterDeepColor",Color) =(1,1,1,1)
		_TransAmount("TransAmount",Range(0,100)) = 20
		_DepthRange("DepthRange",float) = 1
		_NormalTex("Normal",2D) ="bump"{}
		_Refract("Refract",float) = 0.5
		_WaterSpeed("WaterSpeed",float) = 5
		_Specular("Specular",float) = 1
		_Gloss("Gloss",float) = 0.5
		_SpecularColor("SpecularColor",Color) =(1,1,1,1)
		//波浪
		_WaveTex("WaveTex",2D) = "white"{}
		_NoiseTex("NoiseTex",2D) ="white"{}
		_WaveSpeed("WaveSpeed",float) = 1
		_WaveRange("WaveRange",float) = 0.5
		_WaveRangeA("WaveRangeA",float) = 1
		_WaveDelta("WaveDelta",float) = 0.5
		//抓屏扰动
		_Distortion("Distortion",float) = 0.5
		//菲涅尔反射
		_Cubemap("Cubemap",Cube)= "_Skybox"{}
		_FresnelScale("FresnelScale",Range(0,1))=0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 200

		GrabPass{"GrabPass"}

		ZWrite off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf WaterLight vertex:vert alpha noshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D_float _CameraDepthTexture;
		sampler2D _NormalTex;
		sampler2D _WaveTex;
		sampler2D _NoiseTex;
		sampler2D GrabPass;
		float4 GrabPass_TexelSize;
		samplerCUBE _Cubemap;

        struct Input
        {
			float2 uv_NormalTex;
			float2 uv_WaveTex;
			float2 uv_NoiseTex;
			float4 proj;
			float3 worldRefl;
			float3 viewDir;
			float3 worldNormal;
			INTERNAL_DATA
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		fixed4 _WaterShallowColor;
		fixed4 _WaterDeepColor;
		half _TransAmount;
		half _DepthRange;
		half _WaterSpeed;
		half _Refract;
		half _Specular;
		half _Gloss;
		fixed4 _SpecularColor;
		float _WaveSpeed;
		float _WaveRange;
		float _WaveRangeA;
		float _WaveDelta;
		float _Distortion;
		float _FresnelScale;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		fixed4 LightingWaterLight(SurfaceOutput s,fixed3 lightDir,half3 viewDir,fixed atten)
		{
			float diffuseFactor = max(0,dot(normalize(lightDir),s.Normal));
			half3 halfDir = normalize(lightDir + viewDir);
			float nh = max(0,dot(halfDir,s.Normal));
			float spec = pow(nh,s.Specular * 128) * s.Gloss;
			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diffuseFactor + _SpecularColor.rgb * spec * _LightColor0.rgb) * atten;
			c.a = s.Alpha + spec * _SpecularColor.a;
			return c;
		}

		void vert(inout appdata_full v,out Input i)
		{
			UNITY_INITIALIZE_OUTPUT(Input,i);

			i.proj = ComputeScreenPos(UnityObjectToClipPos(v.vertex));
			COMPUTE_EYEDEPTH(i.proj.z);
		}

        void surf (Input IN, inout SurfaceOutput o)
        {
			//tex2Dproj(_CameraDepthTexture,IN.proj) == tex2D(_CameraDepthTexture,IN.proj.xy/IN.proj.w)
			//SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(IN.proj));
			half depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(IN.proj)).r);
			half deltaDepth = depth - IN.proj.z;//depth为采样深度图得到的深度(湖底) IN.proj.z为当前顶点的深度(湖面)
            //按深度进行颜色变化
			fixed4 c = lerp(_WaterShallowColor,_WaterDeepColor,min(deltaDepth,_DepthRange)/_DepthRange);

			//表面法线扭曲
			float4 bumpOffset1 = tex2D(_NormalTex,IN.uv_NormalTex + float2(_WaterSpeed*_Time.x,0));
			float4 bumpOffset2 = tex2D(_NormalTex,float2(1-IN.uv_NormalTex.y,IN.uv_NormalTex.x) + float2(_WaterSpeed * _Time.x,0));//uv反转并偏移
			float4 offsetColor = (bumpOffset1+bumpOffset2)/2;
			float2 offset = UnpackNormal(offsetColor).xy*_Refract;
			bumpOffset1 = tex2D(_NormalTex,IN.uv_NormalTex + offset + float2(_WaterSpeed*_Time.x,0));//计算第二次offset
			bumpOffset2 = tex2D(_NormalTex,float2(1-(IN.uv_NormalTex.y+offset.y),IN.uv_NormalTex.x+offset.x) + float2(_WaterSpeed * _Time.x,0));
			offsetColor = (bumpOffset1+bumpOffset2)/2;
			o.Normal = UnpackNormal(offsetColor);

			//波浪
			half waveB = 1 - min(_WaveRangeA,deltaDepth)/_WaveRangeA;
			fixed4 noiseColor = tex2D(_NoiseTex,IN.uv_NoiseTex);
			fixed4 waveColor = tex2D(_WaveTex,float2(waveB + _WaveRange * sin(_Time.x * _WaveSpeed + noiseColor.r),1)+offset);//波浪位置偏移
			waveColor.rgb *=(1-(sin(_Time.x * _WaveSpeed +noiseColor.r)+1)/2) * noiseColor.r;//波浪强度变化
			fixed4 waveColor2 = tex2D(_WaveTex,float2(waveB + _WaveRange * sin(_Time.x * _WaveSpeed + _WaveDelta + noiseColor.r),1)+offset);
			waveColor2.rgb *=(1-(sin(_Time.x * _WaveSpeed + _WaveDelta + noiseColor.r )+1)/2) * noiseColor.r;//波浪强度变化

			//抓屏 扰动 折射
			offset = o.Normal.xy * _Distortion * GrabPass_TexelSize.xy;
			IN.proj.xy = offset * IN.proj.z + IN.proj.xy;
			fixed3 refrCol = tex2D(GrabPass,IN.proj.xy/IN.proj.w).rgb;//折射

			//反射
			fixed3 reflaction = texCUBE(_Cubemap,WorldReflectionVector(IN,o.Normal)).rgb;
			fixed fresnel = _FresnelScale + (1-_FresnelScale) * pow(1-dot(IN.viewDir,WorldNormalVector(IN,o.Normal)),5);

			//折射反射融合
			fixed3 refrAndRefl = lerp(reflaction,refrCol,saturate(fresnel));

            o.Albedo = (c.rgb + (waveColor.rgb + waveColor2.rgb) * waveB)*refrAndRefl;

			o.Gloss = _Gloss;
			o.Specular =_Specular;

			//按深度进行透明度变化
            o.Alpha = min(deltaDepth,_DepthRange)/_TransAmount;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
