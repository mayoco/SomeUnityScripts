Shader "Custom/005_Surface_Snow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SnowTex("SnowTex",2D) = "white"{}
		_NormalTex("NormalTex",2D) = "bump"{}
		_SnowDir("SnowDir",Vector) =(0,1,0)
		_SnowAmount("SnowAmount", Range(0,2)) = 1
		_SnowMaxLerp("SnowMaxLerp",Range(0,1)) = 1
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
		float4 _SnowDir;
		half _SnowAmount;
		half _SnowMaxLerp;


        struct Input
        {
            float2 uv_MainTex;
			float2 uv_NormalTex;
			float2 uv_SnowTex;
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
			o.Normal = normalTex;
			fixed3 wNormal = WorldNormalVector(IN , normalTex);//依照法线贴图采样获得世界法线 需要在Input结构体中定义worldNormal和INTERNAL_DATA

            float lerpVal = clamp(saturate(dot(wNormal,_SnowDir.xyz)),0,_SnowMaxLerp);

			// Albedo comes from a texture tinted by color
            fixed4 c = lerp(tex2D (_MainTex, IN.uv_MainTex),tex2D(_SnowTex,IN.uv_SnowTex)*_SnowAmount,lerpVal)* _Color;


            o.Albedo = c.rgb;
            
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
