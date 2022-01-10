Shader "Unlit/BasicShader" { // path (not the asset path)
    Properties { // input data to this shader (per-material)
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags { 
            "RenderType"="Opaque" 
            "Queue"="Geometry" // render order
        }

        Pass {
            // render setup
            // ZTest On
            // ZWrite On
            // Blend x y 
            
            CGPROGRAM

            // what functions to use for what
            #pragma vertex vert
            #pragma fragment frag

            // bunch of unity utility functions and variables
            #include "UnityCG.cginc"

            // per-vertex input data from the mesh
            struct MeshData {
                float3 vertex : POSITION;  // vertex position
                float3 normal : NORMAL;
                float4 tangent : TANGENT; // xyz = tangent direction, w = flip sign -1 or 1
                float2 uv0 : TEXCOORD0;    // uv channel 0
                // float2 uv1 : TEXCOORD1;     // uv channel 1
                // float4 uv2 : TEXCOORD2;     // uv channel 2
                // float4 uv3 : TEXCOORD3;     // uv channel 3
            };

            // the struct for sending data from the vertex shader to the fragment shader
            struct Interpolators {
                float4 vertex : SV_POSITION; // clip space vertex position
                // arbitrary data we want to send:
                float2 uv : TEXCOORD0;
                // float4 name : TEXCOORD1;
                // float4 name : TEXCOORD2;
            };

            // property variable declaration
            float4 _Color = (1, 0, 1, 1);

            // vertex shader - foreach( vertex )
            Interpolators vert ( MeshData v ) {
                Interpolators o;

                // transforms from local space to clip space
                // usually using the matrix called UNITY_MATRIX_MVP
                // model-view-projection matrix (local to clip space)
                o.vertex = UnityObjectToClipPos(v.vertex);

                // pass coordinates to the fragment shader
                o.uv = v.uv0;
                
                return o;
            }

            // fragment shader - foreach( fragment/pixel )
            float4 frag (Interpolators i) : SV_Target {
                float2 coords = i.uv.x;
                float time = _Time.y; // current time in seconds
                //frac(x) = x - floor(x)
                return float4(frac(coords - time), .75, 1 ); // cast to float4 since that's the output type
            }
            ENDCG
        }
    }
}