Shader "Unlit/RgbdpPoint"
{
    Properties
    {
        _RgbdpTex ("RgbdpTexture", 2D) = "white" {}
        _MaxDepth ("MaxDepth", Float) = 3
        _MinDepth ("MinDepth", Float) = 0.1
        _FovX ("Camera FOV X", Float) = 69.4
        _FovY ("Camera FOV Y", Float) = 52.05
        _PLim ("Position limit", Float) = 10.0
        _Size ("Particle size", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _RgbdpTex;
            float4 _RgbdpTex_ST;
            float _MaxDepth;
            float _MinDepth;
            float _FovX;
            float _FovY;
            float _PLim;
            float _Size;
            #pragma exclude_renderers gles

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 triuv : TEXCOORD0;
                float4 color : TEXCOORD1;
                float2 uv : TEXCOORD2;
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
                float texWidth = 1024;
                float aspectRatio = - UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1];
                float2 FocalLength;
                FocalLength.x = 0.5 / tan(radians(_FovX / 2));
                FocalLength.y = 0.5 / tan(radians(_FovY / 2));
                float4x4 mat = float4x4(
                    float4(getTexVal(8.0), getTexVal(5.0), getTexVal(2.0), getTexVal(11.0) * _PLim / 2.0),
                    float4(getTexVal(7.0), getTexVal(4.0), getTexVal(1.0), getTexVal(10.0) * _PLim / 2.0),
                    float4(getTexVal(6.0), getTexVal(3.0), getTexVal(0.0), getTexVal(9.0)  * _PLim / 2.0),
                    float4(0, 0, 0, 1));
                o.uv = float2((floor(v.vertex.z / texWidth) + 0.5) / texWidth, (fmod(v.vertex.z, texWidth) + 0.5) / texWidth);
                float z = rgb2hsv(tex2Dlod(_RgbdpTex, float4(float2(o.uv.x * 0.4848 + 0.5151, o.uv.y), 0, 0))).x * (_MaxDepth - _MinDepth) + _MinDepth;
                float x = z * (o.uv.x - 0.5) / FocalLength.x;
                float y = z * (o.uv.y - 0.5) / FocalLength.y;

                float3 p = float3(x, y, z);
                float4 vp1 = UnityObjectToClipPos(mul(mat, float4(p, 1)));
                float sz = _Size;
                float3x2 triVert = float3x2(
                    float2(0, 1),
                    float2(0.9, -0.5),
                    float2(-0.9, -0.5));
                o.triuv = triVert[round(v.vertex.y)];
                if (abs(UNITY_MATRIX_P[0][2]) < 0.0001) sz *= 2;
                sz *= pow(determinant((float3x3)UNITY_MATRIX_M),1/3.0);
                o.vertex = vp1+float4(o.triuv*sz*float2(aspectRatio,1),0,0);

                float4 c = float4(tex2Dlod(_RgbdpTex, float4(o.uv.x * 0.4848 + 0.0303, o.uv.y, 0, 0)).rgb, 1);
                o.color = c;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float l = length(i.triuv);
                if(abs(0 - rgb2hsv(tex2D(_RgbdpTex, float2(i.uv.x * 0.4848 + 0.5151, i.uv.y))).z) < 0.1) clip(-1);
                clip(0.5-l);
                return i.color;
            }
            ENDCG
        }
    }
}