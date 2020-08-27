// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ChromaKeyTool/BlurOp"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_BlurSize("Blursize", Float) = 0.01
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
				"CanUseSpriteAtlas" = "True"
			}

			Cull Off
			Lighting Off
			ZWrite Off
			AlphaTest Off
			ZTest[unity_GUIZTestMode]
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"

				#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
				#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				sampler2D _MainTex;
				float _BlurSize;
				float4 _MainTex_ST;

				appdata_t vert(appdata_base v)
				{
					appdata_t OUT;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
					OUT.vertex = UnityObjectToClipPos(v.vertex);
					OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					return OUT;
				 }

				fixed4 frag(appdata_t IN) : SV_Target
				{

					//inspiration: https://www.ronja-tutorials.com/2018/08/27/postprocessing-blur.html

					//calculate aspect ratio
					float invAspect = _ScreenParams.y / _ScreenParams.x;
					//init color variable
					float alpha = 0;

					//iterate over blur samples
					for (float x = 0; x < 10; x++) {
						//get uv coordinate of sample
						float2 uv = IN.texcoord + float2((x / 9 - 0.5) * _BlurSize * invAspect, 0);
						//add color at position to color
						alpha += tex2D(_MainTex, uv).a;
					}

					for (float y = 0; y < 10; y++) {
						//get uv coordinate of sample
						float2 uv = IN.texcoord + float2(0, (y / 9 - 0.5) * _BlurSize * invAspect);
						//add color at position to color
						alpha += tex2D(_MainTex, uv).a;
					}

					//divide the sum of values by the amount of samples
					alpha = alpha / 20;

					float4 col;
					col.rgb = tex2D(_MainTex, IN.texcoord).rgb;
					col.a = alpha;
					return col;
				}
			 ENDCG
			 }
		}
}

