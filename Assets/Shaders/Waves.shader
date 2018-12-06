Shader "Custom/Waves" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Steepness ("Steepness", Range(0, 1)) = 0.5
		_WaveLength ("Wavelength", Float) = 10
		_Direction ("Direction (2D)", Vector) = (1,0,0,0)
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
		float2 _Direction;

		void vert (inout appdata_full vertexData) {
			float3 p = vertexData.vertex.xyz;

			float k = 2 * UNITY_PI / _WaveLength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(_Direction);
			float f = k * (dot(d, p.xz) - c * _Time.y);
			float a = _Steepness / k;

			p.x += d.x * (a * cos(f));
			p.y = a * sin(f);
			p.z += d.y * (a * cos(f));

			float3 tangent = float3(
				1 - d.x * d.x * (_Steepness * sin(f)),
				d.x * (_Steepness * cos(f)),
				-d.x * d.y * (_Steepness * sin(f))
			);
			float3 binormal = float3(
				-d.x * d.y * (_Steepness * sin(f)),
				d.y * (_Steepness * cos(f)),
				1 - d.y * d.y * (_Steepness * sin(f))
			);
			float3 normal = normalize(cross(binormal, tangent));

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
