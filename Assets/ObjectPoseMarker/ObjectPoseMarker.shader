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
                float4 ScreenPos   : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.ScreenPos = ComputeScreenPos(o.vertex);
                if(abs(60.0 - degrees(atan(1/unity_CameraProjection._m11))*2.0) > 0.01) o.vertex = 0;
                return o;
            };

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;

                //float2 width = float2(1/16*9/16, 1.0/16.0)
                if(ScreenPos.x < 0.03515) {
                    // 16bit = 65536
                    float3 Pos = mul(UNITY_MATRIX_M, float4(0,0,0,1)).xyz;
                    uint3 PosInt = uint3(Pos * 1000 + 32768);
                    int iy = floor(ScreenPos.y * 16.0);
                    c = fixed4(PosInt >> iy & 1, 1);
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
