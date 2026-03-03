#ifndef COMPRESSED

cbuffer positionTransformWV : register(b0)
{
    float4x4 matWV;
};
cbuffer positionTransformWV2 : register(b1)
{
    float4x4 matWV2;
};
cbuffer positionTransformProj : register(b2)
{
    float4x4 matP;
};
cbuffer textureTransform : register(b3)
{
    float4x4 matUV;
};
cbuffer textureUV2 : register(b4)
{
    float4 vecUVT2;
};
cbuffer fog : register(b5)
{
    float4 vecFog;
};

#ifdef LIGHTING
cbuffer lighting : register(b6)
{
    float3 vecLight0;
    float3 vecLight1;
    float4 vecLight0Col;
    float4 vecLight1Col;
    float4 vecLightAmbientCol;
};
#endif

#ifdef TEXGEN
cbuffer texgen : register(b7)
{
    float4x4 matTexGenEye;
    float4x4 matTexGenObj;
};
#endif

#else

cbuffer positionTransformWV : register(b0)
{
    float4x4 matWV;
};
cbuffer positionTransformProj : register(b2)
{
    float4x4 matP;
};
cbuffer textureUV2 : register(b4)
{
    float4 vecUVT2;
};
cbuffer fog : register(b5)
{
    float4 vecFog;
};
cbuffer positionTransform2 : register(b8)
{
    float4 vecWV2Trans;
};

#endif

SamplerState light_sampler_s : register(s0);
Texture2D<float4> light_texture : register(t0);

#ifndef COMPRESSED
struct VS_INPUT
{
    float4 v0 : POSITION0;
    float4 v1 : COLOR0;
    float3 v2 : NORMAL0;
    float4 v3 : TEXCOORD0;
    int2   v4 : TEXCOORD1;
};
#else
struct VS_INPUT
{
    int4 v0 : POSITION0;
    int4 v1 : TEXCOORD0;
};
#endif

struct VS_OUTPUT
{
    float4 o0 : SV_POSITION;
    float4 o1 : COLOR0;
    float4 o2 : TEXCOORD0;
};

float4 fog_calc(float4 vecFog, float eyeZ)
{
    float4 r0;
    r0.x = vecFog.x + eyeZ;
    r0.y = vecFog.x * eyeZ;
    r0.y = 1.44269502 * r0.y;
    r0.y = exp2(r0.y);
    r0.y = min(1, r0.y);
    r0.x = saturate(vecFog.y * r0.x);
    bool bLinear = (vecFog.z == 1);
    bool bExp    = (vecFog.z == 2);
    r0.y = bExp ? r0.y : 1;
    r0.z = bLinear ? r0.x : r0.y;
    return r0;
}

VS_OUTPUT main(VS_INPUT input)
{
    VS_OUTPUT output;
    float4 r0, r1, r2;

#ifndef COMPRESSED

    r0.xyzw = matWV2._m01_m11_m21_m31 * input.v0.yyyy;
    r0.xyzw = matWV2._m00_m10_m20_m30 * input.v0.xxxx + r0.xyzw;
    r0.xyzw = matWV2._m02_m12_m22_m32 * input.v0.zzzz + r0.xyzw;
    r0.xyzw = matWV2._m03_m13_m23_m33 * input.v0.wwww + r0.xyzw;
    r1.xyzw = matWV._m01_m11_m21_m31 * r0.yyyy;
    r1.xyzw = matWV._m00_m10_m20_m30 * r0.xxxx + r1.xyzw;
    r1.xyzw = matWV._m02_m12_m22_m32 * r0.zzzz + r1.xyzw;
    r0.xyzw = matWV._m03_m13_m23_m33 * r0.wwww + r1.xyzw;
    r1.xyzw = matP._m01_m11_m21_m31 * r0.yyyy;
    r1.xyzw = matP._m00_m10_m20_m30 * r0.xxxx + r1.xyzw;
    r1.xyzw = matP._m02_m12_m22_m32 * r0.zzzw + r1.xyzw;
    output.o0.xyzw = matP._m03_m13_m23_m33 * r0.wwww + r1.xyzw;

    r0.xy = (int2)input.v4.xy;
    r0.xy = float2(0.00390625, 0.00390625) * r0.xy;
    r0.xy = max(vecUVT2.xy, r0.xy);
    r0.xy = frac(r0.xy);
    r1.xyzw = light_texture.SampleLevel(light_sampler_s, r0.xy, 0).xyzw;
    r1.w = 1;
    output.o1.xyzw = input.v1.wzyx * r1.xyzw;

#ifdef LIGHTING
    r0.xyw = matWV2._m01_m11_m21 * input.v2.yyy;
    r0.xyw = matWV2._m00_m10_m20 * input.v2.xxx + r0.xyw;
    r0.xyw = matWV2._m02_m12_m22 * input.v2.zzz + r0.xyw;
    r1.xyz = matWV._m01_m11_m21 * r0.yyy;
    r1.xyz = matWV._m00_m10_m20 * r0.xxx + r1.xyz;
    r0.xyw = matWV._m02_m12_m22 * r0.www + r1.xyz;
    r1.x = dot(r0.xyw, r0.xyw);
    r1.x = rsqrt(r1.x);
    r0.xyw = r1.xxx * r0.xyw;
    r1.x = dot(vecLight1.xyz, r0.xyw);
    r0.x = dot(vecLight0.xyz, r0.xyw);
    r0.x = max(0, r0.x);
    r0.y = max(0, r1.x);
    r1.xyzw = vecLight1Col.xyzw * r0.yyyy;
    r1.xyzw = r0.xxxx * vecLight0Col.xyzw + r1.xyzw;
    r1.xyzw = saturate(vecLightAmbientCol.xyzw + r1.xyzw);

    r0.xy = (int2)input.v4.xy;
    r0.xy = float2(0.00390625, 0.00390625) * r0.xy;
    r0.xy = max(vecUVT2.xy, r0.xy);
    r0.xy = frac(r0.xy);
    r2.xyzw = light_texture.SampleLevel(light_sampler_s, r0.xy, 0).xyzw;
    r0.xyw = input.v1.wzy * r2.xyz;
    output.o1.xyz = r1.xyz * r0.xyw;
    output.o1.w = r1.w;
#endif

#ifdef TEXGEN
    r1.xyzw = matTexGenEye._m01_m11_m21_m31 * r0.yyyy;
    r1.xyzw = matTexGenEye._m00_m10_m20_m30 * r0.xxxx + r1.xyzw;
    r1.xyzw = matTexGenEye._m02_m12_m22_m32 * r0.zzzz + r1.xyzw;
    r1.xyzw = matTexGenEye._m03_m13_m23_m33 * r0.wwww + r1.xyzw;
    r2.xyzw = matTexGenObj._m01_m11_m21_m31 * input.v0.yyyy;
    r2.xyzw = matTexGenObj._m00_m10_m20_m30 * input.v0.xxxx + r2.xyzw;
    r2.xyzw = matTexGenObj._m02_m12_m22_m32 * input.v0.zzzz + r2.xyzw;
    r2.xyzw = matTexGenObj._m03_m13_m23_m33 * input.v0.wwww + r2.xyzw;
    r1.xyzw = r2.xyzw + r1.xyzw;
    r0.xyw = matUV._m01_m11_m31 * r1.yyy;
    r0.xyw = matUV._m00_m10_m30 * r1.xxx + r0.xyw;
    r0.xyw = matUV._m02_m12_m32 * r1.zzz + r0.xyw;
    output.o2.xyw = matUV._m03_m13_m33 * r1.www + r0.xyw;
#else
    r0.xy = matUV._m01_m11 * input.v3.yy;
    r0.xy = matUV._m00_m10 * input.v3.xx + r0.xy;
    output.o2.xy = matUV._m03_m13 + r0.xy;
    output.o2.w = 1;
#endif

    float4 fog = fog_calc(vecFog, r0.z);
    output.o2.z = fog.z;

#else // COMPRESSED

    r0.xyzw = (int4)input.v0.xyzw;
    r0.xyz = r0.xyz * float3(0.0009765625, 0.0009765625, 0.0009765625) + vecWV2Trans.xyz;
    r0.w = 32768 + r0.w;
    r1.xyz = float3(1.52587891e-05, 0.00048828125, 0.03125) * r0.www;
    r1.xyz = frac(r1.xyz);
    r2.xyzw = matWV._m01_m11_m21_m31 * r0.yyyy;
    r2.xyzw = matWV._m00_m10_m20_m30 * r0.xxxx + r2.xyzw;
    r0.xyzw = matWV._m02_m12_m22_m32 * r0.zzzz + r2.xyzw;
    r0.xyzw = matWV._m03_m13_m23_m33 + r0.xyzw;
    r2.xyzw = matP._m01_m11_m21_m31 * r0.yyyy;
    r2.xyzw = matP._m00_m10_m20_m30 * r0.xxxx + r2.xyzw;
    r2.xyzw = matP._m02_m12_m22_m32 * r0.zzzz + r2.xyzw;
    output.o0.xyzw = matP._m03_m13_m23_m33 * r0.wwww + r2.xyzw;
    r2.xyzw = (int4)input.v1.zwxy;
    r2.xyzw = float4(0.00390625, 0.00390625, 0.000122070312, 0.000122070312) * r2.xyzw;
    r0.xy = max(vecUVT2.xy, r2.xy);
    output.o2.xy = r2.zw;
    r0.xy = frac(r0.xy);
    r2.xyzw = light_texture.SampleLevel(light_sampler_s, r0.xy, 0).xyzw;
    output.o1.xyz = r2.xyz * r1.xyz;
    output.o1.w = 1;

    float4 fog = fog_calc(vecFog, r0.z);
    output.o2.z = fog.z;
    output.o2.w = 1;

#endif

    return output;
}