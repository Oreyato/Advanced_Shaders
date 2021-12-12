Shader "Unlit/Start"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform float4 _Color;

            #include "UnityCG.cginc"

            struct VertexInput {
                float4 vertex: POSITION;
            };

            struct VertexOutput {
                float4 pos: SV_POSITION;
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                return _Color;
            }
            ENDCG
        }
    }
}
