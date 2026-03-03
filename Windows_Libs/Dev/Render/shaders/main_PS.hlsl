cbuffer diffuse : register(b0)
{
    float4 diffuse_colour;
};
cbuffer fog : register(b1)
{
    float4 fog_colour;
};
cbuffer alphaTest : register(b3)
{
    float4 alphaTestRef;
};

#ifdef FORCE_LOD
cbuffer forcedLOD : register(b5)
{
    float4 forcedLod;
};
#endif

SamplerState diffuse_sampler_s : register(s0);
Texture2D<float4> diffuse_texture : register(t0);

struct PS_INPUT
{
    float4 v0 : SV_POSITION;
    float4 v1 : COLOR0;
    linear centroid float4 v2 : TEXCOORD0;
};

float4 main(PS_INPUT input) : SV_TARGET
{
    float4 r0, r1;

#ifdef TEXTURE_PROJECTION
    r0.xy = input.v2.xy / input.v2.ww;
    r0.xyzw = diffuse_texture.Sample(diffuse_sampler_s, r0.xy).xyzw;
    r0.xyzw = diffuse_colour.xyzw * r0.xyzw;
    r0.w = input.v1.w * r0.w;
    r1.x = (r0.w < alphaTestRef.w) ? 1 : 0;
    if (r1.x != 0) discard;
    r0.xyz = r0.xyz * input.v1.xyz + -fog_colour.xyz;
    float4 o0;
    o0.xyz = input.v2.zzz * r0.xyz + fog_colour.xyz;
    o0.w = r0.w;
    return o0;

#elif defined(FORCE_LOD)
    r0.xyzw = diffuse_texture.SampleLevel(diffuse_sampler_s, input.v2.xy, forcedLod.x).xyzw;
    r0.xyzw = diffuse_colour.xyzw * r0.xyzw;
    r0.w = input.v1.w * r0.w;
    r1.x = (r0.w < alphaTestRef.w) ? 1 : 0;
    if (r1.x != 0) discard;
    r0.xyz = r0.xyz * input.v1.xyz + -fog_colour.xyz;
    float4 o0;
    o0.xyz = input.v2.zzz * r0.xyz + fog_colour.xyz;
    o0.w = r0.w;
    return o0;

#else
    r0.x = (1 < input.v2.x) ? 1 : 0;
    if (r0.x != 0)
        r0.xyzw = diffuse_texture.SampleLevel(diffuse_sampler_s, input.v2.xy, 0).xyzw;
    else
        r0.xyzw = diffuse_texture.Sample(diffuse_sampler_s, input.v2.xy).xyzw;
    r0.xyzw = diffuse_colour.xyzw * r0.xyzw;
    r0.w = input.v1.w * r0.w;
    r1.x = (r0.w < alphaTestRef.w) ? 1 : 0;
    if (r1.x != 0) discard;
    r0.xyz = r0.xyz * input.v1.xyz + -fog_colour.xyz;
    float4 o0;
    o0.xyz = input.v2.zzz * r0.xyz + fog_colour.xyz;
    o0.w = r0.w;
    return o0;
#endif
}