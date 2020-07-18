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
                return v * lerp(float3(t.x, t.x, t.x), clamp(p - float3(t.x, t.x, t.x), 0.0, 1.0), s);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;
                float2 width = float2(0.0938, 0.1667);
                //float2 width = float2(1/6*9/16, 1.0/6.0);

                if(ScreenPos.x > width.x) {
                    c = fixed4(0, 0, 0, 0);
                }
                else if(ScreenPos.y >= width.y*5.0 && ScreenPos.y < 1.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.x / _XLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*4.0 && ScreenPos.y < width.y*5.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.y / _YLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*3.0 && ScreenPos.y < width.y*4.0) {
                    c = fixed4(hsv2rgb(i.CameraPos.z / _ZLim - 0.5, 1, 1), 1);
                }
                else if(ScreenPos.y >= width.y*2.0 && ScreenPos.y < width.y*3.0) {
                    c = fixed4(0, 0, 1, 1);
                }
                else if(ScreenPos.y >= width.y     && ScreenPos.y < width.y*2.0) {
                    c = fixed4(1, 0, 1, 1);
                }
                else if(ScreenPos.y < width.y) {
                    c = fixed4(1, 0, 0, 1);
                }
                return c;
            }
            ENDCG
        }
    }
}
