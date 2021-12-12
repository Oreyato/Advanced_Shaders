Shader "Unlit/Line"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Start("Start", float) = 0.4
        _End("End", float) = 0.6
        _Test("Intersect (0 for no, else for yes)", float) = 0
    }
    SubShader
    {
        Tags { 
            "Order" = "Transparent"
            "RenderType" = "Transparent" 
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform float4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Start;
            uniform float _End;
            uniform float _Test;

            struct VertexInput {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw = 0;
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            float drawLine(float2 uv, float start, float end){
                if (uv.x > start && uv.x < end) {
                    if (_Test == 0) {
                        return 1;
                    } 
                    else if (_Test != 0 && (uv.y > _Start && uv.y < _End)) {
                        return 1;
                    }                   
                }
                return 0;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;
                color.a = drawLine(i.texcoord.xy, _Start, _End);
                return color;
            }

            ENDCG
        }
    }
}
