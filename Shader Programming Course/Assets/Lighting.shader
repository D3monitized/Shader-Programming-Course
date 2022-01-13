Shader "Unlit/Lighting"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(2, 2048)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXTCOORD2;
                float3 worldPos : TEXCOORD1;
                
            };

            float4 _Color;
            float4 _MainTex_ST;
            sampler2D _MainTex;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex));
                o.uv = v.uv; 
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.normal = normalize(i.normal); 
                
                //Diffuse Lighting                
                float3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
                float lighting = saturate(dot(i.normal, lightDir));

                float3 surfaceColor = tex2D(_MainTex, i.uv);
                float3 lightColor = _LightColor0;
                float3 diffuse = lighting * lightColor;

                //Specular Lighting
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectedLight = reflect(-lightDir, i.normal);
                float3 h = normalize(view + reflectedLight); 
                float specularLighting = pow(max(0, dot(view, reflectedLight)), _Gloss) * lightColor; 
                
                
                
                return float4(surfaceColor * diffuse + specularLighting, 1);
            }
            ENDCG
        }
    }
}