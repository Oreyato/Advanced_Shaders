Shader "Unlit/Bokeh"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Intersect("Intersect (0 for no, else for yes)", Range(0, 1)) = 0
        _IsCircle("Is a circle (0 for no, else for yes)", Range(0, 1)) = 0
        _Center("Center", float) = 0.5
        _Radius("Radius", float) = 0.5
        _Feather("Fading edge",  Range(0, 0.5)) = 0.05
        _Speed("Speed",  Range(0, 20)) = 1
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

            uniform float _Intersect;
            uniform float _IsCircle;
            uniform float _Center;
            uniform float _Radius;
            uniform float _Feather;
            uniform float _Speed;

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
            
            float2 Smoothstep(float lower, float higher, float value) {
                float result;
                result = clamp((value - lower) / (higher - lower), 0.0, 1.0);

                return result * result * (3.0 - 2.0 * result);
            };

            float drawCircleAnimate(float2 uv, float2 center, float radius, float feather){
                float circle = pow((uv.y - center.y), 2) + pow((uv.x - center.x), 2);
                float radiusSquare = pow(radius, 2);

                // If I want to draw a circle instead of a disk
                if (_IsCircle != 0) {
                    if ((circle < radiusSquare + 0.01) && (circle > radiusSquare - 0.01)) {
                        if (_Intersect == 0) {
                            float fade = abs(sin(_Time.y * _Speed)); 
                            return smoothstep(radiusSquare, radiusSquare - feather, circle) * fade;
                        } 
                        else if (_Intersect != 0) {
                            float fade = abs(sin(_Time.y * _Speed)); 
                            return smoothstep(radiusSquare, radiusSquare - feather, circle) * fade;
                        }                   
                    }
                }
                else {
                    if (circle < radiusSquare) {
                        if (_Intersect == 0) {
                            float fade = abs(sin(_Time.y * _Speed)); 
                            return smoothstep(radiusSquare, radiusSquare - feather, circle) * fade;
                        } 
                        else if (_Intersect != 0) {
                            float fade = abs(sin(_Time.y * _Speed)); 
                            return smoothstep(radiusSquare, radiusSquare - feather, circle) * fade;
                        }                   
                    }
                }
                return 0;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.texcoord) * _Color;
                color.a = drawCircleAnimate(i.texcoord.xy, _Center, _Radius, _Feather);
                return color;
            }

            ENDCG
        }
    }
}
