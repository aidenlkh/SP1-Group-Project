// Procedural sunset city with five scrolling building layers, in crisp pixels.
// URP 2D Renderer. No textures needed.
Shader "Custom/SunsetCity2D"
{
    Properties
    {
        _SkyTop ("Sky Top", Color) = (0.72, 0.52, 0.72, 1)
        _SkyBottom ("Sky Near Horizon", Color) = (1.0, 0.74, 0.62, 1)
        _Color1 ("Far Buildings", Color) = (0.94, 0.6, 0.66, 1)
        _Color2 ("Buildings 2", Color) = (0.84, 0.4, 0.52, 1)
        _Color3 ("Buildings 3", Color) = (0.56, 0.26, 0.42, 1)
        _Color4 ("Buildings 4", Color) = (0.14, 0.17, 0.27, 1)
        _Color5 ("Front Buildings", Color) = (0.05, 0.09, 0.13, 1)
        _WindowWarm ("Window Light", Color) = (1.0, 0.72, 0.62, 1)
        _PixelsTall ("Pixels Tall", Float) = 324
        _Aspect ("Width / Height", Float) = 1.78
        _Speed ("Scroll Speed", Float) = 6
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
                float4 _SkyTop;
                float4 _SkyBottom;
                float4 _Color1;
                float4 _Color2;
                float4 _Color3;
                float4 _Color4;
                float4 _Color5;
                float4 _WindowWarm;
                float _PixelsTall;
                float _Aspect;
                float _Speed;
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

            // One layer of buildings.
            // Returns: x = inside a building (0/1), y = lit window (0/1)
            float2 City(float2 px, float cellW, float ground, float baseH, float varH,
                        float seed, float winChance)
            {
                float cell = floor(px.x / cellW);
                float lx = frac(px.x / cellW);

                float left = hash11(cell + seed) * 0.25;
                float right = 1.0 - hash11(cell + seed + 7.3) * 0.25;
                float height = floor(baseH + hash11(cell + seed + 3.1) * varH);

                float inBuilding = step(left, lx) * step(lx, right) * step(px.y, height);
                float inGround = step(px.y, ground);
                float inside = max(inBuilding, inGround);

                // Small antenna on some roofs
                float antennaX = floor(cell * cellW + cellW * (left + right) * 0.5);
                float hasAntenna = step(0.7, hash11(cell + seed + 11.0));
                float antenna = hasAntenna * step(abs(floor(px.x) - antennaX), 0.5)
                              * step(height, px.y) * step(px.y, height + 6.0);
                inside = max(inside, antenna);

                // Windows: 2x2 pixels on a 4x5 grid, only on buildings, not near the roof
                float2 wcell = floor(px / float2(4.0, 5.0));
                float2 wpos = px - wcell * float2(4.0, 5.0);
                float windowShape = step(1.0, wpos.x) * step(wpos.x, 2.0) * step(1.0, wpos.y) * step(wpos.y, 2.0);
                float lit = step(hash21(wcell + seed * 13.0), winChance);
                float window = inBuilding * windowShape * lit * step(px.y, height - 4.0) * step(ground * 0.5, px.y);

                return float2(inside, window);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Chunky pixel grid, bottom-left origin
                float2 res = float2(_PixelsTall * _Aspect, _PixelsTall);
                float2 px = floor(IN.uv * res);
                float t = _Time.y * _Speed;
                float h = _PixelsTall / 324.0;          // keeps proportions if Pixels Tall changes

                // Sky gradient with banded pixel steps
                float skyT = saturate(px.y / _PixelsTall);
                skyT = floor(skyT * 14.0) / 14.0;
                float3 col = lerp(_SkyBottom.rgb, _SkyTop.rgb, pow(skyT, 1.3));

                // Scalloped cloud bands drifting slowly
                [unroll]
                for (int b = 0; b < 3; b++)
                {
                    float bandY = (_PixelsTall * (0.62 + b * 0.12));
                    float cx = px.x + t * 0.08 * (b + 1) + b * 40.0;
                    float bump = abs(sin(cx * 0.07 + b)) * 7.0 + abs(sin(cx * 0.023 + b * 2.0)) * 5.0;
                    float inCloud = step(bandY - bump, px.y);
                    col = lerp(col, lerp(col, _SkyTop.rgb, 0.35), inCloud * 0.5);
                }

                // Buildings, far to near, each scrolling faster
                float2 c1 = City(float2(px.x + t * 0.10, px.y), 58.0 * h, 105.0 * h, 150.0 * h, 70.0 * h, 1.0, 0.0);
                col = lerp(col, _Color1.rgb, c1.x);
                // pale horizontal stripes on the far towers, like distant glass
                float stripe = step(fmod(px.y, 3.0), 0.5) * c1.x * step(115.0 * h, px.y);
                col = lerp(col, lerp(_Color1.rgb, _SkyBottom.rgb, 0.6), stripe);

                float2 c2 = City(float2(px.x + t * 0.25, px.y), 50.0 * h, 85.0 * h, 115.0 * h, 60.0 * h, 21.0, 0.28);
                col = lerp(col, _Color2.rgb, c2.x);
                col = lerp(col, _WindowWarm.rgb, c2.y * 0.8);

                float2 c3 = City(float2(px.x + t * 0.45, px.y), 44.0 * h, 65.0 * h, 90.0 * h, 55.0 * h, 41.0, 0.22);
                col = lerp(col, _Color3.rgb, c3.x);
                col = lerp(col, _WindowWarm.rgb, c3.y * 0.6);

                float2 c4 = City(float2(px.x + t * 0.75, px.y), 40.0 * h, 42.0 * h, 62.0 * h, 60.0 * h, 61.0, 0.18);
                col = lerp(col, _Color4.rgb, c4.x);
                col = lerp(col, lerp(_WindowWarm.rgb, _Color2.rgb, 0.4), c4.y * 0.7);

                float2 c5 = City(float2(px.x + t * 1.2, px.y), 54.0 * h, 18.0 * h, 38.0 * h, 50.0 * h, 81.0, 0.12);
                col = lerp(col, _Color5.rgb, c5.x);
                col = lerp(col, lerp(_Color4.rgb, _WindowWarm.rgb, 0.35), c5.y * 0.8);

                return half4(col * _Brightness, 1.0);
            }
            ENDHLSL
        }
    }
}
