static const uint3 gl_WorkGroupSize = uint3(16u, 16u, 1u);

ByteAddressBuffer _62 : register(t1, space0);
ByteAddressBuffer _94 : register(t2, space0);
RWByteAddressBuffer _148 : register(u0, space0);

static uint3 gl_LocalInvocationID;
static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_LocalInvocationID : SV_GroupThreadID;
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

groupshared float m_B[16][16];

void mm_matMul()
{
    uint globalRow = gl_GlobalInvocationID.y;
    uint globalCol = gl_GlobalInvocationID.x;
    uint tileRow = gl_LocalInvocationID.y;
    uint tileCol = gl_LocalInvocationID.x;
    float dot00 = 0.0f;
    for (int t = 0; uint(t) < 24u; t++)
    {
        uint idxA = ((globalRow * 384u) + (uint(t) * 16u)) + tileCol;
        float arow = asfloat(_62.Load(idxA * 4 + 0));
        uint idxB = (((uint(t) * 16u) + tileRow) * 64u) + globalCol;
        if (((uint(t) * 16u) + tileRow) < 384u)
        {
            m_B[tileRow][tileCol] = asfloat(_94.Load(idxB * 4 + 0));
        }
        else
        {
            m_B[tileRow][tileCol] = 0.0f;
        }
        GroupMemoryBarrierWithGroupSync();
        for (int i = 0; uint(i) < 16u; i++)
        {
            dot00 += (WaveReadLaneAt(arow, uint(i)) * m_B[i][tileCol]);
        }
        GroupMemoryBarrierWithGroupSync();
    }
    if ((globalRow < 196u) && (globalCol < 64u))
    {
        uint indexRes = (globalRow * 64u) + globalCol;
        _148.Store(indexRes * 4 + 0, asuint(dot00));
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
