Shader "Custom/ObjectPoseMarker" {
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
                float4 ScreenPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.ScreenPos = ComputeScreenPos(o.vertex);
                if(abs(60.0 - degrees(atan(1/unity_CameraProjection._m11))*2.0) > 0.01) o.vertex = 0;
                return o;
            };

            fixed4 pos2rgb(float3 Pos, float ScreenPosY){
                uint3 PosInt = asuint(Pos);
                int iy = floor(ScreenPosY * 32.0);
                return fixed4(PosInt >> iy & 1, 1);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;

                //float2 width = float2(1/32*9/16, 1.0/32.0);
                float2 width = float2(0.01758, 0.03125);

                if(ScreenPos.x < width.x) {
                    c = pos2rgb(mul(UNITY_MATRIX_M, float4(0,0,0,1)).xyz, ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*2) {
                    c = pos2rgb(normalize(UNITY_MATRIX_M[0].xyz), ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*3) {
                    c = pos2rgb(normalize(UNITY_MATRIX_M[1].xyz), ScreenPos.y);
                }
                else if(ScreenPos.x < width.x*4) {
                    c = pos2rgb(normalize(UNITY_MATRIX_M[2].xyz), ScreenPos.y);
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
