// @Cyanilux
// Grass Geometry Shader, Written for Universal RP with help from https://roystan.net/articles/grass-shader.html
// Note, doesn't include Lighting or Tessellation
Shader "Unlit/GeoGrass" {
		Properties {
			_Color("Colour", Color) = (1,1,1,1)
			_Color2("Colour2", Color) = (1,1,1,1)
			_Width("Width", Float) = 1
			_RandomWidth("Random Width", Float) = 1
			_Height("Height", Float) = 1
			_RandomHeight("Random Height", Float) = 1
			_WindStrength("Wind Strength", Float) = 0.1
			[Space]
		     // Added by niuage
			_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
		}

		SubShader {
			Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
			LOD 300

			Cull Off

			Pass {
				Name "ForwardLit"
				Tags {"LightMode" = "UniversalForward"}

				HLSLPROGRAM
				// Required to compile gles 2.0 with standard srp library
				#pragma prefer_hlslcc gles
				#pragma exclude_renderers d3d11_9x gles
				#pragma target 4.5

				#pragma require geometry

				#pragma vertex vert
				#pragma geometry geom
				#pragma fragment frag

                // added by niuage
				#pragma hull hull
				#pragma domain domain

				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				#pragma multi_compile _ _SHADOWS_SOFT

				// Defines

				#define BLADE_SEGMENTS 1

				// Includes

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
				#include "grass.hlsl"

				// added by niuage
				#include "tesselation/CustomTessellation.hlsl"

				// Fragment

				float4 frag(GeometryOutput input) : SV_Target {
					#if SHADOWS_SCREEN
						float4 clipPos = TransformWorldToHClip(input.positionWS);
						float4 shadowCoord = ComputeScreenPos(clipPos);
					#else
						float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
					#endif

					Light mainLight = GetMainLight(shadowCoord);

					return lerp(_Color, _Color2, input.uv.y) * mainLight.shadowAttenuation;
				}

				ENDHLSL
			}
		}
}