Shader "Unlit/Assets/BlinkShader.shader" { // path (not the asset path)
    Properties { // input data to this shader (per-material)
        _ColorA ("Color A", Color) = (0,0,0,0)
        _ColorB ("Color B", Color) = (1,1,1,1)       
        _Frequency ("Blink Speed", Float) = 1 
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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv0 : TEXCOORD2;
                // float4 name : TEXCOORD2;
            };

            // property variable declaration
            float4 _ColorA;
            float4 _ColorB;           
            float _Frequency; 
          

            // vertex shader - foreach( vertex )
            Interpolators vert ( MeshData v ) {
                Interpolators i;               
                
                // transforms from local space to clip space
                // usually using the matrix called UNITY_MATRIX_MVP
                // model-view-projection matrix (local to clip space)
                i.vertex = UnityObjectToClipPos(v.vertex);

                // pass coordinates to the fragment shader
                i.worldNormal = UnityObjectToWorldNormal( v.normal );
                i.worldPos = mul( UNITY_MATRIX_M, float4( v.vertex, 1 ) ); // world space
                i.uv0 = v.uv0; // world space
                
                //o.coord = v.uv0.x*8 + _Time.y;
                return i;
            }

           

            // fragment shader - foreach( fragment/pixel )
            float4 frag (Interpolators i) : SV_Target {

              
                //Blinking shader with adjustable frequency                
                float time = _Time.y;
                float tau = 6.28318530f;
                float t = sin(time * tau * _Frequency) * .5f + .5f;
                
                return lerp(_ColorA, _ColorB, t);

                
            }
            ENDCG
        }
    }
}