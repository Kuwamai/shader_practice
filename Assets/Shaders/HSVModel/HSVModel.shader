Shader "Unlit/HSVModel"
{
    Properties
    {
        _Hue ("Hue",        Range(0, 1)) = 0.0
        _Sat ("Saturation", Range(0, 1)) = 1.0
        _Val ("Value",      Range(0, 1)) = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            float _Hue;
            float _Sat;
            float _Val;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float3 hsv2rgb(float h, float s, float v){
                float4 t = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(float3(h, h, h) + t.xyz) * 6.0 - float3(t.w, t.w, t.w));
                return v * lerp(float3(t.x, t.x, t.x), clamp(p - float3(t.x, t.x, t.x), 0.0, 1.0), s);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(hsv2rgb(_Hue, _Sat, _Val), 1);
                return col;
            }
            ENDCG
        }
    }
}
