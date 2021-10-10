Shader "Custom/CameraPoseMarker" {
    Properties{
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

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.ScreenPos = ComputeScreenPos(o.vertex);
                o.CameraPos = _WorldSpaceCameraPos;
                if(abs(60.0 - degrees(atan(1/unity_CameraProjection._m11))*2.0) > 0.01) o.vertex = 0;
                return o;
            };

            fixed4 pos2rgb(float3 Pos, float ScreenPosY){
                // 16bit = 65536
                uint3 PosInt = uint3(Pos * 1000 + 32768);
                int iy = floor(ScreenPosY * 16.0);
                return fixed4(PosInt >> iy & 1, 1);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;
                float4x4 CameraRot = transpose(UNITY_MATRIX_V);

                //float2 width = float2(1/16*9/16, 1.0/16.0);
                float2 width = float2(0.03515, 0.0625)/2;
                
                if(ScreenPos.x < width.x) {
                    c = pos2rgb(i.CameraPos, ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*2) {
                    c = pos2rgb(CameraRot[0].xyz, ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*3) {
                    c = pos2rgb(CameraRot[1].xyz, ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*4) {
                    c = pos2rgb(CameraRot[2].xyz, ScreenPos.y);
                }
                else {
                    clip(-1);
                }
                return c;
            }
            ENDCG
        }
    }
}