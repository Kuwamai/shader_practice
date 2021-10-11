Shader "Custom/CameraPoseReader" {
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        //16/9=1.777
        _AspectRatio ("Aspect ratio", Float) = 1.777
        _Size ("Size", Float) = 1
    }
    SubShader{
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
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _AspectRatio;
            float _Size;

            float3 getTexVal(int ix){
                //float2 width = float2(1/32*9/16, 1.0/32.0);
                float2 width = float2(0.01758, 0.03125) / 2.0;

                uint3  PosInt = uint3(0, 0, 0);
                for(int iy=0; iy<32; iy++) {
                    float2 uv = float2(width.x + width.x * ix * 2.0, width.y + width.y * iy * 2.0);
                    PosInt += uint3(tex2Dlod(_MainTex, float4(uv, 0, 0)).xyz) << iy;
                }
                float3 PosFloat = asfloat(PosInt);
                return PosFloat;
            }

            v2f vert(appdata v) {
                v2f o;
                float3 Pos = getTexVal(0);
                float4x4 mat = float4x4(
                    float4(getTexVal(1), Pos.x),
                    float4(getTexVal(2), Pos.y),
                    float4(getTexVal(3), Pos.z),
                    float4(0, 0, 0, 1));

                v.vertex.x *= _AspectRatio;
                v.vertex *= _Size;

                o.vertex = mul(mat, v.vertex);
                o.vertex = UnityObjectToClipPos(o.vertex);
                o.uv = v.uv;
                return o;
            };

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                return c;
            }
            ENDCG
        }
    }
}