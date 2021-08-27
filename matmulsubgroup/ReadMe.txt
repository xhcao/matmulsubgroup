This project could only run on machine whose `subgroupSize` is 16.
you could run `matmulsubgroup.exe float` | `matmulsubgroup.exe vec2` | `matmulsubgroup.exe vec4` to test float/vec2/vec4 types in shaders.
matrixmulsubgroupfloat0808.comp, matrixmulsubgroupvec20808.comp and matrixmulsubgroupvec40808.comp are GLSL shaders, which are more readable ones.
matmulsubgroupfloat|vec2|vec4 are HLSL shaders, which are converted by spirv-cross tools from GLSL shaders.
