Shader "Custom/Damage Shader" {
    Properties{
        _MainTex("Txture", 2D) = "white" {}
        _Alpha("Alpha" , Float) = 1
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

            #define COLORS 32.0

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

            sampler2D _MainTex;
            float _Alpha;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 suv = ((i.ScreenPos.xy) / i.ScreenPos.w);
                fixed4 col = saturate(tex2D(_MainTex, suv));
                fixed4 c = fixed4(col.rgb, col.a* _Alpha);
                return c;
            }
            ENDCG
        }
    }
}
