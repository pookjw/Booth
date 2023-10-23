//
//  pixel_buffer_shader.metal
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

#include <metal_stdlib>
using namespace metal;

namespace pixel_buffer_shader {
    struct VertexIO {
        float4 position [[position]];
        float2 textureCoord [[user(texturecoord)]];
    };
    
    vertex VertexIO vertexFunction(const device packed_float4 *positions [[buffer(0)]],
                                   const device packed_float2 *textrueCoords [[buffer(1)]],
                                   uint vertexID [[vertex_id]])
    {
        return {
            .position = positions[vertexID],
            .textureCoord = textrueCoords[vertexID]
        };
    }
    
    fragment half4 fragmentFunction(VertexIO inoutFragment [[stage_in]],
                                    texture2d<half> inputTexture [[texture(0)]],
                                    sampler samplr [[sampler(0)]])
    {
        return inputTexture.sample(samplr, inoutFragment.textureCoord);
    }
}
