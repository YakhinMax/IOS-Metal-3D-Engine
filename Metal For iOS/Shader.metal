//
//  Shader.metal
//  Metal For iOS
//
//  Created by Maxim Yakhin on 06.08.2020.
//  Copyright © 2020 Max Yakhin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

half4 rayMarch (float3, float3);

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 ray [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 relative_position;
};

vertex VertexOut vertex_shader(const VertexIn vertex_in [[stage_in]]) {
    VertexOut vertex_out;
    vertex_out.position = vertex_in.position;
    vertex_out.relative_position = vertex_in.ray;
    return vertex_out;
}

fragment half4 fragment_shader(VertexOut Vertex [[stage_in]],
                               constant packed_float3 &camera [[buffer(0)]]) {
    return rayMarch(float3(Vertex.relative_position), camera);
}

enum Type {Plane = 0, Sphere = 1};

struct Object {
    Type type;
    float3 position;
    float3 dimensions;
};

float smooth_min(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a,b) - h * h * h * k / 6;
}

half4 rayMarch (float3 direction, float3 camera) {
    float3 norm = normalize(direction - camera);
    float3 curpoint = camera;
    float3 pos = float3(0,0,0);
    float rad = 0.5;
    float minDist = INFINITY;
    float surface = INFINITY;
    for (ushort step = 0; step < 75; step++) {
        surface = curpoint.y + 1;
        if (surface <= 0.001)
            break;
        float dist = distance(curpoint, pos) - rad;
        if (abs(curpoint.x) > 5 || abs(curpoint.y) > 5 || abs(curpoint.z) > 5)
            if (dist > minDist)
                break;
        minDist = dist;
        if (minDist <= 0.001) {
            float3 l = normalize(camera - curpoint);
            float3 n = normalize(curpoint - pos);
            return half4(abs(n.y) * 2,0.5 + n.z,0.5 - n.z,1) * dot(l, n);
//            return half4(1,0,0,1) * dot(l, n);
        }
        curpoint += norm * min(minDist,surface);
    }
    if (direction.y * surface > 0)
        return half4(0.125,0.125,0.125,1);
    else
        return half4(abs(curpoint.z) / 5,0,0,1);
}
