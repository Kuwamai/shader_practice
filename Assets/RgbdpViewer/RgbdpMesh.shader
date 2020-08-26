Shader "Unlit/RgbdpMesh"
{
    Properties
    {
        _RgbdpTex ("RgbdpTexture", 2D) = "white" {}
        _MaxDepth ("MaxDepth", Float) = 1.3
        _MinDepth ("MinDepth", Float) = 0.15
        _FovX ("Camera FOV X", Float) = 69.4
        _FovY ("Camera FOV Y", Float) = 52.05
        _XLim ("X-limit", Float) = 0.0
        _YLim ("Y-limit", Float) = 0.0
        _ZLim ("Z-limit", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        //Tags { "RenderType"="Opaque" }
        //ZWrite Off
        AlphaToMask On
        //cull off
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
            float _XLim;
            float _YLim;
            float _ZLim;

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

            float getTexVal(float n){
                float2 width = float2(0.0303, 0.0833) / 2.0;
                float e = 1.0e-10;
                return rgb2hsv(tex2Dlod(_RgbdpTex, float4(width.x, width.y + width.y * n * 2.0, 0, 0)).xyz).x * 2.0 - 1.0;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float2 FocalLength;
                FocalLength.x = 0.5 / tan(radians(_FovX / 2));
                FocalLength.y = 0.5 / tan(radians(_FovY / 2));
                float4x4 mat = float4x4(
                    float4(getTexVal(8.0), getTexVal(5.0), getTexVal(2.0), getTexVal(11.0) * _XLim / 2.0),
                    float4(getTexVal(7.0), getTexVal(4.0), getTexVal(1.0), getTexVal(10.0) * _YLim / 2.0),
                    float4(getTexVal(6.0), getTexVal(3.0), getTexVal(0.0), getTexVal(9.0)  * _ZLim / 2.0),
                    float4(0, 0, 0, 1));
                //float z = _MaxDepth;
                //float z = abs(rgb2hsv(tex2Dlod(_RgbdpTex, float4(v.uv * 0.4848 + 0.5151, 0, 0))).x -1) * (_MaxDepth - _MinDepth) + _MinDepth;
                float z = rgb2hsv(tex2Dlod(_RgbdpTex, float4(float2(v.uv.x * 0.4848 + 0.5151, v.uv.y), 0, 0))).x * (_MaxDepth - _MinDepth) + _MinDepth;
                float x = z * (v.uv.x - 0.5) / FocalLength.x;
                float y = z * (v.uv.y - 0.5) / FocalLength.y;
                v.vertex.xyz = float3(x, y, z);
                v.vertex = mul(mat, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RgbdpTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(tex2D(_RgbdpTex, float2(i.uv.x * 0.4848 + 0.0303, i.uv.y)).rgb, rgb2hsv(tex2D(_RgbdpTex, float2(i.uv.x * 0.4848 + 0.5151, i.uv.y))).z);
                //fixed4 col = fixed4(tex2D(_RgbdpTex, i.uv * 0.4848 + 0.5151).xyz, 1);
                return col;
            }
            ENDCG
        }
    }
}