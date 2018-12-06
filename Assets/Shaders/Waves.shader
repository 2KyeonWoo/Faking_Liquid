Shader "Custom/Waves" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveLength ("Wavelength", Float) = 10
		_Speed ("Speed", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Steepness, _WaveLength;

		void vert (inout appdata_full vertexData) {
			float3 p = vertexData.vertex.xyz;

			float k = 2 * UNITY_PI / _WaveLength;
			float c = sqrt(9.8 / k);
			float f = k * (p.x - c * _Time.y);
			float a = _Steepness / k;
			p.x += a * cos(f);
			p.y = a * sin(f);

			float3 tangent = normalize(float3(
				1 - _Steepness * sin(f),
				_Steepness * cos(f), 
				0
				));
			float3 normal = float3(-tangent.y, tangent.x, 0);

			vertexData.vertex.xyz = p;
			vertexData.normal = normal;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
