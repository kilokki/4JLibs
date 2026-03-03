cbuffer screenspace_constants : register(b9)
{
    float4 v_scaleoffset;
};

void VS_ScreenSpace(uint v0 : SV_VertexID, out float4 o0 : SV_POSITION, out float2 o1 : TEXCOORD0)
{
    float4 r0, r1;

    o0.zw = float2(1, 1);
    r0.xy = (int2)v0.xx & int2(1, -2);
    r0.z = (uint)r0.x << 1;
    r0.yz = (int2)r0.yz + int2(-1, -1);
    r1.x = (int)r0.x;
    o0.xy = (int2)r0.zy;
    r0.x = (uint)v0.x >> 1;
    r0.x = (int)-r0.x + 1;
    r1.y = (int)r0.x;
    o1.xy = r1.xy * v_scaleoffset.zw + v_scaleoffset.xy;
}

void VS_ScreenClear(uint v0 : SV_VertexID, out float4 o0 : SV_POSITION)
{
    float4 r0;

    r0.x = (uint)v0.x << 1;
    r0.x = (int)r0.x & 2;
    r0.x = (int)r0.x + -1;
    o0.x = (int)r0.x;
    r0.x = (int)v0.x & -2;
    r0.x = (int)r0.x + -1;
    o0.y = (int)r0.x;
    o0.zw = float2(1, 1);
}