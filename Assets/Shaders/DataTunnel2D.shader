// Dark "data tunnel" background for URP with the 2D Renderer.
// Flying down an endless square tunnel, drawn in chunky pixels.
Shader "Custom/DataTunnel2D"
{
    Properties
    {
        _BackgroundColor ("Background Color", Color) = (0.005, 0.005, 0.015, 1)
        _RingColor ("Ring Color", Color) = (0.1, 0.55, 0.7, 1)
        _CornerColor ("Corner Beam Color", Color) = (0.6, 0.1, 0.5, 1)
        _BitColor ("Data Bit Color", Color) = (0.3, 0.9, 0.55, 1)
        _GlowColor ("Far Glow Color", Color) = (0.35, 0.15, 0.55, 1)
        _PixelsTall ("Pixel Size (pixels tall)", Float) = 180
        _Aspect ("Width / Height", Float) = 1.8
        _Speed ("Fly Speed", Float) = 0.6
        _RingDensity ("Ring Density", Float) = 4
        _BitAmount ("Data Bits", Range(0, 0.3)) = 0.08
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

            CBUFFER_START(UnityPerMaterial)
                float4 _BackgroundColor;
                float4 _RingColor;
                float4 _CornerColor;
                float4 _BitColor;
                float4 _GlowColor;
                float _PixelsTall;
                float _Aspect;
                float _Speed;
                float _RingDensity;
                float _BitAmount;
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

            float hash21(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Snap to a chunky pixel grid
                float2 res = float2(_PixelsTall * _Aspect, _PixelsTall);
                float2 uv = (floor(IN.uv * res) + 0.5) / res;
                float pixel = 1.0 / _PixelsTall;

                float2 q = (uv - 0.5) * float2(_Aspect, 1.0);
                float r = max(max(abs(q.x), abs(q.y)), 0.002);      // square tunnel
                float z = 1.0 / r;                                  // depth into the tunnel
                float travel = _Time.y * _Speed;

                // Rings rushing toward the camera
                float ringF = frac(z * _RingDensity * 0.25 - travel);
                float pixelZ = pixel / (r * r) * _RingDensity * 0.25;   // how much depth one pixel covers
                float ringDist = min(ringF, 1.0 - ringF) / max(pixelZ, 1e-5);
                float ring = ringDist < 0.8 ? 1.0 : 0.0;
                ring *= saturate(1.0 - pixelZ * 2.0);               // fade rings where they get too dense

                // Neon beams along the four corners
                float corner = abs(abs(q.x) - abs(q.y)) < pixel * 0.9 ? 1.0 : 0.0;

                // Flickering data bits on the walls
                float angle = atan2(q.y, q.x) / 6.2831 + 0.5;
                float2 cellUV = float2(angle * 96.0, z * _RingDensity * 1.5 - travel * 6.0);
                float2 cell = floor(cellUV);
                float2 inCell = frac(cellUV);
                float on = step(1.0 - _BitAmount, hash21(cell + floor(_Time.y * 3.0) * 11.0));
                float box = step(0.25, inCell.x) * step(inCell.x, 0.75) * step(0.3, inCell.y) * step(inCell.y, 0.7);
                float bits = on * box * saturate(1.0 - pixelZ * 1.5) * saturate((0.45 - r) * 6.0);

                // Fog: the far end of the tunnel is dark, with a faint glow in the middle
                float fog = saturate(r * 3.5);
                float glow = exp(-r * 12.0);

                float3 col = _BackgroundColor.rgb;
                col += _RingColor.rgb * ring * fog;
                col += _CornerColor.rgb * corner * fog;
                col += _BitColor.rgb * bits * fog * 0.8;
                col += _GlowColor.rgb * glow * (0.8 + 0.2 * sin(_Time.y * 2.0));

                float vignette = saturate(1.25 - length(IN.uv - 0.5) * 1.1);
                col *= vignette * _Brightness;

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
