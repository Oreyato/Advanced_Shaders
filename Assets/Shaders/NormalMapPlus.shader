Shader "Unlit/NormalMapPlus"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
        [KeywordEnum(Off, On)] _UseNormal("Use Normal Map?", Float) = 0
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
            #pragma shader_feature _USENORMAL_OFF _USENORMAL_ON
                //  ^ will make Unity compile only shader variants for which an option is selected
                //    can be replaced with "multi_compile" that will make Unity compile all variants of shaders

            #include "UnityCG.cginc"
            #include "PracticeLightning.cginc"

            uniform float4 _Color;
            uniform sampler2D _MainTex;
            uniform sampler2D _NormalMap;
            uniform float4 _MainTex_ST;
            uniform float4 _NormalMap_ST;

            struct VertexInput {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float4 texcoord: TEXCOORD0;

                #if _USENORMAL_ON
                float4 tangent: TANGENT;
                #endif
            };

            struct VertexOutput {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
                float4 normalWorld: TEXCOORD1;

                #if _USENORMAL_ON
                float4 tangentWorld: TEXCOORD2;
                float3 binormalWorld: TEXCOORD3; // Binormal is orthogonal to the normal in the direction of U
                    //                             (where U and V forms the ref plane)                                                           
                float4 normalTexCoord: TEXCOORD4;
                #endif
            };

            VertexOutput vert(VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.zw = 0;
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

                #if _USENORMAL_ON
                o.normalTexCoord.zw = 0;
                o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));
                o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent));
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);
                
                #else
                o.normalWorld = float4(UnityObjectToWorldNormal(v.normal), 1);
                #endif

                return o;
            }

            // float3 normalFromColor(float4 color) {
            //     #if defined(UNITY_NO_DXT5nm)
            //     return color.xyz;

            //     #else
            //     // In this case, R channel is alpha
            //     float3 normal = float3(color.a, color.g, 0.0);
            //     normal.z = sqrt(1 - dot(normal, normal));
                
            //     return normal;
            //     #endif
            // }

            // float3 WorldNormalFromNormalMap(sampler2D normalMap, float2 normalTexCoord, float3 tangentWorld, float3 binormalWorld, float3 normalWorld) {
            //     // Color at Pixel which we read from Tangent space normal map
            //     float4 colorAtPixel = tex2D(normalMap, normalTexCoord);

            //     // Normal value converted from Color value
            //     float3 normalAtPixel = normalFromColor(colorAtPixel);

            //     // Compose TBN matrix 
            //     float3x3 TBNWorld = float3x3(tangentWorld, binormalWorld, normalWorld);

            //     return normalize(mul(normalAtPixel, TBNWorld));
            // }

            half4 frag (VertexOutput i) : COLOR
            {
                #if _USENORMAL_ON
                float3 worldNormalAtPixel = WorldNormalFromNormalMap(_NormalMap, i.normalTexCoord.xy, i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);

                return float4(worldNormalAtPixel, 1);

                #else
                return float4(i.normalWorld.xyz, 1);
                #endif
            }

            ENDCG
        }
    }
}
