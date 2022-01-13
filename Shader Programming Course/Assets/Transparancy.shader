Shader "Unlit/Transparancy"
{
   
    Properties {
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1) 
        _MainTex ("Base Color", 2D) = "black" {}
        _ClipThreshold ("Clip Threshold", Range(0.0001,1)) = 0.5
    }
    SubShader {
        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent" // draw order in render pipeline
        }
        Pass {
            
            Cull Off // don't cull front or back (double-sided rendering)
            ZWrite Off // turn off writing to the depth buffer
            Blend One One // alpha blending
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData {
                float3 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _ClipThreshold;
            float4 _ColorA;
            float4 _ColorB; 

            Interpolators vert( MeshData v ) {
                Interpolators i;
                i.vertex = UnityObjectToClipPos(v.vertex);
                i.uv = v.uv0;
                return i;
            }
            
            float4 frag( Interpolators i ) : SV_Target {
                float4 baseColor = tex2D( _MainTex, i.uv );
                float t = sin(frac(_Time.y)); 
                
                return baseColor * lerp(_ColorA, _ColorB, t);
            }
            ENDCG
        }
    }
}

