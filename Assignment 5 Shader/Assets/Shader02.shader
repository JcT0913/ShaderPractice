// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shader02"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_AnimationSpeed("Animation Speed", Vector) = (1,0,0,0)
		_TransmissionRelated("Transmission Related", Float) = 30
		_GradientSmoothness("Gradient Smoothness", Range( 0 , 1)) = 0
		_GenerateNoise("Generate Noise", Vector) = (1,0,0,0)
		_ColorA("Color A", Color) = (0.1411765,0.7333333,0.8392157,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform float4 _ColorA;
		uniform float _GradientSmoothness;
		uniform float2 _AnimationSpeed;
		uniform float2 _GenerateNoise;
		uniform float _TransmissionRelated;
		uniform float _EdgeLength;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float4 color78 = IsGammaSpace() ? float4(1,0.3893456,0,0) : float4(1,0.1255233,0,0);
			float temp_output_91_0 = ( _CosTime.w * -1.0 );
			float clampResult85 = clamp( ( temp_output_91_0 + ( ( temp_output_91_0 - i.uv_texcoord.x ) / _GradientSmoothness ) ) , 0.0 , 1.0 );
			float4 lerpResult79 = lerp( _ColorA , color78 , clampResult85);
			o.Albedo = lerpResult79.rgb;
			float2 uv_TexCoord3 = i.uv_texcoord * float2( 5,1 ) + float2( 1,1 );
			float2 panner4 = ( ( _Time.y * _AnimationSpeed ).x * _GenerateNoise + uv_TexCoord3);
			float simplePerlin2D1 = snoise( panner4*2.0 );
			simplePerlin2D1 = simplePerlin2D1*0.5 + 0.5;
			o.Smoothness = simplePerlin2D1;
			float3 temp_cast_2 = (( _SinTime.w * _TransmissionRelated )).xxx;
			o.Transmission = temp_cast_2;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19002
363;164;1384;1483;2130.208;1247.027;2.31464;True;True
Node;AmplifyShaderEditor.CommentaryNode;92;-1400.536,-1084.519;Inherit;False;1652.183;738.1736;Gradient Color & Modifying Color according to Time;12;79;85;45;78;84;83;82;88;91;89;90;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CosTime;89;-1271.057,-890.1983;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-1350.536,-701.9553;Inherit;False;Constant;_multifyCosTimeby1;multify Cos Time by -1;10;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1036.797,-860.9168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-1116.285,-1034.519;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-846.4654,-948.7629;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-982.4197,-666.3988;Inherit;False;Property;_GradientSmoothness;Gradient Smoothness;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-974.5751,97.32813;Inherit;False;1100.572;512.1351;Noise Genarator;7;52;6;5;8;3;4;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;6;-923.6511,401.7036;Inherit;False;Property;_AnimationSpeed;Animation Speed;6;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TimeNode;52;-924.5751,241.274;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;83;-641.489,-852.5511;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-609.708,310.5175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-691.5725,147.9341;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;75;-394.8881,-303.4278;Inherit;False;518.3615;362.3675;Transmission;3;66;67;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;-451.1554,-597.3761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-657.8621,445.4632;Inherit;False;Property;_GenerateNoise;Generate Noise;10;0;Create;True;0;0;0;False;0;False;1,0;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;76;-382.9278,385.9681;Inherit;False;693.1603;537.5698;Opacity Mask;5;73;74;69;71;80;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;4;-398.9559,148.397;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-344.8881,-92.18443;Inherit;False;Property;_TransmissionRelated;Transmission Related;7;0;Create;True;0;0;0;False;0;False;30;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;67;-267.8493,-253.4278;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;78;-277.5536,-760.5209;Inherit;False;Constant;_ColorB;Color B;8;0;Create;True;0;0;0;False;0;False;1,0.3893456,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;45;-285.0754,-962.5699;Inherit;False;Property;_ColorA;Color A;11;0;Create;True;0;0;0;False;0;False;0.1411765,0.7333333,0.8392157,0;0,0.7920473,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;85;-216.8979,-505.3456;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-44.4818,624.0823;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-784.9565,-251.7168;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;6b2910686f14f5844bf4707db2d5e2ba;6b2910686f14f5844bf4707db2d5e2ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;69;-85.09077,740.5331;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CosTime;80;-287.6795,435.6459;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;73;-332.9278,609.7495;Inherit;False;Property;_DisappearRelated;Disappear Related;8;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-138.0031,147.3281;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-38.52643,-76.06007;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;144.2324,595.4167;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;79;69.64981,-582.7359;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;257.3656,-125.951;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Shader02;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;False;Transparent;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;5;-1;-1;0;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;91;0;89;4
WireConnection;91;1;90;0
WireConnection;82;0;91;0
WireConnection;82;1;88;1
WireConnection;83;0;82;0
WireConnection;83;1;87;0
WireConnection;8;0;52;2
WireConnection;8;1;6;0
WireConnection;84;0;91;0
WireConnection;84;1;83;0
WireConnection;4;0;3;0
WireConnection;4;2;5;0
WireConnection;4;1;8;0
WireConnection;85;0;84;0
WireConnection;74;0;80;4
WireConnection;74;1;73;0
WireConnection;1;0;4;0
WireConnection;68;0;67;4
WireConnection;68;1;66;0
WireConnection;71;0;74;0
WireConnection;71;1;69;2
WireConnection;79;0;45;0
WireConnection;79;1;78;0
WireConnection;79;2;85;0
WireConnection;0;0;79;0
WireConnection;0;4;1;0
WireConnection;0;6;68;0
ASEEND*/
//CHKSM=E0E18DB214B21D8D063B0EB8FEDFB990A41BFA59