float4x4 tFilter: WORLD;
float4x4 tHitbox;

Texture2D tex <string uiname="Texture";>;
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
int elementcount;
int slice;


bool countmode <String uiname="Hit/Count Mode";>;

RWStructuredBuffer<uint> buffer : BACKBUFFER;

SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

[numthreads(1,1,1)]
void CS_Clear(uint3 i : SV_DispatchThreadID)
{
	buffer[slice] = 0;
}

[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >=  asuint(elementcount)) { return;}
	if (buffer[slice] == 1 && !countmode) { return; }
	
	float4 coords = tex.SampleLevel(mySampler,uv[i.x],0);
	if(coords.w != 0.0f){
		float4 test = mul(coords, tHitbox);
		if(	!(test.x < -0.5 || test.x > 0.5 ||
			test.y < -0.5 || test.y > 0.5 ||
			test.z < -0.5 || test.z > 0.5
			)){
				if(countmode){
					uint oldval;
					InterlockedAdd(buffer[slice],1,oldval);
				}
				else buffer[slice] = 1;
		}
	}
	
	
}

technique11 CollisionDetection
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

technique11 Clear
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );
	}
}






