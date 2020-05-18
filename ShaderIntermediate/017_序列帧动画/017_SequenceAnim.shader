Shader "Unlit/017_SequenceAnim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_HorAmount("HorAmount",float) = 4 //横
		_VerAmount("VerAmount",float) = 4 //竖
		_Speed("Speed",Range(1,100)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "IgnoreProjector"="True"}
        LOD 100

        Pass
        {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _HorAmount;
			float _VerAmount;
			float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float time = floor(_Time.y * _Speed);
				float row = floor(time/_HorAmount);//第几行
				float col = time - row * _HorAmount;//第几列

				half2 uv = i.uv + half2(col,-row);

				uv.x/=_HorAmount;
				uv.y/=_VerAmount;

                // sample the texture
                fixed4 color = tex2D(_MainTex, uv);
                return color;
            }
            ENDCG
        }
    }
}
