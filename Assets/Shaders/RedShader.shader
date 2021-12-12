Shader "Unlit/RedShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM // Starts program - Nvidia CGLanguage 
            #pragma vertex vert // Shader compilation info
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata // Informations that comes from the app to the vertex shader
            {
                float4 vertex : POSITION;
            };

            struct v2f // Vertex to Fragment shader
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;

            v2f vert (appdata v) // vert from #pragma
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target // frag from #pragma
            {
                // sample the texture
                return _Color;
            }
            ENDCG // Ends program
        }
    }
}