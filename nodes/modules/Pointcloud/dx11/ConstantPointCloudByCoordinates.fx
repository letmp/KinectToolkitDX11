//@author: tmp 
//@help: Creates a colored pointcloud 
//@tags: DX11, Kinect, Pointcloud
//@credits: vvvv

float4x4 tW: WORLD;
float4x4 tVP: VIEWPROJECTION;

ByteAddressBuffer sobCoords <string uiname="CoordinatesBuffer";>;
StructuredBuffer<uint> sbIndex <string uiname="IndexBuffer";>;

Texture2D texRGB <string uiname="RGB";>;
Texture2D texRGBDepth <string uiname="RGBDepth";>;
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
float4x4 tFilterBoundingBox <string uiname="Transform Filter BoundingBox";>;

SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

struct vsIn
{
	float4 pos : POSITION;
	uint ii : SV_InstanceID;
};

struct psIn
{
    float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float4 col : Color;
}; 

psIn VS(vsIn input)
{
	psIn output;
	
	uint idx = sbIndex[input.ii];
	
	// move geometry
	float x = asfloat(sobCoords.Load(idx * 24));
	float y = asfloat(sobCoords.Load(idx * 24 + 4));
	float z = asfloat(sobCoords.Load(idx * 24 + 8));
	float w = asfloat(sobCoords.Load(idx * 24 + 12));
	float3 center = float3(x,y,z);	
	center += input.pos.xyz;
    output.pos  = mul(float4(center,w),tW);
	
	float height = mul(output.pos, tFilterBoundingBox).y + 0.5f;
	output.col = output.pos;
	
	output.pos  = mul(output.pos, tVP);
	
	// pass texcoords for color lookup
	output.uv = float2(asfloat(sobCoords.Load(idx * 24 + 16)), asfloat(sobCoords.Load(idx * 24 + 20)));
	
    return output;
}

float4 PS(psIn input): SV_Target
{
	float2 coords = texRGBDepth.SampleLevel(sPoint,input.uv,0).rg;
    return texRGB.SampleLevel(sPoint,coords,0)* cAmb;
}

float4 PSHeight(psIn input): SV_Target
{
	float4 col = input.col;
    return col;
}

technique10 PointCloudRGB
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
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



 
