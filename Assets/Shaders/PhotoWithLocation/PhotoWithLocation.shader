Shader "Custom/Photo with location" {
    Properties{
        _XLim ("X-limit", Float) = 0.0
        _YLim ("Y-limit", Float) = 0.0
        _ZLim ("Z-limit", Float) = 0.0
    }
    SubShader{
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent+2" }
        LOD 200
        ZTest Always
        Cull Off

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
               
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 Vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 ScreenPos   : TEXCOORD0;
                float3 CameraPos    : TEXCOORD1;
                float4 Vertex : SV_POSITION;
            };

            float _XLim;
            float _YLim;
            float _ZLim;

            v2f vert(appdata v) {
                v2f o;
                o.Vertex = UnityObjectToClipPos(v.Vertex);
                o.ScreenPos = ComputeScreenPos(o.Vertex);
                o.CameraPos = _WorldSpaceCameraPos;
                return o;
            };

            float3 hsv2rgb(float h, float s, float v){
                float4 t = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(float3(h, h, h) + t.xyz) * 6.0 - float3(t.w, t.w, t.w));
                float3 hsv = v * lerp(float3(t.x, t.x, t.x), clamp(p - float3(t.x, t.x, t.x), 0.0, 1.0), s);
                return hsv;
                //return clamp(hsv, 0.02, 0.98);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;
                float2 width = float2(0.0469, 0.0833);
                //float2 width = float2(1/12*9/16, 1.0/12.0);

                if(ScreenPos.x > width.x) {
                    c = fixed4(0, 0, 0, 0);
                }
                else if(ScreenPos.y >= width.y*11.0 && ScreenPos.y < 1.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.x / _XLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*10.0 && ScreenPos.y < width.y*11.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.y / _YLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*9.0 && ScreenPos.y < width.y*10.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.z / _ZLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*8.0 && ScreenPos.y < width.y*9.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m00, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*7.0 && ScreenPos.y < width.y*8.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m01, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*6.0 && ScreenPos.y < width.y*7.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m02, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*5.0 && ScreenPos.y < width.y*6.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m10, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*4.0 && ScreenPos.y < width.y*5.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m11, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*3.0 && ScreenPos.y < width.y*4.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m12, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*2.0 && ScreenPos.y < width.y*3.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m20, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y     && ScreenPos.y < width.y*2.0) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m21, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                else if(ScreenPos.y < width.y) {
                    c = fixed4(hsv2rgb((clamp(UNITY_MATRIX_V._m22, -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                return c;
            }
            ENDCG
        }
    }
}
