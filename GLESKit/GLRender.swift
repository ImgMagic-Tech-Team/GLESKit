//
//  Render.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

public enum GLDrawPattern {
    case triangles
    case triangleStrip
    case triangleFan
    
    internal var glRepresentation: GLenum {
        switch self {
        case .triangles: return GLenum(GL_TRIANGLES)
        case .triangleStrip: return GLenum(GL_TRIANGLE_STRIP)
        case .triangleFan: return GLenum(GL_TRIANGLE_FAN)
        }
    }
}


/// Provides an interface for on-screen and offscreen rendering while giving
/// the ability to adjust vertex and fragment shaders data in a convenient way
public class GLRenderer<VertexType: GLVertex> {
    
    // MARK: - Properties
    
    private let program: GLProgram
    private let vertexArray: GLVertexArray<VertexType>
    private let drawPattern: GLDrawPattern
    
    // MARK: - Lifecycle
    
    /// Designated initializer that gathers entities essential for a rendering process
    ///
    /// - Parameters:
    ///   - program: OpenGL program object
    ///   - vertexArray: object that holds vertex data
    ///   - drawPattern: object that tells how to interpret vertex data in the vertexArray
    public init(program: GLProgram,
                vertexArray: GLVertexArray<VertexType>,
                drawPattern: GLDrawPattern) {
        self.program = program
        self.vertexArray = vertexArray
        self.drawPattern = drawPattern
    }
    
    // MARK: - Private
    
    /// Apllies render parameters
    ///
    /// - Parameters:
    ///   - target: render target
    ///   - configuration: incapsulates render parameters for rendering to the target
    private func prepareForRendering(to target: GLObjectSizeable,
                                     with configuration: GLRenderConfiguration) {
        // Use viewport from a configuration object or determine it from the drawing surface's size
        if let viewport = configuration.viewport {
            let realViewport = GLCGGeometryConverter.pixels(from: GLCGGeometryConverter.inverted(rect: viewport, relativeTo: target.size))
            glViewport(GLint(realViewport.origin.x),
                       GLint(realViewport.origin.y),
                       GLsizei(realViewport.size.width),
                       GLsizei(realViewport.size.height))
        } else {
            let realSize = GLCGGeometryConverter.pixels(from: target.size)
            glViewport(0,
                       0,
                       GLsizei(realSize.width),
                       GLsizei(realSize.height))
        }
        
        if let buffersToClear = configuration.buffersToClear {
            glClear(GLbitfield(buffersToClear.reduce(0, { $0 | $1.glRepresentation })))
        }
    }
    
    /// Designated method for a single-pass rendering
    ///
    /// - Parameters:
    ///   - target: some render target
    ///   - configuration: a configuration closure for modifying render parameters
    private func internalRender(to target: GLObjectSizeable & GLObjectUsable,
                                configuration: ((GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        target.use()
        vertexArray.use()
        program.use()
        program.prepareForRendering()
        
        let singlePassRenderConfiguration = GLSinglePassRenderConfiguration(vertexArray: vertexArray,
                                                                            program: program)
        if let configuration = configuration {
            configuration(singlePassRenderConfiguration)
        }
        
        prepareForRendering(to: target,
                            with: singlePassRenderConfiguration)
        glDrawElements(drawPattern.glRepresentation,
                       GLsizei(vertexArray.indices.count),
                       GLenum(GL_UNSIGNED_SHORT),
                       nil);
    }
    
    /// Designated method for a multi-pass rendering
    ///
    /// - Parameters:
    ///   - target: render target
    ///   - numberOfPasses: number of render passes
    ///   - configuration: a configuration closure which can be used to adjust render parameters before a render cycle starts
    ///   - singlePassConfiguration: a configuration closure for applying render parameters for a partuclar render pass
    private func internalRender(to target: GLObjectSizeable & GLObjectUsable,
                                numberOfPasses: Int,
                                configuration: ((GLRenderConfiguration) -> Void)?,
                                singlePassConfiguration: ((Int, GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        target.use()
        vertexArray.use()
        program.use()
        
        let multipassRenderConfiguration = GLRenderConfiguration()
        if let configuration = configuration {
            configuration(multipassRenderConfiguration)
        }
        
        prepareForRendering(to: target, with: multipassRenderConfiguration)
        
        if let singlePassConfiguration = singlePassConfiguration {
            for pass in 0..<numberOfPasses {
                let signlePassRenderConfiguration = GLSinglePassRenderConfiguration(vertexArray: vertexArray,
                                                                                    program: program)
                program.prepareForRendering()
                singlePassConfiguration(pass,
                                        signlePassRenderConfiguration)
                prepareForRendering(to: target,
                                    with: signlePassRenderConfiguration)
                glDrawElements(drawPattern.glRepresentation,
                               GLsizei(vertexArray.vertices.count),
                               GLenum(GL_UNSIGNED_SHORT),
                               nil);
            }
        }
    }
    
    // MARK: - Public
    
    /// Single-pass on-screen rendering
    ///
    /// - Parameters:
    ///   - glkView: iOS-provided render target
    ///   - configuration: a configuration closure which can be used to adjust render parameters before rendering begins
    public func render(to glkView: GLKView,
                       configuration: ((GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        internalRender(to: glkView,
                       configuration: configuration)
    }
    
    /// Single-pass offscreen rendering
    ///
    /// - Parameters:
    ///   - framebuffer: offscreen render target
    ///   - configuration: a configuration closure which can be used to adjust render parameters before rendering begins
    public func render(to framebuffer: GLFramebuffer,
                       configuration: ((GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        internalRender(to: framebuffer,
                       configuration: configuration)
    }
    
    /// Multi-pass on-screen rendering
    ///
    /// - Parameters:
    ///   - glkView: iOS-provided render target
    ///   - numberOfPasses: number of render passes
    ///   - configuration: a configuration closure which allows to configure render parameters before the rendering begins
    ///   - singlePassConfiguration: a configuration closure which allows to configure render parameters for a particular render pass
    public func render(to glkView: GLKView,
                       numberOfPasses: Int,
                       configuration: ((GLRenderConfiguration) -> Void)?,
                       singlePassConfiguration: ((Int, GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        internalRender(to: glkView,
                       numberOfPasses: numberOfPasses,
                       configuration: configuration,
                       singlePassConfiguration: singlePassConfiguration)
    }
    
    /// Multi-pass offscreen rendering
    ///
    /// - Parameters:
    ///   - framebuffer: offscreen render target
    ///   - numberOfPasses: number of render passes
    ///   - configuration: a configuration closure which allows to configure render parameters before the rendering begins
    ///   - singlePassConfiguration: a configuration closure which allows to configure render parameters for a particular render pass
    public func render(to framebuffer: GLFramebuffer,
                       numberOfPasses: Int,
                       configuration: ((GLRenderConfiguration) -> Void)?,
                       singlePassConfiguration: ((Int, GLSinglePassRenderConfiguration<VertexType>) -> Void)?) {
        internalRender(to: framebuffer,
                       numberOfPasses: numberOfPasses,
                       configuration: configuration,
                       singlePassConfiguration: singlePassConfiguration)
    }
}
