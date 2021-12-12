Shader "Unlit/BasicLightning"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
        [KeywordEnum(Off, On)] _UseNormal("Use Normal Map?", Float) = 0
        _Diffuse("Diffuse %", Range(0, 100)) = 10
        [KeywordEnum(Off, Vert, Frag)] _Lightning("Lightning Mode", Float) = 0
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

            #pragma shader_feature _LIGHTNING_OFF _LIGHTNING_VERT _LIGHTNING_FRAG

            #include "UnityCG.cginc"
            #include "PracticeLightning.cginc"

            uniform float4 _Color;
            uniform sampler2D _MainTex;
            uniform sampler2D _NormalMap;
            uniform float4 _MainTex_ST;
            uniform float4 _NormalMap_ST;
            uniform float _Diffuse;
            uniform float4 _LightColor0;

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

                #if _LIGHTNING_VERT
                float4 surfaceColor: COLOR0;
                #endif
            };

            float3 LambertDiffuse(float3 normal, float3 lightDir, float3 lightColor, float diffuseFactor, float attenuation) {
                return lightColor * diffuseFactor * attenuation * max(0, dot(normal, lightDir));
            }

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

                #if _LIGHTNING_VERT
                float3 dirLight = normalize(_WorldSpaceLightPos0);
                float3 lightColor = _LightColor0.xyz;
                float attenuation = 1;
                o.surfaceColor = float4(LambertDiffuse(o.normalWorld, lightDir, lightColor, _Diffuse, attenuation), 1.0);
               
                #endif 

                return o;
            }

            half4 frag (VertexOutput i) : COLOR
            {
                #if _USENORMAL_ON
                float3 worldNormalAtPixel = WorldNormalFromNormalMap(_NormalMap, i.normalTexCoord.xy, i.tangentWorld.xyz, i.binormalWorld.xyz, i.normalWorld.xyz);
                
                #else
                float3 worldNormalAtPixel = i.normalWorld.xyz;
                
                #endif

                #if _LIGHTNING_FRAG
                float3 dirLight = normalize(_WorldSpaceLightPos0);
                float3 lightColor = _LightColor0.xyz;
                float attenuation = 1;
                return float4(LambertDiffuse(o.normalWorld, lightDir, lightColor, _Diffuse, attenuation), 1.0);
                
                #elif _LIGHTNING_VERT
                return i.surfaceColor;

                #else
                return float4(worldNormalAtPixel, 1);
                
                #endif
            }

            ENDCG
        }
    }
}
