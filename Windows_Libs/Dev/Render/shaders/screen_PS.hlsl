cbuffer cbuff : register(b4)
{
    float4 clear_colour;
};

SamplerState screen_sampler_s : register(s0);
Texture2D<float4> screen_texture : register(t0);

float4 PS_ScreenSpace(float4 v0 : SV_POSITION, float2 v1 : TEXCOORD0) : SV_TARGET
{
    float4 o0;
    o0.xyzw = screen_texture.Sample(screen_sampler_s, v1.xy).xyzw;
    return o0;
}

float4 PS_ScreenClear(float4 v0 : SV_POSITION) : SV_TARGET
{
    float4 o0;
    o0.xyzw = clear_colour.xyzw;
    return o0;
}