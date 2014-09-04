#define PI  3.14f 
#define NUM_LIGHTS               2 
 
float4 vMaterialColor = float4(192.f/255.f, 128.f/255.f, 96.f/255.f, 1.f); 
float fMaterialPower = 16.f; 
 
float4 vAmbientColor = float4(128.f/255.f, 128.f/255.f, 128.f/255.f, 1.f); 
float  materialAlpha = 1.0f;
float4   camera;
bool bSpecular = false; 
 
struct CLight 
{ 
   float3 vPos; 
   float3 vDir; 
   float4 vAmbient; 
   float4 vDiffuse; 
   float4 vSpecular; 
   float  fRange; 
   float3 vAttenuation; //1, D, D^2; 
}; 
 
int iLightPointNum; 
CLight lights[NUM_LIGHTS] = {                         //NUM_LIGHTS == 2
   { 
      float3(0.0f, 0.0f, 0.0f),              //position 
      float3(0.0f, 0.0f, 0.0f),              //direction 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //ambient 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //diffuse 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //specular 
      500.f,                                //range 
      float3(0.6f, 0.0000005f, 0.0000009f),                 //attenuation 
   }, 
   { 
      float3(0.0f, 0.0f, 0.0f),              //position 
      float3(0.0f, 0.0f, 0.0f),              //direction 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //ambient 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //diffuse 
      float4(0.0f, 0.0f, 0.0f, 0.0f),        //specular 
      500.f,                                //range 
      float3(0.6f, 0.0000005f, 0.0000009f),                 //attenuation 
   } 
}; 
 
//transformation matrices 
float4x4 matWorldViewProj  : WORLDVIEWPROJ; 
float4x4 matWorldView      : WORLDVIEW; 
float4x4 matWorld          : WORLD; 

texture Texture0;

sampler2D texSampler0 : TEXUNIT0 = sampler_state
{
	Texture	  = (Texture0);
    MIPFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
};
 
//function output structures 
struct VS_OUTPUT 
{ 
   float4 Pos           : POSITION; 
   float2 Tex0          : TEXCOORD0; 
   float3 worldPos      : TEXCOORD1; 
   float3 normal        : TEXCOORD2;
   float3 viewPos       : TEXCOORD3;
}; 
 
struct COLOR_PAIR 
{ 
   float4 Color         : COLOR0; 
   float4 ColorSpec     : COLOR1; 
}; 
 

//----------------------------------------------------------------------------- 
// Name: DoPointLight() 
// Desc: Point light computation 
//----------------------------------------------------------------------------- 
COLOR_PAIR DoPointLight(float3 vPosition, float3 N, float3 V, int i) 
{ 
   float3 pos=(float3)mul(matWorld,vPosition);
   float3 light = lights[i].vPos;
   float3 lightDir = light-pos;
   float3 L = normalize(lightDir); 
   COLOR_PAIR Out; 
   float NdotL = dot(N, L); 
   Out.Color = lights[i].vAmbient; 
   Out.ColorSpec = 0; 
   float fAtten = 1.f; 
   if(NdotL >= 0.f) 
   { 
      //compute diffuse color 
      Out.Color += NdotL * lights[i].vDiffuse; 
 
      //add specular component 
      if(bSpecular) 
      { 
         float3 H = normalize(L + V);   //half vector 
         Out.ColorSpec = pow(max(0, dot(H,N)), fMaterialPower) * lights[i].vSpecular; 
      } 
 
      float LD = length(lightDir); 
      fAtten = 1.f/(lights[i].vAttenuation.x + lights[i].vAttenuation.y*LD + lights[i].vAttenuation.z*LD*LD); 
      Out.Color.rgb *= fAtten; 
      Out.ColorSpec.rgb *= fAtten; 
   } 
   return Out; 
} 

 
//----------------------------------------------------------------------------- 
// Name: vs_main() 
// Desc: The vertex shader 
//----------------------------------------------------------------------------- 
VS_OUTPUT vs_main (float4 vPosition  : POSITION0,  
                   float3 vNormal    : NORMAL0,  
                   float2 tc         : TEXCOORD0, 
                   float2 tc2        : TEXCOORD1) 
{ 
   VS_OUTPUT Out = (VS_OUTPUT) 0; 
 
   vNormal = normalize(vNormal); 
   Out.Pos = mul(vPosition, matWorldViewProj); 
 
   float3 P = mul(matWorldView,vPosition).xyz;           //position in view space 
   float4 nn = float4(vNormal,1.0f);
   float3 N = normalize(mul(matWorld,nn).xyz);
   float3 C = mul(matWorldView,camera).xyz;
   float3 V = -normalize(C-P);                          //viewer 
 
   Out.Tex0 = tc; 
   Out.worldPos = vPosition.xyz;
   Out.normal = N;
   Out.viewPos = V;
   
   return Out; 
} 

float4 ps_main( in VS_OUTPUT IN) : COLOR
{	
   int i;
   float4 color = float4(0.0f, 0.0f, 0.0f,1.0f);
   float4 colorSpec = float4(0.0f, 0.0f, 0.0f,1.0f);
   for( i = 0; i < iLightPointNum; i++)  
   { 
      COLOR_PAIR ColOut = DoPointLight(IN.worldPos, IN.normal, IN.viewPos, i); 
      color += ColOut.Color; 
      colorSpec += ColOut.ColorSpec; 
   } 
 
   //apply material color 
   color *= vMaterialColor; 
   colorSpec *= vMaterialColor; 
  
   return saturate(color+colorSpec)*float4(1,1,1,materialAlpha);
}

float4 ps_main_texture( in VS_OUTPUT IN) : COLOR
{
   int i;
   float4 color = float4(0.0f, 0.0f, 0.0f,1.0f);
   float4 colorSpec = float4(0.0f, 0.0f, 0.0f,1.0f);
   for( i = 0; i < iLightPointNum; i++)  
   { 
      COLOR_PAIR ColOut = DoPointLight(IN.worldPos, IN.normal, IN.viewPos, i); 
      color += ColOut.Color; 
      colorSpec += ColOut.ColorSpec; 
   } 
 
   //apply material color 
   color *= vMaterialColor; 
   colorSpec *= vMaterialColor; 
	
   return saturate(color+colorSpec) * tex2D(texSampler0,IN.Tex0) * float4(1,1,1,materialAlpha);
}

// Techniques 
technique basic_without_texture
{ 
   pass P0 
   { 
      SPECULARENABLE = (bSpecular); 
      VertexShader = compile vs_3_0 vs_main(); 
	  PixelShader = compile ps_3_0 ps_main();
   } 
} 
technique basic_with_texture
{ 
   pass P0 
   { 
      SPECULARENABLE = (bSpecular); 
      VertexShader = compile vs_3_0 vs_main(); 
	  PixelShader = compile ps_3_0 ps_main_texture();
   } 
} 
