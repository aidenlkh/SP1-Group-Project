// Neuromancer-style cyberspace background for URP with the 2D Renderer.
// Same setup as your other background shaders.
Shader "Custom/Cyberspace2D"
{
    Properties
    {
        _GridColor ("Grid Color", Color) = (0.1, 1, 0.7, 1)
        _PulseColor ("Pulse Color", Color) = (0.8, 1, 1, 1)
        _TowerColorA ("Tower Color A", Color) = (0.1, 0.9, 1, 1)
        _TowerColorB ("Tower Color B", Color) = (1, 0.2, 0.8, 1)
        _TowerColorC ("Tower Color C", Color) = (0.3, 1, 0.4, 1)
        _SkyColor ("Sky Color", Color) = (0.015, 0.02, 0.035, 1)
        _Horizon ("Horizon Height", Range(0.3, 0.8)) = 0.55
        _Aspect ("Width / Height", Float) = 1.8
        _GridScale ("Grid Density", Float) = 4
        _LineWidth ("Line Width (pixels)", Range(0.5, 4)) = 1.2
        _Speed ("Fly Speed", Float) = 2
        _PulseSpeed ("Pulse Speed", Float) = 0.6
        _StaticAmount ("Sky Static", Range(0, 0.2)) = 0.05
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
                float4 _TowerColorA;
                float4 _TowerColorB;
                float4 _TowerColorC;
                float4 _SkyColor;
                float _Horizon;
                float _Aspect;
                float _GridScale;
                float _LineWidth;
                float _Speed;
                float _PulseSpeed;
                float _StaticAmount;
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

            float hash21(float2 p)
            {
                float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
                p3 += dot(p3, p3.yzx + 33.33);
                return frac((p3.x + p3.y) * p3.z);
            }

            // One row of data towers on the horizon. Returns color in rgb, coverage in a.
            float4 Towers(float2 uv, float count, float seed, float maxHeight, float glow)
            {
                float x = uv.x * count;
                float id = floor(x);
                float fx = frac(x);

                float exists = step(0.35, hash11(id * 1.7 + seed));
                float left = lerp(0.08, 0.3, hash11(id + 9.2 + seed));
                float right = 1.0 - lerp(0.08, 0.3, hash11(id + 4.4 + seed));
                float height = lerp(0.2, 1.0, hash11(id + 17.3 + seed)) * maxHeight;
                float top = _Horizon + height;

                float inside = exists * step(left, fx) * step(fx, right)
                             * step(_Horizon, uv.y) * step(uv.y, top);
                if (inside < 0.5) return float4(0, 0, 0, 0);

                // Glowing outline
                float fwx = max(fwidth(x), 1e-5);
                float fwy = max(fwidth(uv.y), 1e-5);
                float dSide = min(fx - left, right - fx) / fwx;
                float dTop = (top - uv.y) / fwy;
                float outline = saturate(1.0 - min(dSide, dTop) / 1.3);

                // Tower color picked per tower
                float pick = hash11(id * 5.3 + seed);
                float3 c = pick < 0.33 ? _TowerColorA.rgb : (pick < 0.66 ? _TowerColorB.rgb : _TowerColorC.rgb);

                // Flickering windows
                float2 w = float2((fx - left) / (right - left) * 6.0, (uv.y - _Horizon) * 90.0);
                float2 wf = frac(w);
                float windowShape = step(0.3, wf.x) * step(wf.x, 0.7) * step(0.35, wf.y) * step(wf.y, 0.65);
                float lit = step(0.72, hash21(floor(w) + id * 13.0 + floor(_Time.y * 0.7 + hash11(id) * 5.0)));

                float3 fill = c * 0.07;
                float3 col = fill + c * outline * glow + c * windowShape * lit * 0.55 * glow;
                return float4(col, 1.0);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.uv;
                float3 col = _SkyColor.rgb;

                // Sky: dead-channel static, stronger near the top
                float stat = hash21(floor(uv * float2(320.0, 180.0)) + floor(_Time.y * 15.0) * 7.0);
                col += stat * _StaticAmount * saturate((uv.y - _Horizon) * 3.0);

                if (uv.y >= _Horizon)
                {
                    // Far towers first, then near towers on top
                    float4 far = Towers(uv, 22.0, 3.0, 0.12, 0.5);
                    col = lerp(col, far.rgb + _SkyColor.rgb, far.a);
                    float4 nearT = Towers(uv, 11.0, 41.0, 0.22, 1.0);
                    col = lerp(col, nearT.rgb + _SkyColor.rgb, nearT.a);
                }
                else
                {
                    // Perspective grid floor rushing toward the camera
                    float d = _Horizon - uv.y;
                    float z = 0.35 / d;
                    float wx = (uv.x - 0.5) * _Aspect * z;
                    float2 g = float2(wx, z + _Time.y * _Speed) * _GridScale;

                    float2 fw = max(fwidth(g), 1e-5);
                    float2 f = frac(g);
                    float2 dd = min(f, 1.0 - f) / fw;
                    float gridLines = saturate(1.0 - min(dd.x, dd.y) / _LineWidth);

                    float fog = saturate(d / _Horizon * 2.5);
                    float antiMoire = saturate(1.0 - fw.y * 1.5);

                    // Data pulses racing along the lines toward the camera
                    float lineId = round(g.x);
                    float onLine = saturate(1.0 - (abs(g.x - lineId) / fw.x) / (_LineWidth * 2.0));
                    float carries = step(0.6, hash11(lineId * 3.1 + 7.0));
                    float phase = frac(g.y * 0.25 + _Time.y * _PulseSpeed + hash11(lineId));
                    float pulse = onLine * carries * pow(phase, 12.0);

                    col += _GridColor.rgb * gridLines * fog * antiMoire * 0.8;
                    col += _PulseColor.rgb * pulse * fog * antiMoire * 1.5;
                    col += _GridColor.rgb * 0.04 * fog;
                }

                // Glowing horizon line
                col += _GridColor.rgb * exp(-abs(uv.y - _Horizon) * 60.0) * 0.6;

                // Scanlines and vignette
                float scanlines = 0.92 + 0.08 * sin(uv.y * 640.0);
                float vignette = saturate(1.15 - length(uv - 0.5) * 1.0);
                col *= scanlines * vignette * _Brightness;

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
