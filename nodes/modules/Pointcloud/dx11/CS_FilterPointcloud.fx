
ByteAddressBuffer sobuffer;
int elementcount;
int slice;
float4x4 tFilter <string uiname="Transform Filter";>;

/*This is the buffer from the renderer
Renderer automatically assigns BACKBUFFER semantic
Please note we mark the buffer as append here */
AppendStructuredBuffer<uint> AppendPositionBuffer : BACKBUFFER;

[numthreads(1,1,1)]
void CS_Clear(uint3 i : SV_DispatchThreadID)
{
	//AppendPositionBuffer.Clear();
}

[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	//Safeguard if we don't use a multiple
	if (i.x >=  asuint(elementcount)) { return;}
	
	float x = asfloat(sobuffer.Load(i.x * 24));
	float y = asfloat(sobuffer.Load(i.x * 24 + 4));
	float z = asfloat(sobuffer.Load(i.x * 24 + 8));
	float w = asfloat(sobuffer.Load(i.x * 24 + 12));

	float4 test = mul(float4(x,y,z,w), tFilter);
	if(	!(test.x < -0.5 || test.x > 0.5 ||
		test.y < -0.5 || test.y > 0.5 ||
		test.z < -0.5 || test.z > 0.5
		)){
			AppendPositionBuffer.Append(i.x);
		}
}

technique11 FilterIDs
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







