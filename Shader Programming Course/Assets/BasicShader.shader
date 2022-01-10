Shader "Unlit/BasicShader" { // path (not the asset path)
    Properties { // input data to this shader (per-material)
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1)
        _MainTex ("Main color texture", 2D) = "black" {}
        
        _WaveHeight("Wave height", Float) = 1
        _WaveLength("Wave length", Float) = 1
        _WaveSpeed("Wave speed", Float) = 1
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
            float _WaveHeight;
            float _WaveLength;
            float _WaveSpeed;
            sampler2D _MainTex; 

            // vertex shader - foreach( vertex )
            Interpolators vert ( MeshData v ) {
                Interpolators i;

                
                // modify vertices
                //v.vertex.y += cos(((v.uv0.x+_Time.y*_WaveSpeed))*_WaveLength*UNITY_PI*2)*_WaveHeight;
                
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
                //float4 color = lerp(_ColorA, _ColorB, frac(i.coord.x) );

                i.uv0.y += _Time.y / 5; 

                //By multiplying the texture with a color, the texture tints by that color
                float4 texColor = tex2D( _MainTex, i.uv0) * _ColorB;

                //With saturate we clamp the colorchange between 0 and 1 in worldspace
                float t = saturate(i.worldPos.y); //Mathf.Clamp01()
                
                
                return lerp(_ColorA, texColor, t); 
                
                //return float4(i.uv0,0,1);
            }
            ENDCG
        }
    }
}