Shader "Unlit/Smoothstep"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _LowerValue("Lower Value", float) = 0
        _HigherValue("Higher Value", float) = 1
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
            uniform float _LowerValue;
            uniform float _HigherValue;

            struct VertexInput {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            float2 Smoothstep(float lower, float higher, float value) {
                float result;
                result = clamp((value - lower) / (higher - lower), 0.0, 1.0);

                return result * result * (3.0 - 2.0 * result);
            };
 
            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw = 0;
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;
                color.a = Smoothstep(_LowerValue, _HigherValue, i.texcoord.x);

                return color;
            }

            ENDCG
        }
    }
}
