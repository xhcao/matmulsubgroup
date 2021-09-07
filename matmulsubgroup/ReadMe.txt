This project could only run on machine whose `subgroupSize` is 16.
you could run `matmulsubgroup.exe float` | `matmulsubgroup.exe vec2` | `matmulsubgroup.exe vec4` | `matmulsubgroup.exe vec4shared` | `matmulsubgroup.exe floatshared` to test float/vec2/vec4 types with/without shared memory in shaders.
matrixmulsubgroupfloat.comp, matrixmulsubgroupvec2.comp, matrixmulsubgroupvec4.comp, matrixmulsubgroupsharedfloat.comp and matrixmulsubgroupsharedvec4.comp are GLSL shaders, which are more readable ones.
matmulsubgroupfloat|vec2|vec4|sharedfloat|sharedvec4 are HLSL shaders, which are converted by spirv-cross tools from GLSL shaders.
