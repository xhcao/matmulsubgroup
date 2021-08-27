static const uint3 gl_WorkGroupSize = uint3(16u, 1u, 1u);

ByteAddressBuffer _116 : register(t2, space0);
ByteAddressBuffer _132 : register(t1, space0);
RWByteAddressBuffer _267 : register(u0, space0);

static uint3 gl_WorkGroupID;
static uint3 gl_LocalInvocationID;
static uint3 gl_GlobalInvocationID;
struct SPIRV_Cross_Input
{
    uint3 gl_WorkGroupID : SV_GroupID;
    uint3 gl_LocalInvocationID : SV_GroupThreadID;
    uint3 gl_GlobalInvocationID : SV_DispatchThreadID;
};

static int batch;

void mm_matMul()
{
    int global_x = int(gl_WorkGroupID.x);
    int global_y = int(gl_WorkGroupID.y);
    int local_x = int(gl_LocalInvocationID.x);
    int local_y = int(gl_LocalInvocationID.y);
    float2 dot00 = 0.0f.xx;
    uint indexRowA = uint(local_x) + (((uint(global_y) * 1u) * 384u) / 2u);
    uint indexColB = uint(local_x) + (uint(global_x) * 16u);
    uint indexRes = (uint(local_x) + (uint(global_x) * 16u)) + (((uint(global_y) * 1u) * 64u) / 2u);
    uint indexB = indexColB;
    uint indexA = indexRowA;
    float2 m_B[32];
    float2 arow;
    uint w = 0u;
    do
    {
        bool inRange = (w + (2u * WaveGetLaneIndex())) < 384u;
        if (WaveActiveAllTrue(inRange))
        {
            for (uint i = 0u; i < (WaveGetLaneCount() * 2u); i++)
            {
                m_B[i] = asfloat(_116.Load2(indexB * 8 + 0));
                indexB += 32u;
            }
            arow = asfloat(_132.Load2(indexA * 8 + 0));
            for (uint i_1 = 0u; i_1 < WaveGetLaneCount(); i_1++)
            {
                dot00 += (m_B[2u * i_1] * WaveReadLaneAt(arow, i_1).x);
                dot00 += (m_B[(2u * i_1) + 1u] * WaveReadLaneAt(arow, i_1).y);
            }
        }
        else
        {
            uint4 ballotValue = WaveActiveBallot(inRange);
            uint bollotCount = countbits(ballotValue.x) + countbits(ballotValue.y) + countbits(ballotValue.z) + countbits(ballotValue.w);
            for (uint i_2 = 0u; i_2 < (bollotCount * 2u); i_2++)
            {
                m_B[i_2] = asfloat(_116.Load2(indexB * 8 + 0));
                indexB += 32u;
            }
            arow = asfloat(_132.Load2(indexA * 8 + 0));
            for (uint i_3 = 0u; i_3 < bollotCount; i_3++)
            {
                dot00 += (m_B[2u * i_3] * WaveReadLaneAt(arow, i_3).x);
                dot00 += (m_B[(2u * i_3) + 1u] * WaveReadLaneAt(arow, i_3).y);
            }
        }
        indexA += WaveGetLaneCount();
        w += (WaveGetLaneCount() * 2u);
    } while (w < 384u);
    bool _250 = (uint(local_x) + (uint(global_x) * 16u)) < 32u;
    bool _261;
    if (_250)
    {
        _261 = (uint(local_y) + (uint(global_y) * 1u)) < 196u;
    }
    else
    {
        _261 = _250;
    }
    if (_261)
    {
        _267.Store2(indexRes * 8 + 0, asuint(dot00));
    }
}

void comp_main()
{
    batch = int(gl_GlobalInvocationID.z);
    mm_matMul();
}

[numthreads(16, 1, 1)]
void main(SPIRV_Cross_Input stage_input)
{
    gl_WorkGroupID = stage_input.gl_WorkGroupID;
    gl_LocalInvocationID = stage_input.gl_LocalInvocationID;
    gl_GlobalInvocationID = stage_input.gl_GlobalInvocationID;
    comp_main();
}