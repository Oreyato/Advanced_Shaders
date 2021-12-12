Shader "Unlit/VertAnimNormal"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}

        _Frequency("Frequency",  Range(0, 20)) = 1
        _Amplitude("Amplitude",  Range(0, 20)) = 1
        _Speed("Speed",  Range(0, 20)) = 1
    } 
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        Tags { 
            "Order" = "Transparent"
            "RenderType" = "Transparent" 
            "IgnoreProjector" = "True"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform float4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

            uniform float _Frequency;
            uniform float _Amplitude;
            uniform float _Speed;

            struct VertexInput {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos: SV_POSITION;
                float4 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            float4 VertexAnimNormal(float4 vertPos, float4 vertNormal, float2 uv){
                vertPos += sin((uv.x - _Time.y * _Speed) * _Frequency) * _Amplitude * vertNormal;

                return vertPos;
            }

            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                v.vertex = VertexAnimNormal(v.vertex, v.normal,v.texcoord);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw = 0;
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;

                return color;
            }

            ENDCG
        }
    }
}
