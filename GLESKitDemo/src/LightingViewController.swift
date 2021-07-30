//
//  LightingViewController.swift
//  GLESKitDemo
//
//  Created by SuXinDe on 2021/7/30.
//  Copyright © 2021 su xinde. All rights reserved.
//

import Foundation
import GLESKit

// MARK: - Lifecycle
extension LightingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContext()
        setupRenderPipelineObjects()
        
        for obstacle in obstacles {
            obstacle.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

class LightingViewController: GLKViewController {
    
    // MARK: - Properties
    
    // MARK - Scene settings
    @IBInspectable var lightRadius: Int = 0
    @IBInspectable var lightRaysCount: Int = 0
    
    // MARK - Outlets
    @IBOutlet var lights: [LightView]!
    @IBOutlet var obstacles: [UIImageView]!
    @IBOutlet weak var occludersContainerView: UIView!
    
    // MARK - Render pipeline stuff
    let context = EAGLContext(api: .openGLES3)
    
    var shadowMapRenderer: GLRenderer<FlatLightingVertex>!
    var lightsRenderer: GLRenderer<FlatLightingVertex>!
    
    var occludersTexture: GLTexture2D!
    var occludersFramebuffer: GLFramebuffer!
    
    var occluderSamplesTextureArray: GLTexture2DArray!
    var occluderSamplesFramebuffer: GLFramebuffer!
    
    var shadowMapFramebuffer: GLFramebuffer!
    var shadowMapTexture: GLTexture2D!
    
    // MARK: - Setup
    
    func setupContext() {
        let glkView = view as! GLKView
        glkView.context = context!
        glkView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
    }
    
    func setupRenderPipelineObjects() {
        let bottomLeftCorner = FlatLightingVertex(
            position: GLKVector4(v: (-1, -1, 0, 1)),
            textureCoordinates: GLKVector2(v: (0, 0))
        )
        let topLeftCorner = FlatLightingVertex(
            position: GLKVector4(v: (-1, 1, 0, 1)),
            textureCoordinates: GLKVector2(v: (0, 1))
        )
        let bottomRightCorner = FlatLightingVertex(
            position: GLKVector4(v: (1, -1, 0, 1)),
            textureCoordinates: GLKVector2(v: (1, 0))
        )
        let topRightCorner = FlatLightingVertex(
            position: GLKVector4(v: (1, 1, 0, 1)),
            textureCoordinates: GLKVector2(v: (1, 1))
        )
        
        let vertexArray = try! GLVertexArray(
            vertices: [bottomLeftCorner, topLeftCorner, bottomRightCorner, topRightCorner],
            indices: [0, 1, 2, 3]
        )
        
        let shadowMapRenderingProgram = try! GLProgram(
            vertexShader: GLShader(resourceName: "ShadowMapRenderer.vsh", type: .vertex),
            fragmentShader: GLShader(resourceName: "ShadowMapRenderer.fsh", type: .fragment)
        )
        
        let lightsRenderingProgram = try! GLProgram(
            vertexShader: GLShader(resourceName: "LightRenderer.vsh", type: .vertex),
            fragmentShader: GLShader(resourceName: "LightRenderer.fsh", type: .fragment)
        )
        
        shadowMapRenderer = GLRenderer(
            program: shadowMapRenderingProgram,
            vertexArray: vertexArray,
            drawPattern: .triangleStrip
        )
        
        lightsRenderer = GLRenderer(
            program: lightsRenderingProgram,
            vertexArray: vertexArray,
            drawPattern: .triangleStrip
        )
        
        // Texture will contain contents of the occludersContainerView
        occludersTexture = try! GLTexture2D(size: occludersContainerView.bounds.size)
        try! occludersTexture.update(withContentsOf: occludersContainerView)
        
        //
        occludersFramebuffer = try! GLFramebuffer(size: occludersTexture.size)
        try! occludersFramebuffer.attach(
            texture: occludersTexture,
            to: .attachment0
        )
        
        //
        shadowMapTexture = try! GLTexture2D(
            sizeInPixels: CGSize(width: lightRaysCount,
                                 height: lights.count)
        )
        shadowMapFramebuffer = try! GLFramebuffer(size: shadowMapTexture.size)
        try! shadowMapFramebuffer.attach(texture: shadowMapTexture, to: .attachment0)
        
        //
        let lightDiameter = Int(lightRadius * 2)
        occluderSamplesTextureArray = try! GLTexture2DArray(
            size: CGSize(width: lightDiameter,
                         height: lightDiameter),
            capacity: UInt(lights.count)
        )
        occluderSamplesFramebuffer = try! GLFramebuffer(size: occluderSamplesTextureArray.size)
    }
    
    // MARK: - Utility methods
    
    func lightFrame(for light: LightView) -> CGRect {
        return CGRect(x: light.center.x - CGFloat(lightRadius), y: light.center.y - CGFloat(lightRadius),
                      width: CGFloat(lightRadius * 2), height: CGFloat(lightRadius * 2))
    }
    
    // MARK: - Rendering
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        for (index, light) in lights.enumerated() {
            let frame = lightFrame(for: light)
            var bounds = frame
            bounds.origin = .zero
            try! occluderSamplesFramebuffer.attach(
                layer: index,
                of: occluderSamplesTextureArray,
                to: .attachment0
            )
            try! GLFramebuffer.copy(
                from: occludersFramebuffer,
                attachment: .attachment0,
                rectangle: frame,
                to: occluderSamplesFramebuffer,
                attachment: .attachment0,
                rectangle: bounds
            )
        }
        
        shadowMapRenderer.render(to: shadowMapFramebuffer, configuration: { [weak self] (configuration) in
            configuration.buffersToClear = [.color]
            try! configuration.program.modifyUniform(named: "u_occlusionMapsCount", with: Float(self!.lights.count))
            try! configuration.program.modifyUniform(named: "u_shadowMapSize", with: Float(self!.lightRaysCount))
            try! configuration.program.modifyUniform(named: "u_occlusionMaps", with: self!.occluderSamplesTextureArray)
        })
        
        lightsRenderer.render(to: view, numberOfPasses: lights.count, configuration: { (configuration) in
            configuration.buffersToClear = [.color]
            glEnable(GLenum(GL_BLEND));
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE));
        }, singlePassConfiguration: { [weak self] (pass, configuration) in
            let light = self!.lights[pass]
            configuration.viewport = self!.lightFrame(for: light)
            try! configuration.program.modifyUniform(named: "u_shadowMapTexture", with: self!.shadowMapTexture)
            try! configuration.program.modifyUniform(named: "u_shadowMapSize", with: GLKVector2(v: (Float(self!.lightRaysCount), Float(self!.lights.count))))
            try! configuration.program.modifyUniform(named: "u_lightIndex", with: Float(pass))
            try! configuration.program.modifyUniform(named: "u_lightColor", with: light.glLightColor)
        })
    }
}
