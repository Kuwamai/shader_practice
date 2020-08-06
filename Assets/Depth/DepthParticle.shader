Shader "Unlit/star_particle"
{
    Properties
    {
        _Depth ("Depth", 2D) = "white" {}
        _Col ("Color", 2D) = "white" {}
        _Size ("Size", Range(0, 0.1)) = 0.01
        _XLim ("X-limit", Float) = 0.0
        _YLim ("Y-limit", Float) = 0.0
        _ZLim ("Z-limit", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 color : TEXCOORD1;
            };
            
            sampler2D _Depth;
            sampler2D _Col;
            float _Size;
            float _XLim;
            float _YLim;
            float _ZLim;
            
            appdata vert (appdata v)
            {
                return v;
            }
            
            [maxvertexcount(3)]
            void geom(triangle appdata IN[3], inout TriangleStream<v2f> stream) {
                float2 uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;
                uv.x = (floor(uv.x * 512) + 0.5) / 512.0;
                uv.y = (floor(uv.y * 512) + 0.5) / 512.0;
                
                float3 p = float3((uv.x - 0.5) * _XLim, (uv.y - 0.5) * _YLim, tex2Dlod(_Depth, float4(uv,0,0)).x * _ZLim);
                float3 c = tex2Dlod(_Col, float4(uv,0,0)).xyz;
                if(length(p) < 0.1 && length(c) < 0.1) return;
                
                float sz = _Size;
                //VRモードだと2回処理が走って描画サイズが倍になる
                //VR以外のカメラのとき、描画サイズを倍にすることで対処
                if (abs(UNITY_MATRIX_P[0][2]) < 0.0001) sz *= 2;

                sz *= pow(determinant((float3x3)UNITY_MATRIX_M),1/3.0);
                float aspectRatio = - UNITY_MATRIX_P[0][0] / UNITY_MATRIX_P[1][1];
                v2f o;
                float4 vp1 = UnityObjectToClipPos(float4(p, 1));
                
                o.color = c;
                o.uv = float2(0,1);
                o.vertex = vp1+float4(o.uv*sz*float2(aspectRatio,1),0,0);
                stream.Append(o);
                o.uv = float2(-0.9,-0.5);
                o.vertex = vp1+float4(o.uv*sz*float2(aspectRatio,1),0,0);
                stream.Append(o);
                o.uv = float2(0.9,-0.5);
                o.vertex = vp1+float4(o.uv*sz*float2(aspectRatio,1),0,0);
                stream.Append(o);
                stream.RestartStrip();
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float l = length(i.uv);
                clip(0.5-l);
                return float4(i.color,1);
            }
            ENDCG
        }
    }
}