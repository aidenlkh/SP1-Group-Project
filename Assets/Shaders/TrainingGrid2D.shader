// Neon "training room" grid background for URP with the 2D Renderer.
// Same setup as MatrixRain2D: material on a Square sprite, child of the camera.
Shader "Custom/TrainingGrid2D"
{
    Properties
    {
        _GridColor ("Grid Color", Color) = (0.1, 0.8, 1, 1)
        _PulseColor ("Pulse Color", Color) = (1, 0.2, 0.85, 1)
        _BackgroundColor ("Background Color", Color) = (0.01, 0.01, 0.04, 1)
        _GridX ("Cells Across", Float) = 18
        _GridY ("Cells Down", Float) = 10
        _LineWidth ("Line Width (pixels)", Range(0.5, 4)) = 1.2
        _ScrollSpeed ("Scroll Speed", Float) = 0.15
        _PulseSpeed ("Pulse Speed", Float) = 0.25
        _TrailLength ("Pulse Trail Length", Range(0.5, 8)) = 3
        _ScanSpeed ("Scan Band Speed", Float) = 0.12
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
                float4 _GridColor;
                float4 _PulseColor;
                float4 _BackgroundColor;
                float _GridX;
                float _GridY;
                float _LineWidth;
                float _ScrollSpeed;
                float _PulseSpeed;
                float _TrailLength;
                float _ScanSpeed;
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

            float hash11(float p)
            {
                p = frac(p * 0.1031);
                p *= p + 33.33;
                p *= p + p;
                return frac(p);
            }

            // Bright streak travelling along a line, with a fading tail behind it
            float Pulse(float along, float lineId, float lineLength, float offsetSeed)
            {
                float r = hash11(lineId + offsetSeed);
                float active = step(0.55, r);                       // only some lines carry pulses
                float speed = _PulseSpeed * lerp(0.6, 1.6, hash11(lineId * 3.7 + offsetSeed));
                float head = frac(_Time.y * speed + r) * lineLength;
                float dist = head - along;
                if (dist < 0.0) dist += lineLength;                 // wrap around
                float tail = saturate(1.0 - dist / _TrailLength);
                return active * tail * tail;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;
                float2 g = uv * float2(_GridX, _GridY);
                g.y += _Time.y * _ScrollSpeed;                      // slow drift

                float2 fw = max(fwidth(g), 1e-5);

                // Fine grid lines
                float2 f = frac(g);
                float2 dPix = min(f, 1.0 - f) / fw;
                float fine = saturate(1.0 - min(dPix.x, dPix.y) / _LineWidth);

                // Major grid lines every 4 cells
                float2 fm = frac(g / 4.0);
                float2 dmPix = (min(fm, 1.0 - fm) * 4.0) / fw;
                float major = saturate(1.0 - min(dmPix.x, dmPix.y) / (_LineWidth * 1.5));

                // Pulses on horizontal lines (moving sideways) and vertical lines (moving up)
                float rowLine = round(g.y);
                float colLine = round(g.x);
                float nearRow = saturate(1.0 - (abs(g.y - rowLine) / fw.y) / (_LineWidth * 2.0));
                float nearCol = saturate(1.0 - (abs(g.x - colLine) / fw.x) / (_LineWidth * 2.0));
                float pulse = nearRow * Pulse(g.x, rowLine, _GridX, 11.0)
                            + nearCol * Pulse(g.y, colLine, _GridY * 2.0, 57.0);

                // Scan band sweeping down the screen
                float scanPos = 1.0 - frac(_Time.y * _ScanSpeed);
                float band = exp(-abs(uv.y - scanPos) * 30.0);

                // Subtle scanlines and vignette
                float scanlines = 0.92 + 0.08 * sin(uv.y * _GridY * 60.0);
                float vignette = saturate(1.1 - length(uv - 0.5) * 0.9);

                float3 col = _BackgroundColor.rgb;
                col += _GridColor.rgb * (fine * 0.25 + major * 0.55) * (1.0 + band * 2.0);
                col += _GridColor.rgb * band * 0.06;
                col += _PulseColor.rgb * pulse * 1.2;
                col *= scanlines * vignette * _Brightness;

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
