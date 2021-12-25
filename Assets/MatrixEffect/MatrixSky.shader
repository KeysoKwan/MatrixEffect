Shader "Matrix/MatrixSky"
{
    Properties {
        _FontTexture ("FontTexture", 2D) = "white" {}
       _Scale("ScaleX",int) = 1920 
    }

    SubShader {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "/Shaders/XNoiseLibrary.hlsl"

        sampler2D _FontTexture;
        uint _Scale;

        float text(float2 coord)
        {
            float2 uv    = frac (coord.xy/ 16.);                // Geting the fract part of the block, this is the uv map for the blocl
            float2 block = floor(coord.xy/ 16.);                // Getting the id for the block. The first blocl is (0,0) to its right (1,0), and above it (0,1) 
            uv = uv * 0.7 + .1;                       // Zooming a bit in each block to have larger ltters

            float2 rand = float2(snoise(((1420 +_Time.y) * block.xy)/float2(512.,512.)),
                                 cnoise((_Time.z * block.xy)/float2(512.,512.)));

            rand  = floor(rand * 16.);                     // Each random value is used for the block to sample one of the 16 columns of the font texture. This rand offset is what picks the letter, the animated white noise is what changes it
            uv += rand;                                // The random texture has a different value und the xy channels. This ensures that randomly one member of the texture is picked 

            uv *= 0.0625;                              // So far the uv value is between 0-16. To sample the font texture we need to normalize this to 0-1. hence a divid by 16
            uv.x = -uv.x;
            return tex2D(_FontTexture, uv).r;
        }

        float3 rain(float2 fragCoord)
        {
            fragCoord.x  = floor(fragCoord.x/ 16.);             // This is the exact replica of the calculation in text function for getting the cell ids. Here we want the id for the columns 

            float offset = sin (fragCoord.x*15.);               // Each drop of rain needs to start at a different point. The column id  plus a sin is used to generate a different offset for each columm
            float speed  = cos (fragCoord.x*3.)*.15 + .35;      // Same as above, but for speed. Since we dont want the columns travelling up, we are adding the 0.7. Since the cos *0.3 goes between -0.3 and 0.3 the 0.7 ensures that the speed goes between 0.4 mad 1.0. This is also control parameters for min and max speed
            float y      = frac((fragCoord.y / _Scale)         // This maps the screen again so that top is 1 and button is 0. The addition with time and frac would cause an entire bar moving from button to top
                                          + _Time.y * speed + offset);   // the speed and offset would cause the columns to move down at different speeds. Which causes the rain drop effect

            return float3(.1, 1., .35) / (y*20.);               // adjusting the retun color based on the columns calculations. 
        }

        float3 RotateAroundYInDegrees (float3 vertex, float degrees)
        {
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float3(mul(m, vertex.xz), vertex.y).xzy;
        }

        struct appdata_t {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };
        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
        };
        v2f vert (appdata_t v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

            float3 rotated = RotateAroundYInDegrees(v.vertex, 180);
            o.vertex = UnityObjectToClipPos(rotated);
            o.uv = v.texcoord;
            return o;
        }

#define scale 0.6
        half4 skybox_frag (v2f i, sampler2D smp, half4 smpDecode)
        {
            fixed4 col     = float4(0.,0.,0.,1.);
            col.xyz = text(i.uv * float2(_Scale, _Scale) * scale) *
                      rain(i.uv * float2(_Scale, _Scale) * scale);

            return col;
        }
        ENDCG

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _FrontTex;
            half4 _FrontTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_FrontTex, _FrontTex_HDR); }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _BackTex;
            half4 _BackTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_BackTex, _BackTex_HDR); }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _LeftTex;
            half4 _LeftTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_LeftTex, _LeftTex_HDR); }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _RightTex;
            half4 _RightTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_RightTex, _RightTex_HDR); }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _UpTex;
            half4 _UpTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_UpTex, _UpTex_HDR); }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            sampler2D _DownTex;
            half4 _DownTex_HDR;
            half4 frag (v2f i) : SV_Target { return skybox_frag(i,_DownTex, _DownTex_HDR); }
            ENDCG
        }
    }
}
