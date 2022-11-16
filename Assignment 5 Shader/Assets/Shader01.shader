Shader "Unlit/Shader01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("ColorA", Color) = (1, 1, 1, 1)
        _ColorB ("ColorB", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define TAU 6.28318530

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                //float3 normals: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                //float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _ColorA;
            float4 _ColorB;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                //o.normal = UnityObjectToWorldNormal(v.normals);
                //o.uv = v.uv;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;

                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;

                float t = (cos((i.uv.y + xOffset + _Time.y / 3) * TAU * 5) + 1) * 0.5;
                return float4(t, 1, 1, 0.5);

                //float4 outputColor = lerp(_ColorA, _ColorB, i.uv.x);
                //return outputColor;
            }
            ENDCG
        }
    }
}
