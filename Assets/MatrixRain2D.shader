// Matrix digital rain shader for URP with the 2D Renderer.
// Put it on a material, and put the material on a Quad behind your scene.
Shader "Custom/MatrixRain2D"
{
    Properties
    {
        _RainColor ("Rain Color", Color) = (0.1, 1, 0.3, 1)
        _HeadColor ("Head Color", Color) = (0.8, 1, 0.85, 1)
        _BackgroundColor ("Background Color", Color) = (0, 0.02, 0, 1)
        _Columns ("Columns", Float) = 50
        _Rows ("Rows", Float) = 30
        _Speed ("Fall Speed", Float) = 1
        _TrailLength ("Trail Length", Range(0.05, 1)) = 0.4
        _GlyphSpeed ("Glyph Change Speed", Float) = 4
        _Brightness ("Brightness", Range(0, 2)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off

        Pass
        {
            // This tag is what makes the 2D Renderer draw the shader
            Tags { "LightMode"="Universal2D" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _RainColor;
                float4 _HeadColor;
                float4 _BackgroundColor;
                float _Columns;
                float _Rows;
                float _Speed;
                float _TrailLength;
                float _GlyphSpeed;
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

            // Simple pseudo-random functions
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

            // Draws a random symmetric 5x7 pixel "character" inside one cell
            float Glyph(float2 cellUV, float seed)
            {
                float2 inner = (cellUV - 0.15) / 0.7;
                if (inner.x < 0.0 || inner.x > 1.0 || inner.y < 0.0 || inner.y > 1.0)
                    return 0.0;

                float2 px = floor(inner * float2(5.0, 7.0));
                px.x = min(px.x, 4.0 - px.x); // mirror so it looks more like a symbol
                return step(0.5, hash21(px + seed * 7.31));
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 grid = float2(_Columns, _Rows);
                float2 uv = float2(IN.uv.x, 1.0 - IN.uv.y); // row 0 at the top
                float2 cell = floor(uv * grid);
                float2 cellUV = frac(uv * grid);

                // Each column falls at its own speed and starting offset
                float colRand = hash11(cell.x + 1.0);
                float speed = _Speed * lerp(0.5, 1.5, colRand);
                float cycle = _Rows * (1.0 + _TrailLength) + 5.0;
                float head = fmod(_Time.y * speed * 8.0 + colRand * cycle, cycle);
                float dist = head - cell.y;

                // Fade out behind the falling head
                float trail = max(_TrailLength * _Rows, 1.0);
                float intensity = (dist >= 0.0) ? saturate(1.0 - dist / trail) : 0.0;
                intensity *= intensity;

                // Characters flicker to new symbols over time
                float cellRand = hash21(cell);
                float glyphSeed = floor(_Time.y * _GlyphSpeed * lerp(0.3, 1.0, cellRand)) + cellRand * 100.0;
                float glyph = Glyph(cellUV, glyphSeed);

                // The leading character is brighter
                float isHead = (dist >= 0.0 && dist < 1.0) ? 1.0 : 0.0;
                float3 rain = lerp(_RainColor.rgb, _HeadColor.rgb, isHead);

                float3 col = _BackgroundColor.rgb + rain * glyph * intensity * _Brightness;
                return half4(col, 1.0);
            }
            ENDHLSL
        }
    }
}
