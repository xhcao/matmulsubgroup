static const uint3 gl_WorkGroupSize = uint3(16u, 16u, 1u);

ByteAddressBuffer _66 : register(t1, space0);
ByteAddressBuffer _113 : register(t2, space0);
RWByteAddressBuffer _212 : register(u0, space0);

static uint3 gl_LocalInvocationID;
static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_LocalInvocationID : SV_GroupThreadID;
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

groupshared float4 m_B[64][16];

void mm_matMul()
{
    uint globalRow = gl_GlobalInvocationID.y;
    uint globalCol = gl_GlobalInvocationID.x;
    uint tileRow = gl_LocalInvocationID.y;
    uint tileCol = gl_LocalInvocationID.x;
    float4 dot00 = 0.0f.xxxx;
    for (int t = 0; uint(t) < 6u; t++)
    {
        uint idxA = (((globalRow * 384u) / 4u) + (uint(t) * 16u)) + tileCol;
        float4 arow = asfloat(_66.Load4(idxA * 16 + 0));
        uint idxBBase = (uint(t) * 16u) * 64u;
        for (int i = 0; i < 4; i++)
        {
            uint idxB = ((idxBBase + (((uint(i) * 16u) * 64u) / 4u)) + ((tileRow * 64u) / 4u)) + globalCol;
            m_B[(uint(i) * 16u) + tileRow][tileCol] = asfloat(_113.Load4(idxB * 16 + 0));
        }
        GroupMemoryBarrierWithGroupSync();
        for (int i_1 = 0; uint(i_1) < 16u; i_1++)
        {
            dot00 += (m_B[4 * i_1][tileCol] * WaveReadLaneAt(arow, uint(i_1)).x);
            dot00 += (m_B[(4 * i_1) + 1][tileCol] * WaveReadLaneAt(arow, uint(i_1)).y);
            dot00 += (m_B[(4 * i_1) + 2][tileCol] * WaveReadLaneAt(arow, uint(i_1)).z);
            dot00 += (m_B[(4 * i_1) + 3][tileCol] * WaveReadLaneAt(arow, uint(i_1)).w);
        }
        GroupMemoryBarrierWithGroupSync();
    }
    if ((globalRow < 196u) && (globalCol < 16u))
    {
        uint indexRes = ((globalRow * 64u) / 4u) + globalCol;
        _212.Store4(indexRes * 16 + 0, asuint(dot00));
    }
}

void comp_main()
{
    mm_matMul();
}

[numthreads(16, 16, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_LocalInvocationID = stage_input.gl_LocalInvocationID;
    gl_GlobalInvocationID = stage_input.gl_GlobalInvocationID;
    comp_main();
}
