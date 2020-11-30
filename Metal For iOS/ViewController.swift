//
//  ViewController.swift
//  Metal For iOS
//
//  Created by Maxim Yakhin on 06.08.2020.
//  Copyright © 2020 Max Yakhin. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    var renderer: Renderer!
    var model: Model!
    var lastMouse: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = Model()
        
        model.changeScale(scale: Float(view.frame.width / view.frame.height))
        
        renderer = Renderer(view: view as! MTKView)
        renderer.metalView.delegate = self
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        renderer.metalView.addGestureRecognizer(pinch)
        
//        renderer.metalView.clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    var lastScale : CGFloat = 1.0
    
    @objc func zoom(sender: UIPinchGestureRecognizer) {
        //Doesn't work
        guard (sender.view != nil) else { return }
        if sender.state == .began {
            lastScale = sender.scale
        }
        else if sender.state == .changed {
            model.magnify(scale: Float(sender.scale / lastScale))
            lastScale = sender.scale
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        lastMouse = pos
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        let dx = pos.x - lastMouse.x
        let dy = pos.y - lastMouse.y
        model.incAngles(x: Float(dx / 360),y: Float(dy / 360))
        lastMouse = pos
    }
    
    func touchUp(atPoint pos: CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: renderer.metalView)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: renderer.metalView)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: renderer.metalView)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: renderer.metalView)) }
    }
}

