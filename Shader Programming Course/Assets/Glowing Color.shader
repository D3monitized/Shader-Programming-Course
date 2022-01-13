Shader "Unlit/Glowing Color"
{
    Properties
    {
        _ColorA("ColorA", Color) = (1,1,1,1)
        _ColorB("ColorB", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "Black" {}
        _Frequency("Frequency", Range(1, 50)) = 1
        _Gloss("Gloss", Range(2, 2048)) = 1
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
                float3 normal : TEXCOORD2; 
                float3 worldPosition : TEXCOORD1; 
            };

            float4 _MainTex_ST;
            float4 _ColorA;
            float4 _ColorB;
            float _Frequency;
            float _Gloss;
            sampler2D _MainTex; 

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                 o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(UNITY_MATRIX_M, float4(v.vertex));
                o.uv = v.uv; 
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);

                float3 lightDir = UnityWorldSpaceLightDir(i.worldPosition);
                float lighting = saturate(dot(i.normal, lightDir)); 
                
                float t = (frac(sin(_Time.y * _Frequency) * .5f + .5f));
                float3 color = lerp(_ColorA, _ColorB, t);
                float3 surfaceColor = tex2D(_MainTex, i.uv);
                color *= surfaceColor;
                
                float3 lightColor = _LightColor0;
                float3 diffuse = lightColor * color;

                float3 view = normalize(_WorldSpaceCameraPos - i.worldPosition);
                float3 reflectedLight = reflect(-lightDir, i.normal); 
                float3 h = normalize(reflectedLight + view);
                float specularLighting = pow(max(0, dot(view, reflectedLight)), _Gloss) * lightColor; 
                
                return float4(diffuse * lighting + specularLighting, 1);
            }
            ENDCG
        }
    }
}