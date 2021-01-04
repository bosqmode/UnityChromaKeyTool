// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ChromaKeyTool/DespillOp"
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

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				appdata_t vert(appdata_base v)
				{
					appdata_t OUT;
					OUT.vertex = UnityObjectToClipPos(v.vertex);
					OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					return OUT;
				 }

				fixed4 frag(appdata_t IN) : SV_Target
				{

					//inspiration: https://benmcewan.com/blog/2018/05/20/understanding-despill-algorithms/

					float4 col;
					col = tex2D(_MainTex, IN.texcoord).rgba;

					float average = (col.r + col.b) / 2;

					if (col.g > average)
						col.g = average;

					return col;
				}
			 ENDCG
			 }
		}
}

