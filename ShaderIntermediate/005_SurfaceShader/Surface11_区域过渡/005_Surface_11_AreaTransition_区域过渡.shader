Shader "Custom/005_Surface_11_AreaTransition"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_Dis("Dis",Range(0.1,10)) = 1//影响过渡区域的长度
		_StartPoint("StartPoint",Range(-10,10)) = 1
		_Tex2("Tex2",2D) = "white"{}
		_UnderInfluence("UnderInfluence",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		half _StartPoint;
		sampler2D _Tex2;
		half _Dis;
		half _UnderInfluence;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_Tex2;
			float3 worldPos;
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			float temp = saturate((IN.worldPos.y + _StartPoint)/_Dis);//saturate把输入值限制到[0, 1]之间。
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float clampTemp = clamp(temp,_UnderInfluence,1);//clamp 把输入值限制在[min, max]范围内  _UnderInfluence > 0时,对于下一步的lerp来说相当于总有c的影响,效果为Tex2半透明的叠加在原图像上
			fixed4 color = lerp(tex2D(_Tex2,IN.uv_Tex2),c,clampTemp);
            o.Albedo = color.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
