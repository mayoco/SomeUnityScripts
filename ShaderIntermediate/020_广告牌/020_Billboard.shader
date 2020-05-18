Shader "Unlit/020_Billboard"
{//广告牌效果 实现原理->将模型转向到总是面对摄像机
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[MaterialToggle]_Vertical("Vertical",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
        LOD 100

        Pass
        {
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull off

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _Vertical;

            v2f vert (appdata v)
            {
                v2f o;
				float3 center = float3(0,0,0);
				float3 view = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));

				float3 normalDir = view - center;//得到表面法线 (由模型中心指向摄像机)
				normalDir.y = normalDir.y * _Vertical;
				normalDir = normalize(normalDir);

				float3 upDir = abs(normalDir.y) >0.999 ? float3(0,0,1) : float3(0,1,0);//如果表面法线向上 upDir(假的上方向) 为 (0,0,1)
				float3 rightDir = normalize(cross(upDir,normalDir));
				upDir = normalize(cross(normalDir,rightDir));//算出真正的向上的方向
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;//依照新的基坐标进行吧变换

                o.vertex = UnityObjectToClipPos(float4(localPos,1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
