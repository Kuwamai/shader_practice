Shader "Custom/ObjectPoseReader" {
    Properties{
        _Photo ("Texture", 2D) = "white" {}
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

            sampler2D _Photo;

            float3 getTexVal(){
                float2 width = float2(0.03515, 0.0625) / 2.0;
                uint3  PosInt = uint3(0, 0, 0);
                for(int i=0; i<16; i++) {
                    float2 uv = float2(width.x, width.y + width.y * i * 2.0);
                    PosInt += uint3(tex2Dlod(_Photo, float4(uv, 0, 0)).xyz) << i;
                }
                float3 PosFloat = (float3(PosInt) - 32768) / 1000;
                return PosFloat;
            }

            v2f vert(appdata v) {
                v2f o;
                float3 Pos = getTexVal();
                float4x4 mat = float4x4(
                    float4(1, 0, 0, Pos.x),
                    float4(0, 1, 0, Pos.y),
                    float4(0, 0, 1, Pos.z),
                    float4(0, 0, 0, 1));

                o.vertex = mul(mat, v.vertex);
                o.vertex = UnityObjectToClipPos(o.vertex);
                o.uv = v.uv;
                return o;
            };

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_Photo, i.uv);
                return c;
            }
            ENDCG
        }
    }
}