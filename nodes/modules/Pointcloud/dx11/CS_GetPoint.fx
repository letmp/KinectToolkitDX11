
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float3> rwbuffer : BACKBUFFER;

//Texture we want to read from
Texture2D texDepth <string uiname="Texture Depth";>;
Texture2D texRGBDepth <string uiname="Texture RGBDepth";>;
float2 FOV;

//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;

SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};


[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	float2 coords = texRGBDepth.SampleLevel(sPoint,uv[i.x],0).rg;
	float2 offset = uv[i.x] - coords;
	float depth =  texDepth.SampleLevel(sPoint,coords,0).r * 65.535 ;
	float XtoZ = tan(FOV.x/2) * 2;
    float YtoZ = tan(FOV.y/2) * 2;
	
	float x = ((uv[i.x].x + offset.x - 0.5) * depth * XtoZ * -1);
	float y = ((0.5 - uv[i.x].y - offset.y) * depth * YtoZ);
	float z = depth;
	
	rwbuffer[i.x] = float3(x,y,z);

}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







