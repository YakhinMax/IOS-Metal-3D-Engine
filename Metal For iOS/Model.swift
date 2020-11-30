//
//  Model.swift
//  Metal For iOS
//
//  Created by Maxim Yakhin on 06.08.2020.
//  Copyright © 2020 Max Yakhin. All rights reserved.
//

import simd

struct Vertex {
    var position: SIMD3<Float>
    var ray: SIMD3<Float>
}

class Model {
    
    var apectRatio : Float = 1.0
    
    var camera = SIMD3<Float>(0,0,-3)
    
    var angles : [Float] = [0,0,0]
    
    var rotation = matrix_float3x3(SIMD3<Float>(1,0,0),
                                   SIMD3<Float>(0,1,0),
                                   SIMD3<Float>(0,0,1))

    var vertices : [Vertex] = [
        Vertex(position: SIMD3<Float>(-1,-1,0),
               ray: SIMD3<Float>(-1,-1,0)),
        Vertex(position: SIMD3<Float>(-1,1,0),
               ray: SIMD3<Float>(-1,1,0)),
        Vertex(position: SIMD3<Float>(1,-1,0),
               ray: SIMD3<Float>(1,-1,0)),
        Vertex(position: SIMD3<Float>(1,1,0),
               ray: SIMD3<Float>(1,1,0))
    ]
    
    func magnify(scale: Float) {
        camera *= scale
        for i in 0..<vertices.count {
            vertices[i].ray *= scale
        }
    }
    
    func incAngles(x: Float, y: Float) {
        angles[0] += x
        angles[1] += y
        let realCamera = simd_mul(rotation, camera)
        let axis = SIMD3<Float>(realCamera.z,0,-realCamera.x)
        let matrx = matrix3x3_rotation(radians: angles[0], axis: SIMD3<Float>(0,1,0))
        let matry = matrix3x3_rotation(radians: angles[1], axis: axis)
        rotation = simd_mul(matry, matrx)
    }
    
    func changeScale(scale: Float) {
        apectRatio = scale
    }

    func getVertices() -> [Vertex] {
        var transformedVertices : [Vertex] = []
        if apectRatio <= 0 {
            return vertices
        }
        for i in vertices {
            var transformedPosition = i.position
            if apectRatio > 1 { transformedPosition.y *= apectRatio }
            if apectRatio < 1 { transformedPosition.x /= apectRatio }
            let transformedRay = simd_mul(rotation, i.ray)
            transformedVertices.append(Vertex(position: transformedPosition, ray: transformedRay))
        }
        return transformedVertices
    }
    
    func getCamera() -> SIMD3<Float> {
        return simd_mul(rotation, camera)
    }
    
    func matrix3x3_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float3x3 {
        let unitAxis = normalize(axis)
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        return matrix_float3x3.init(columns:(vector_float3(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st),
                                             vector_float3(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st),
                                             vector_float3(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci)
                                             ))
    }
}

/*
 Broken Functions
 
 func orient(x: Float, y: Float) {
     let radx = x * sign(camera.z)
     let rady = y
     let ax1 = SIMD3<Float>(0, camera.z, 0)
     let ax2 = SIMD3<Float>(camera.z, 0, -camera.x)
     let matrx = matrix3x3_rotation(radians: radx, axis: ax1)
     let matry = matrix3x3_rotation(radians: rady, axis: ax2)
     let matr = simd_mul(matry, matrx)
     camera = simd_mul(SIMD3<Float>(camera), matr)
     for i in 0..<vertices.count {
         vertices[i].ray = simd_mul(vertices[i].ray, matr)
     }
     if vertices[0].ray.y > vertices[1].ray.y {
         let tmp = vertices[1]
         vertices[1] = vertices[0]
         vertices[0] = tmp
     }
     if vertices[2].ray.y > vertices[3].ray.y {
         let tmp = vertices[3]
         vertices[3] = vertices[2]
         vertices[2] = tmp
     }
 }
 
 func lookAt(x: Float, y: Float) {
     let ax1 = SIMD3<Float>(0, camera.z, camera.y)
     let ax2 = SIMD3<Float>(camera.z, 0, -camera.x)
     let matrx = matrix3x3_rotation(radians: x, axis: ax1)
     let matry = matrix3x3_rotation(radians: y, axis: ax2)
     let matr = simd_mul(matry, matrx)
     var newVertices : [Vertex] = []
     for v in vertices {
         var newRay = v.ray - camera
         newRay = simd_mul(matr, newRay)
         newRay = newRay + camera
         newVertices.append(Vertex(position: v.position, ray: newRay))
     }
     vertices = newVertices
 
 }
*/
