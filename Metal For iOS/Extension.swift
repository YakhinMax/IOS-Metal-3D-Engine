//
//  Extension.swift
//  Metal For iOS
//
//  Created by Maxim Yakhin on 06.08.2020.
//  Copyright © 2020 Max Yakhin. All rights reserved.
//

import MetalKit

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        model.changeScale(scale: Float(size.width / size.height))
    }
    
    func draw(in view: MTKView) {
        let vertices = model.getVertices()
        renderer.buildVertexBuffer(array: vertices)
        renderer.setCamera(camera: model.getCamera())
        renderer.render(view: view)
    }
}
