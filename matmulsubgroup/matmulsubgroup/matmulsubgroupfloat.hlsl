static const uint3 gl_WorkGroupSize = uint3(16u, 1u, 1u);

ByteAddressBuffer _108 : register(t2, space0);
ByteAddressBuffer _124 : register(t1, space0);
RWByteAddressBuffer _229 : register(u0, space0);

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
    float dot00 = 0.0f;
    uint indexRowA = uint(local_x) + ((uint(global_y) * 1u) * 384u);
    uint indexColB = uint(local_x) + (uint(global_x) * 16u);
    uint indexRes = (uint(local_x) + (uint(global_x) * 16u)) + ((uint(global_y) * 1u) * 64u);
    uint indexB = indexColB;
    uint indexA = indexRowA;
    float m_B[16];
    float arow;
    uint w = 0u;
    do
    {
        bool inRange = (w + WaveGetLaneIndex()) < 384u;
        if (WaveActiveAllTrue(inRange))
        {
            for (uint i = 0u; i < WaveGetLaneCount(); i++)
            {
                m_B[i] = asfloat(_108.Load(indexB * 4 + 0));
                indexB += 64u;
            }
            arow = asfloat(_124.Load(indexA * 4 + 0));
            for (uint i_1 = 0u; i_1 < WaveGetLaneCount(); i_1++)
            {
                dot00 += (WaveReadLaneAt(arow, i_1) * m_B[i_1]);
            }
        }
        else
        {
            uint4 ballotValue = WaveActiveBallot(inRange);
            uint bollotCount = countbits(ballotValue.x) + countbits(ballotValue.y) + countbits(ballotValue.z) + countbits(ballotValue.w);
            for (uint i_2 = 0u; i_2 < bollotCount; i_2++)
            {
                m_B[i_2] = asfloat(_108.Load(indexB * 4 + 0));
                indexB += 64u;
            }
            arow = asfloat(_124.Load(indexA * 4 + 0));
            for (uint i_3 = 0u; i_3 < bollotCount; i_3++)
            {
                dot00 += (WaveReadLaneAt(arow, i_3) * m_B[i_3]);
            }
        }
        indexA += WaveGetLaneCount();
        w += WaveGetLaneCount();
    } while (w < 384u);
    bool _212 = (uint(local_x) + (uint(global_x) * 16u)) < 64u;
    bool _223;
    if (_212)
    {
        _223 = (uint(local_y) + (uint(global_y) * 1u)) < 196u;
    }
    else
    {
        _223 = _212;
    }
    if (_223)
    {
        _229.Store(indexRes * 4 + 0, asuint(dot00));
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
