// Animated parallax city: six layers scrolling at different speeds.
// URP 2D Renderer. Same setup as your other background materials.
Shader "Custom/ParallaxCity2D"
{
    Properties
    {
        _Layer1 ("Layer 1 (sky, farthest)", 2D) = "black" {}
        _Layer2 ("Layer 2", 2D) = "black" {}
        _Layer3 ("Layer 3", 2D) = "black" {}
        _Layer4 ("Layer 4", 2D) = "black" {}
        _Layer5 ("Layer 5", 2D) = "black" {}
        _Layer6 ("Layer 6 (front, closest)", 2D) = "black" {}

        _Speed1 ("Speed 1", Float) = 0.003
        _Speed2 ("Speed 2", Float) = 0.008
        _Speed3 ("Speed 3", Float) = 0.016
        _Speed4 ("Speed 4", Float) = 0.028
        _Speed5 ("Speed 5", Float) = 0.045
        _Speed6 ("Speed 6", Float) = 0.07

        _Aspect ("Width / Height", Float) = 1.78
        _Brightness ("Brightness", Range(0, 2)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off

        Pass
        {
            Tags { "LightMode"="Universal2D" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_Layer1);
            TEXTURE2D(_Layer2);
            TEXTURE2D(_Layer3);
            TEXTURE2D(_Layer4);
            TEXTURE2D(_Layer5);
            TEXTURE2D(_Layer6);
            // Crisp pixels that repeat sideways, whatever the texture import settings are
            SAMPLER(sampler_point_repeat);

            CBUFFER_START(UnityPerMaterial)
                float _Speed1;
                float _Speed2;
                float _Speed3;
                float _Speed4;
                float _Speed5;
                float _Speed6;
                float _Aspect;
                float _Brightness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 Layer(TEXTURE2D_PARAM(tex, samp), float2 uv, float speed)
            {
                float2 p = float2(uv.x + _Time.y * speed, saturate(uv.y));
                return SAMPLE_TEXTURE2D(tex, samp, p);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Keep the images at their original shape (576 x 324 = 1.78) on any screen
                float2 uv = float2(IN.uv.x * (_Aspect / 1.7778), IN.uv.y);

                float3 col = Layer(TEXTURE2D_ARGS(_Layer1, sampler_point_repeat), uv, _Speed1).rgb;

                float4 l2 = Layer(TEXTURE2D_ARGS(_Layer2, sampler_point_repeat), uv, _Speed2);
                col = lerp(col, l2.rgb, l2.a);
                float4 l3 = Layer(TEXTURE2D_ARGS(_Layer3, sampler_point_repeat), uv, _Speed3);
                col = lerp(col, l3.rgb, l3.a);
                float4 l4 = Layer(TEXTURE2D_ARGS(_Layer4, sampler_point_repeat), uv, _Speed4);
                col = lerp(col, l4.rgb, l4.a);
                float4 l5 = Layer(TEXTURE2D_ARGS(_Layer5, sampler_point_repeat), uv, _Speed5);
                col = lerp(col, l5.rgb, l5.a);
                float4 l6 = Layer(TEXTURE2D_ARGS(_Layer6, sampler_point_repeat), uv, _Speed6);
                col = lerp(col, l6.rgb, l6.a);

                return half4(col * _Brightness, 1.0);
            }
            ENDHLSL
        }
    }
}
