bool reset;
StructuredBuffer<float3> resetPos;
StructuredBuffer<float3> noise;
float	Gamma;	
struct particle
{
	float3 pos;
	float3 vel;
};
RWStructuredBuffer<particle> Output : BACKBUFFER;
int ParticleCount;
float damp;
float radius;
float RepulseAmount;
float AttractAmount;
float radiusattract;
float3 BoxSyze;
float3 gravity;
float3 Attractor;
float AttractorForce;


//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void Repulsion( uint3 DTid : SV_DispatchThreadID )
{

	if (reset)
	{
		Output[DTid.x].pos = resetPos[DTid.x];
		Output[DTid.x].vel = 0;		
	}
	
	else
	{
		float dist = 0;
		float g = Gamma/(1.00001-Gamma);
		for( uint i = 0; i < uint(ParticleCount); i++ )
		{

            dist = distance(Output[DTid.x].pos,Output[i].pos);
			if (DTid.x != i){
				if (dist < radius){
	  			float f=saturate(1-dist*2);
	  			f=pow(f,g);
				Output[DTid.x].vel += (Output[DTid.x].pos-Output[i].pos)*lerp(0.0f,1.00f,f)*radius*RepulseAmount;
					
			    }
         
		     float distiz = distance(Attractor,Output[DTid.x].pos);
			if ( distiz<6) //if I'm within range
				{	float f=saturate(1-distiz*1);
					f=pow(f,g);
					Output[DTid.x].vel += ((Attractor-Output[DTid.x].pos)*lerp(0.0f,-0.50f,f));
				
				}
				
			}			
		}	


		
	
				
		if(Output[DTid.x].pos.y  > BoxSyze.y)
			{Output[DTid.x].pos.y = BoxSyze.y;
			Output[DTid.x].vel.y =	-0.01f * noise[DTid.x].x;
			}
		
	    else if(Output[DTid.x].pos.y < -BoxSyze.y)
			{Output[DTid.x].pos.y = -BoxSyze.y;
				Output[DTid.x].vel.y =	0.01*noise[DTid.x].x;
			}
		
	    if(Output[DTid.x].pos.x > BoxSyze.x) 
			{ Output[DTid.x].pos.x = BoxSyze.x;
				Output[DTid.x].vel.x =	-0.01*noise[DTid.x].x;
			}
		
	    else if(Output[DTid.x].pos.x < -BoxSyze.x) 
			{Output[DTid.x].pos.x = -BoxSyze.x;
				Output[DTid.x].vel.x =	0.01*noise[DTid.x].x;
			}
		
	    if(Output[DTid.x].pos.z > BoxSyze.z) 
			{Output[DTid.x].pos.z = BoxSyze.z;
			Output[DTid.x].vel.z =	-0.01*noise[DTid.x].x;
			}
		
		else if(Output[DTid.x].pos.z < -BoxSyze.z)
			{Output[DTid.x].pos.z =-BoxSyze.z;
				Output[DTid.x].vel.z =	0.01*noise[DTid.x].x;
			}

		
		Output[DTid.x].pos+= Output[DTid.x].vel;
		Output[DTid.x].vel += gravity*0.0001;
		Output[DTid.x].vel *= damp;
	}				
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, Repulsion() ) );
	}
}
