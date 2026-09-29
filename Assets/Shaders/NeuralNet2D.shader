// Dark "neural network" background for URP with the 2D Renderer.
// Drawn in chunky pixels so it stays crisp like pixel art.
Shader "Custom/NeuralNet2D"
{
    Properties
    {
        _BackgroundColor ("Background Color", Color) = (0.01, 0.005, 0.025, 1)
        _LineColor ("Link Color", Color) = (0.05, 0.3, 0.32, 1)
        _NodeColor ("Node Color", Color) = (0.6, 0.1, 0.5, 1)
        _PulseColor ("Data Packet Color", Color) = (0.45, 0.95, 0.95, 1)
        _PixelsTall ("Pixel Size (pixels tall)", Float) = 180
        _Aspect ("Width / Height", Float) = 1.8
        _CellsTall ("Network Density", Float) = 4
        _LinkChance ("Link Amount", Range(0, 1)) = 0.6
        _DriftSpeed ("Drift Speed", Float) = 0.4
        _PulseSpeed ("Data Speed", Float) = 0.5
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
                float4 _LineColor;
                float4 _NodeColor;
                float4 _PulseColor;
                float _PixelsTall;
                float _Aspect;
                float _CellsTall;
                float _LinkChance;
                float _DriftSpeed;
                float _PulseSpeed;
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

            // Where the node of a cell is, slowly drifting over time
            float2 NodePos(float2 cell)
            {
                float2 r = float2(hash21(cell), hash21(cell + 17.1));
                float t = _Time.y * _DriftSpeed;
                float2 wobble = float2(sin(t + r.x * 6.2831), cos(t * 0.8 + r.y * 6.2831)) * 0.15;
                return cell + 0.2 + r * 0.6 + wobble;
            }

            static const float2 dirs[3] = { float2(1, 0), float2(0, 1), float2(1, 1) };

            float SegDist(float2 p, float2 a, float2 b, out float t)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                t = saturate(dot(pa, ba) / dot(ba, ba));
                return length(pa - ba * t);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Snap to a chunky pixel grid
                float2 res = float2(_PixelsTall * _Aspect, _PixelsTall);
                float2 uv = (floor(IN.uv * res) + 0.5) / res;

                float2 p = uv * float2(_Aspect, 1.0) * _CellsTall;
                float2 baseCell = floor(p);
                float pixel = _CellsTall / _PixelsTall;     // one pixel in network units

                float links = 0.0;
                float packets = 0.0;
                float nodes = 0.0;

                [unroll]
                for (int j = -1; j <= 1; j++)
                {
                    [unroll]
                    for (int i = -1; i <= 1; i++)
                    {
                        float2 cell = baseCell + float2(i, j);
                        float2 a = NodePos(cell);

                        // Node dot, blinking gently
                        float blink = 0.6 + 0.4 * sin(_Time.y * 2.0 + hash21(cell) * 20.0);
                        float nd = length(p - a) / pixel;
                        nodes = max(nodes, (nd < 2.2 ? 1.0 : 0.0) * blink);
                        nodes = max(nodes, (nd < 4.0 ? 0.3 : 0.0) * blink);

                        [unroll]
                        for (int k = 0; k < 3; k++)
                        {
                            float2 d = dirs[k];
                            if (hash21(cell * 1.3 + d * 7.7) < _LinkChance)
                            {
                                float2 b = NodePos(cell + d);
                                float t;
                                float dist = SegDist(p, a, b, t) / pixel;
                                links = max(links, dist < 0.7 ? 1.0 : 0.0);

                                // Data packet travelling along the link
                                float speed = _PulseSpeed * (0.6 + hash21(cell + d * 3.1));
                                float head = frac(_Time.y * speed + hash21(cell * 2.7 + d));
                                float behind = head - t;
                                if (behind < 0.0) behind += 1.0;
                                float tail = saturate(1.0 - behind / 0.12);
                                packets = max(packets, (dist < 1.1 ? 1.0 : 0.0) * tail * tail);
                            }
                        }
                    }
                }

                float3 col = _BackgroundColor.rgb;

                // Faint digital noise in the void
                float noise = hash21(floor(IN.uv * res) + floor(_Time.y * 8.0) * 3.0);
                col += step(0.985, noise) * 0.04;

                col += _LineColor.rgb * links * 0.6;
                col = lerp(col, _PulseColor.rgb, packets);
                col = max(col, _NodeColor.rgb * nodes);

                float vignette = saturate(1.2 - length(IN.uv - 0.5) * 1.2);
                col *= vignette * _Brightness;

                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
