Shader "Unlit/SnowOnRock"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "black" {}
        _SnowTex ("Snow Texture", 2D) = "black" {}
        _CullThresh("Culling Threshold", Range(0,1)) = 0
        _FadeStart("Fade Start", Range(0,1)) = 0
        _FadeEnd("Fade End", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 localPos : TEXCOORD2; 
                float3 normal : TEXCOORD3; 
            };

            sampler2D _MainTex;
            sampler2D _SnowTex; 
            float4 _MainTex_ST;
            float _FadeStart;
            float _FadeEnd;
            float _CullThresh;

            Interpolators vert (MeshData v)
            {
                Interpolators i;
                i.vertex = UnityObjectToClipPos(v.vertex);                
                i.uv = v.uv;
                i.localPos = v.vertex;
                i.normal = UnityObjectToWorldNormal(v.normal); 
                UNITY_TRANSFER_FOG(o,o.vertex);
                return i;
            }

            //v = lerp(a,b,t)
            //t = ilerp(a,b,v)
            
            float InvLerp(float a, float b, float v)
            {
                return(v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // sample the texture
                //return float4(i.worldPos, 1);

                float t = InvLerp(_FadeStart, _FadeEnd, i.normal.y);
                 //Saturate => Clamp01
                t = saturate(t);               
                
                float4 baseColor = tex2D( _MainTex, i.uv);
                float4 topColor = tex2D( _SnowTex, i.worldPos);   
                
                clip(baseColor - _CullThresh);
                              
                return lerp(baseColor, topColor, t);
            }
            ENDCG
        }
    }
}
