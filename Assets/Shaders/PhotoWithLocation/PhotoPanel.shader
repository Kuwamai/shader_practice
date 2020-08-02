﻿Shader "Unlit/PhotoPanel" {
    Properties{
        _Photo ("Texture", 2D) = "white" {}
        _XLim ("X-limit", Float) = 0.0
        _YLim ("Y-limit", Float) = 0.0
        _ZLim ("Z-limit", Float) = 0.0
    }
    SubShader{
        //Tags { "RenderType" = "Transparent" "Queue" = "Transparent+2" }
        //LOD 200
        //Cull Off

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
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 ScreenPos   : TEXCOORD1;
                float3 CameraPos   : TEXCOORD2;
                float4 Vertex : SV_POSITION;
            };

            float _XLim;
            float _YLim;
            float _ZLim;
            sampler2D _Photo;
            float4 _Photo_ST;

            float3 rgb2hsv(float3 c){
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float getTexVal(float n){
                float2 width = float2(0.0469, 0.0833) / 2.0;
                float e = 1.0e-10;
                return rgb2hsv(tex2Dlod(_Photo, float4(width.x, width.y + width.y * n * 2.0, 0, 0)).xyz).x * 2.0 - 1.0;
            }

            v2f vert(appdata v) {
                v2f o;
                /*
                float4x4 mat = float4x4(
                    float4(getTexVal(8.0), -getTexVal(5.0), -getTexVal(2.0), getTexVal(11.0) * _XLim / 2.0),
                    float4(-getTexVal(7.0), getTexVal(4.0), -getTexVal(1.0), getTexVal(10.0) * _YLim / 2.0),
                    float4(-getTexVal(6.0), -getTexVal(3.0), getTexVal(0.0), getTexVal(9.0)  * _ZLim / 2.0),
                    float4(0, 0, 0, 1));
                //tashikanihidaritekeidawakore
                float4x4 mat = float4x4(
                    float4(getTexVal(8.0), getTexVal(7.0), getTexVal(6.0), getTexVal(11.0) * _XLim / 2.0),
                    float4(getTexVal(5.0), getTexVal(4.0), getTexVal(3.0), getTexVal(10.0) * _YLim / 2.0),
                    float4(getTexVal(2.0), getTexVal(1.0), getTexVal(0.0), getTexVal(9.0)  * _ZLim / 2.0),
                    float4(0, 0, 0, 1));
                */
                float4x4 mat = float4x4(
                    float4(getTexVal(8.0), getTexVal(5.0), getTexVal(2.0), getTexVal(11.0) * _XLim / 2.0),
                    float4(getTexVal(7.0), getTexVal(4.0), getTexVal(1.0), getTexVal(10.0) * _YLim / 2.0),
                    float4(getTexVal(6.0), getTexVal(3.0), getTexVal(0.0), getTexVal(9.0)  * _ZLim / 2.0),
                    float4(0, 0, 0, 1));
                //o.Vertex = mul(v.Vertex, mat);
                o.Vertex = mul(mat, v.Vertex);
                //o.Vertex.xyz = o.Vertex.xyz + mul(mat, float4(0, 0, 0 ,1)).xyz;
                o.Vertex = UnityObjectToClipPos(o.Vertex);
                o.ScreenPos = ComputeScreenPos(o.Vertex);
                o.CameraPos = _WorldSpaceCameraPos;
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