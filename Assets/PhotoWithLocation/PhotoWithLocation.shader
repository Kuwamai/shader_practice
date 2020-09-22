Shader "Custom/Photo with location" {
    Properties{
        _XLim ("X-limit", Float) = 0.0
        _YLim ("Y-limit", Float) = 0.0
        _ZLim ("Z-limit", Float) = 0.0
    }
    SubShader{
        Tags {"Queue"="Overlay"}
        ZWrite off
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
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 ScreenPos   : TEXCOORD0;
                float3 CameraPos    : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _XLim;
            float _YLim;
            float _ZLim;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.ScreenPos = ComputeScreenPos(o.vertex);
                o.CameraPos = _WorldSpaceCameraPos;
                if(abs(60.0 - degrees(atan(1/unity_CameraProjection._m11))*2.0) > 0.01) o.vertex = 0;
                return o;
            };

            float3 hsv2rgb(float h, float s, float v){
                float4 t = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(float3(h, h, h) + t.xyz) * 6.0 - float3(t.w, t.w, t.w));
                float3 hsv = v * lerp(float3(t.x, t.x, t.x), clamp(p - float3(t.x, t.x, t.x), 0.0, 1.0), s);
                return hsv;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;
                float3 PosLim = float3(_XLim, _YLim, _ZLim);

                //float2 width = float2(1/12*9/16, 1.0/12.0);
                if(ScreenPos.x > 0.0469) {
                    c = fixed4(0, 0, 0, 0);
                }
                else if(ScreenPos.y > 0.75) {
                    int iy = 2 - floor((ScreenPos.y - 0.7500)*4.0*3.0);
                    c = fixed4(hsv2rgb(i.CameraPos[iy] / PosLim[iy] - 0.5, 1, 1), 1);
                }
                else {
                    int iyr =  2 - floor(ScreenPos.y / 0.75*3.0);
                    int iyc =  fmod(8 - floor(ScreenPos.y / 0.75*9.0), 3);
                    float4x4 camera_rot = UNITY_MATRIX_V;
                    camera_rot._m20_m21_m22 = -camera_rot._m20_m21_m22;
                    c = fixed4(hsv2rgb((clamp(camera_rot[iyr][iyc], -0.99, 0.99)+1.0)/2.0, 1, 1), 1);
                }
                return c;
            }
            ENDCG
        }
    }
}
