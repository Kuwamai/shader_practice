Shader "Unlit/RgbdpMesh"
{
    Properties
    {
        _RgbdpTex ("RgbdpTexture", 2D) = "white" {}
        _MaxDepth ("MaxDepth", Float) = 1.3
        _MinDepth ("MinDepth", Float) = 0.15
        _FovX ("Camera FOV X", Float) = 69.4
        _FovY ("Camera FOV Y", Float) = 52.05
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
            #include "UnityCG.cginc"

            sampler2D _RgbdpTex;
            float4 _RgbdpTex_ST;
            float _MaxDepth;
            float _MinDepth;
            float _FovX;
            float _FovY;

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

            float3 rgb2hsv(float3 c){
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 FocalLength;
                FocalLength.x = 0.5 / tan(radians(_FovX / 2));
                FocalLength.y = 0.5 / tan(radians(_FovY / 2));
                float z = rgb2hsv(tex2Dlod(_RgbdpTex, float4(v.uv / 2.0, 0, 0))).x * (_MaxDepth - _MinDepth) + _MinDepth;
                float x = z * (v.uv.x - 0.5) / FocalLength.x;
                float y = z * (v.uv.y - 0.5) / FocalLength.y;
                v.vertex.xyz = float3(x, y, z);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RgbdpTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_RgbdpTex, i.uv / 2.0 + 0.5);
                return col;
            }
            ENDCG
        }
    }
}