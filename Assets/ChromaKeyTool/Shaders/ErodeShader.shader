// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ChromaKeyTool/ErodeOp"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
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

				#pragma multi_compile _1X _2X _3X _5X _9X

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _MainTex_TexelSize;

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
					//inspiration: https://answers.unity.com/questions/1492354/i-am-new-to-shaders-and-i-want-to-write-a-shader-t.html

					float2 o = _MainTex_ST.xy;
					float4 col = tex2D(_MainTex, IN.texcoord);
					float alpha = col.a;

#ifdef _1X
					int scale = 1;
#endif

#ifdef _2X
					int scale = 2;
#endif

#ifdef _3X
					int scale = 3;
#endif

#ifdef _5X
					int scale = 5;
#endif

#ifdef _9X
					int scale = 9;
#endif

					for (int i = -scale; i <= scale && alpha > 0; ++i) {
						for (int j = -scale; j <= scale && alpha > 0; j++) {
							alpha -= 1 - tex2D(_MainTex, IN.texcoord + float2(i / _MainTex_TexelSize.z, j / _MainTex_TexelSize.w)).a;
						}
					}

					col.a = alpha;

					return col;
				}
			 ENDCG
			 }
		}
}

