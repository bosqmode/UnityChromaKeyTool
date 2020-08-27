// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// inspiration: https://sensing.konicaminolta.us/us/blog/identifying-color-differences-using-l-a-b-or-l-c-h-coordinates/

Shader "ChromaKeyTool/ChromaKeyOp"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}

		_LightColor("Light Color", Color) = (1,1,1,1)
		_DarkColor("Dark Color", Color) = (1,1,1,1)
		_Threshhold("Threshhold", Float) = 0.3
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
				fixed4 _LightColor;
				fixed4 _DarkColor;
				float4 _MainTex_ST;
				float _Threshhold;

				appdata_t vert(appdata_base v)
				{
					appdata_t OUT;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
					OUT.vertex = UnityObjectToClipPos(v.vertex);
					OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					return OUT;
				 }

				float CalculateDistance(float c, float min, float max) {
					if (c < min) return min - c;
					if (c > max) return c - max;
					return 0;
				}

				float deltaE(float3 c1, float3 c2) {
					return sqrt( pow((c2.x - c1.x),2) + pow((c2.y - c1.y),2) + pow((c2.z - c1.z),2) );
				}


				float step1(float col) {

					if (col > 0.04045)
					{
						col = pow(((col + 0.055) / 1.055), 2.4);
					}
					else
					{
						col = col / 12.92;
					}

					return col;
				}

				float step2(float col) {
					if (col > 0.008856) {
						col = pow(col, (1.0 / 3.0));
					}
					else {
						col = (7.787 * col) + (16.0 / 116.0);
					}
					return col;
				}

				float3 RGB2XYZ(float3 color) {
					color.r = step1(color.r);
					color.g = step1(color.g);
					color.b = step1(color.b);

					color.r = color.r * 100;
					color.g = color.g * 100;
					color.b = color.b * 100;

					half3 xyz;

					xyz.x = color.r * 0.4124 + color.g * 0.3576 + color.b * 0.1805;
					xyz.y = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722;
					xyz.z = color.r * 0.0193 + color.g * 0.1192 + color.b * 0.9505;	

					return xyz;
				}

				float3 XYZ2LAB(float3 color) {
					half3 temp;

					temp.x = color.x / 92.834;
					temp.y = color.y / 100.000;
					temp.z = color.z / 103.665;

					temp.x = step2(temp.x);
					temp.y = step2(temp.y);
					temp.z = step2(temp.z);

					half3 lab;

					lab.x = (116 * temp.y) - 16;
					lab.y = 500 * (temp.x - temp.y);
					lab.z = 200 * (temp.y - temp.z);

					return lab;
				}

				fixed4 frag(appdata_t IN) : SV_Target
{
					half4 c = tex2D(_MainTex, IN.texcoord);

					float4 xyz;
					float4 lab;
					xyz.a = 1;
					lab.a = 1;

					xyz.rgb = RGB2XYZ(c.rgb);
					lab.rgb = XYZ2LAB(xyz);

					half3 dxyz = RGB2XYZ(_DarkColor);
					half3 lxyz = RGB2XYZ(_LightColor);
					half3 dlab = XYZ2LAB(dxyz);
					half3 llab = XYZ2LAB(lxyz);

					float deltae1 = deltaE(lab, dlab) / 100;
					float deltae2 = deltaE(lab, llab) / 100;
					float ediff = deltae1 * deltae2;
					c.a = ediff * c.a;

					if (c.a < _Threshhold)
						c.a = 0;
					else
						c.a = 1;

					return c;
				}
			 ENDCG
			 }
		}
}

