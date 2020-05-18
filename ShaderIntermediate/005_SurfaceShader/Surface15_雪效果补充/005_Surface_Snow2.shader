Shader "Custom/005_Surface_Snow2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SnowTex("SnowTex",2D) = "white"{}
		_SnowNormal("SnowNormal",2D) = "bump"{}
		_NormalTex("NormalTex",2D) = "bump"{}
		_SnowDir("SnowDir",Vector) =(0,1,0)
		_SnowAmount("SnowAmount", Range(0,2)) = 1
		_SnowMaxLerp("SnowMaxLerp",Range(0,1)) = 1//0 不显示雪
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardSpecular fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _SnowTex;
		sampler2D _SnowNormal;
		float4 _SnowDir;
		half _SnowAmount;
		half _SnowMaxLerp;


        struct Input
        {
            float2 uv_MainTex;
			float2 uv_NormalTex;
			float2 uv_SnowTex;
			float2 uv_SnowNormal;
			float3 worldNormal;
			INTERNAL_DATA
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandardSpecular o)
        {
			float3 normalTex = UnpackNormal(tex2D(_NormalTex,IN.uv_NormalTex));
			float3 snowNormal = UnpackNormal(tex2D(_SnowNormal,IN.uv_SnowNormal));

			fixed3 wNormal = WorldNormalVector(IN , float3(0,0,1));//依照模型自生网格体的信息得到世界法线 
			//WorldNormalVector 相当于进行 worldN.x = dot(_unity_tbn_0,o.Normal); worldN.y = dot(_unity_tbn_1,o.Normal); worldN.z = dot(_unity_tbn_2,o.Normal); worldN=normalize(worldN);

			fixed3 finalNormal = lerp(normalTex,snowNormal,saturate(dot(wNormal,_SnowDir.xyz)));

			o.Normal = finalNormal;

			fixed3 fWNormal = WorldNormalVector(IN,finalNormal);
            float lerpVal = clamp(saturate(dot(fWNormal,_SnowDir.xyz)),0,_SnowMaxLerp);

			// Albedo comes from a texture tinted by color
            fixed4 c = lerp(tex2D (_MainTex, IN.uv_MainTex),tex2D(_SnowTex,IN.uv_SnowTex)*_SnowAmount,lerpVal)* _Color;

            o.Albedo = c.rgb;
            
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
