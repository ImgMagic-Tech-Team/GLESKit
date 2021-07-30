//
//  PlaygroundViewController.swift
//  GLESKitDemo
//
//  Created by SuXinDe on 2021/7/30.
//  Copyright © 2021 su xinde. All rights reserved.
//

import Foundation
import GLESKit

// MARK: - Lifecycle
extension PlaygroundViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContext()
        setupRenderPipelineObjects()
    }
}

class PlaygroundViewController: GLKViewController {
    
    let context = EAGLContext(api: .openGLES3)
    var vertexArray: GLVertexArray<WavefrontVertex>!
    var renderer: GLRenderer<WavefrontVertex>!
    
    // MARK: - Setup
    
    func setupContext() {
        let glkView = view as! GLKView
        glkView.context = context!
        glkView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
    }
    
    func setupRenderPipelineObjects() {
        let loader = try! WavefrontObjectLoader(modelName: "cube")
        let model = try! loader.loadModel()
        
        vertexArray = try! GLVertexArray(
            vertices: model.vertices,
            indices: model.indices
        )
        
        let program = try! GLProgram(
            vertexShader: GLShader(resourceName: "BlinnPhong.vsh", type: .vertex),
            fragmentShader: GLShader(resourceName: "BlinnPhong.fsh", type: .fragment)
        )
        
        renderer = GLRenderer(
            program: program,
            vertexArray: vertexArray,
            drawPattern: .triangles
        )
        
        print("")
    }
    
    // MARK: - Rendering
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        renderer.render(to: view) { (configuration) in
            configuration.viewport = CGRect(x: 0.0, y: 0.0, width: 400, height: 400)
        }
    }
}
