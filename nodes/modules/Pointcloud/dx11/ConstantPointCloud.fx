//@author: tmp 
//@help: Generates a colored PointCloud
//@tags: DX11, Kinect, Pointcloud
//@credits: vvvv

Texture2D texDepth <string uiname="Depth";>;
Texture2D texRGB <string uiname="RGB";>;
Texture2D texRGBDepth <string uiname="RGBDepth";>;

SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

float4x4 tW : WORLD;
float4x4 tVP : VIEWPROJECTION;
float4x4 tFilter <string uiname="Transform Filter";>;
float4x4 tFilterBoundingBox <string uiname="Transform Filter BoundingBox";>;
float2 FOV;
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

struct vsIn
{
	float4 pos : POSITION;
	float2 uv : TEXCOORD0;
};

struct vs2ps
{
    float4 pos: SV_POSITION;
    float2 uv: TEXCOORD0;
	float4 col: COLOR;
};

/* ===================== VERTEX SHADER ===================== */

vs2ps VS(vsIn input)
{
    vs2ps output = (vs2ps)0;
    
	float depth =  texDepth.SampleLevel(sPoint,input.uv.xy,0).r * 65.535 ;
	float XtoZ = tan(FOV.x/2) * 2;
    float YtoZ = tan(FOV.y/2) * 2;
	
	input.pos.x = ((input.uv.x - 0.5) * depth * XtoZ * -1);
	input.pos.y = ((0.5 - input.uv.y) * depth * YtoZ);
	input.pos.z = depth;
	input.pos = mul(input.pos, tW);
	
	// set pos.w to 0 when point is outside the filter transform
	// this prevents the point from being drawn
	float4 test = mul(input.pos, tFilter);
	
	if(	test.x < -0.5 || test.x > 0.5 ||
		test.y < -0.5 || test.y > 0.5 ||
		test.z < -0.5 || test.z > 0.5
		){
			input.pos.w = 0.0f; // this marks the vertex point as discard and will not be rendered
		}
	
	output.col = float4(input.pos);
	input.pos = mul(input.pos,tVP);
	output.pos = input.pos;
	output.uv = input.uv;
   
	return output;
}

/* ===================== PIXEL SHADER ===================== */

float4 PSColor(vs2ps input): SV_Target
{
	float2 coords = texRGBDepth.SampleLevel(sPoint,input.uv,0).rg;
	float4 col = texRGB.SampleLevel(sPoint,coords,0)* cAmb;
    return col;
}

float4 PSHeight(vs2ps input): SV_Target
{
    return input.col;
}

/* ===================== TECHNIQUE ===================== */

technique10 PointCloudRGB
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSColor() ) );
	}
}

technique10 PointCloudHeightEncoding
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSHeight() ) );
	}
}