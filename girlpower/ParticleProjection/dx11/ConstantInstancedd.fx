//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 
float4x4 tW: WORLD;
float4x4 tWV: WORLDVIEW;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tWIT: WORLDINVERSETRANSPOSE;

float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float4 lAmb  <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff <bool color=true;String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=3.0;> = 25.0;     
float Alpha <float uimin=0.0; float uimax=1.5;> = 1;	
float4x4 tTex <bool uvspace=true; string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;
float rad;

Texture2D texture2d; 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};



struct particle
{
	float3 pos;
	float3 vel;
};
StructuredBuffer<particle> ppos;
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	
};


struct VS_IN
{
	uint ii : SV_InstanceID;
	uint iv : SV_VertexID;
	float4 PosO : POSITION;
	float2 TexCd : TEXCOORD0;
 float4 NormO : NORMAL;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;	
	 float4 NormO : NORMAL;
	float4 Color: TEXCOORD0;
    float2 TexCd: TEXCOORD1;
    float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);
	float4 PosV = mul(input.PosO, tWV);
    float3 NormV = normalize(mul(mul(input.NormO.xyz, (float3x3)tWIT),(float3x3)tV).xyz);
	float3 ViewDirV = normalize(-PosV.xyz);
	float3 H = normalize(ViewDirV + LightDirV);
	float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;
	
	float4 pout = float4(input.PosO.xyz,0.20f);
    Out.PosWVP  = mul(pout+float4(ppos[input.ii].pos,1.0),tVP);
	 
	Out.Color = lDiff;
    Out.TexCd = input.TexCd;
	Out.Diffuse = diff + lAmb;
    Out.Specular = spec;
	Out.NormO = float4(NormV,1);
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * In.Color;
	 col.rgb *= In.Diffuse.xyz + In.Specular.xyz;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




