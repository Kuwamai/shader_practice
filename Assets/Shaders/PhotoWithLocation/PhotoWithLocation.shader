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

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c;
                if(i.ScreenPos.x / i.ScreenPos.w < 0.1) {
                    c = fixed4(1, 1, 0, 1);
                }
                else {
                    c = fixed4(0, 0, 0, 0);
                }
                return c;
            }
            ENDCG
        }
    }
}
