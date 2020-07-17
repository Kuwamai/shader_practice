Shader "Custom/Damage Shader" {
    Properties{
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
                float4 Vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.Vertex = UnityObjectToClipPos(v.Vertex);
                o.ScreenPos = ComputeScreenPos(o.Vertex);
                return o;
            };

            float sdBox(float2 p, float2 s){
                float2 d = abs(p) - s;
                return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                float2 ScreenPos = i.ScreenPos.xy / i.ScreenPos.w;
                float2 width = float2(0.0938, 0.1667);
                //float2 width = float2(1/6*9/16, 1.0/6.0);

                if(ScreenPos.x < 0.0938 && ScreenPos.y < width.y) {
                    c = fixed4(0, 1, 0, 1);
                }
                else if(ScreenPos.x < width.x && ScreenPos.y < width.y*2.0) {
                    c = fixed4(1, 1, 0, 1);
                }
                else if(ScreenPos.x < width.x && ScreenPos.y < width.y*3.0) {
                    c = fixed4(1, 1, 1, 1);
                }
                else if(ScreenPos.x < width.x && ScreenPos.y < width.y*4.0) {
                    c = fixed4(0, 0, 1, 1);
                }
                else if(ScreenPos.x < width.x && ScreenPos.y < width.y*5.0) {
                    c = fixed4(1, 0, 1, 1);
                }
                else if(ScreenPos.x < width.x && ScreenPos.y < 1.0) {
                    c = fixed4(1, 0, 0, 1);
                } else {
                    c = fixed4(0, 0, 0, 0);
                }
                return c;
            }
            ENDCG
        }
    }
}
