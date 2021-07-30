//
//  FrameBuffer.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

/// <#Description#>
///
/// - missingAttachment: <#missingAttachment description#>
public enum GLFrameBufferError: Error {
    case missingAttachment(details: String)
}

/// <#Description#>
public enum GLColorAttachment {
    case attachment0, attachment1, attachment2, attachment3
    case attachment4, attachment5, attachment6, attachment7
    case attachment8, attachment9, attachment10, attachment11
    case attachment12, attachment13, attachment14, attachment15
    
    internal var glRepresentation: GLenum {
        switch self {
        case .attachment0: return GLenum(GL_COLOR_ATTACHMENT0)
        case .attachment1: return GLenum(GL_COLOR_ATTACHMENT1)
        case .attachment2: return GLenum(GL_COLOR_ATTACHMENT2)
        case .attachment3: return GLenum(GL_COLOR_ATTACHMENT3)
        case .attachment4: return GLenum(GL_COLOR_ATTACHMENT4)
        case .attachment5: return GLenum(GL_COLOR_ATTACHMENT5)
        case .attachment6: return GLenum(GL_COLOR_ATTACHMENT6)
        case .attachment7: return GLenum(GL_COLOR_ATTACHMENT7)
        case .attachment8: return GLenum(GL_COLOR_ATTACHMENT8)
        case .attachment9: return GLenum(GL_COLOR_ATTACHMENT9)
        case .attachment10: return GLenum(GL_COLOR_ATTACHMENT10)
        case .attachment11: return GLenum(GL_COLOR_ATTACHMENT11)
        case .attachment12: return GLenum(GL_COLOR_ATTACHMENT12)
        case .attachment13: return GLenum(GL_COLOR_ATTACHMENT13)
        case .attachment14: return GLenum(GL_COLOR_ATTACHMENT14)
        case .attachment15: return GLenum(GL_COLOR_ATTACHMENT15)
        }
    }
}

/// <#Description#>
public class GLFramebuffer: GLObject, GLObjectUsable, GLObjectSizeable {

    /// <#Description#>
    private(set) public var size: CGSize = .zero
    
    /// <#Description#>
    internal var colorAttachments = [GLColorAttachment: GLObjectSizeable]()
    
    /// <#Description#>
    ///
    /// - Parameter size: <#size description#>
    /// - Throws: <#throws value description#>
    public init(size: CGSize) throws {
        var framebufferName: GLuint = 0
        glGenFramebuffers(1, &framebufferName)
        try super.init(name: framebufferName)
        try validate(size: size)
        self.size = size
    }
    
    deinit {
        glDeleteFramebuffers(1,
                             &name)
    }
    
    
    /// <#Description#>
    public func use() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER),
                          name)
        let drawBuffers = colorAttachments.map { (colorAttachment, object) -> GLenum in
            return colorAttachment.glRepresentation
        }
        glDrawBuffers(GLsizei(drawBuffers.count),
                      drawBuffers)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - sourceFramebuffer: <#sourceFramebuffer description#>
    ///   - sourceAttachment: <#sourceAttachment description#>
    ///   - sourceRect: <#sourceRect description#>
    ///   - destinationFramebuffer: <#destinationFramebuffer description#>
    ///   - destinationAttachment: <#destinationAttachment description#>
    ///   - destinationRect: <#destinationRect description#>
    /// - Throws: <#throws value description#>
    public static func copy(from sourceFramebuffer: GLFramebuffer,
                            attachment sourceAttachment: GLColorAttachment,
                            rectangle sourceRect: CGRect,
                            to destinationFramebuffer: GLFramebuffer,
                            attachment destinationAttachment: GLColorAttachment,
                            rectangle destinationRect: CGRect) throws {
        
        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER),
                          sourceFramebuffer.name)
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER),
                          destinationFramebuffer.name)
        
        var sourceRectInPixels = GLCGGeometryConverter.pixels(from: sourceRect)
        // Invert origin Y
        guard let sourceAttachedObject = sourceFramebuffer.colorAttachments[sourceAttachment] else {
            throw GLFrameBufferError.missingAttachment(details: "Attemp to copy from \(sourceAttachment), which doesn't have anything attached to it")
        }
        guard destinationFramebuffer.colorAttachments[destinationAttachment] != nil else {
            throw GLFrameBufferError.missingAttachment(details: "Attemp to copy to \(destinationAttachment), which doesn't have anything attached to it")
        }
        
        // Invert Y origin
        sourceRectInPixels = GLCGGeometryConverter.inverted(rect: sourceRectInPixels,
                                                      relativeTo: GLCGGeometryConverter.pixels(from: sourceAttachedObject.size))
        let destinationRectInPixels = GLCGGeometryConverter.pixels(from: destinationRect)
        
        glBlitFramebuffer(GLint(sourceRectInPixels.minX),
                          GLint(sourceRectInPixels.minY),
                          GLint(sourceRectInPixels.maxX),
                          GLint(sourceRectInPixels.maxY),
                          GLint(destinationRectInPixels.minX),
                          GLint(destinationRectInPixels.minY),
                          GLint(destinationRectInPixels.maxX),
                          GLint(destinationRectInPixels.maxY),
                          GLbitfield(GL_COLOR_BUFFER_BIT),
                          GLenum(GL_LINEAR))
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - texture: <#texture description#>
    ///   - colorAttachment: <#colorAttachment description#>
    /// - Throws: <#throws value description#>
    public func attach(texture: GLTexture2D,
                       to colorAttachment: GLColorAttachment) throws {
        if texture.size.width != size.width || texture.size.height != size.height {
            throw GLObject.SizeError.invalidSize(details: "Attempt to attach a texture the size of which (w: \(texture.size.width), h: \(texture.size.width)) doesn't match the framebuffer's size (w: \(size.width), h: \(size.width))")
        }
        colorAttachments[colorAttachment] = texture
        use()
        texture.use()
        
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER),
                               colorAttachment.glRepresentation,
                               GLenum(GL_TEXTURE_2D),
                               texture.name,
                               0)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - layer: <#layer description#>
    ///   - texture2DArray: <#texture2DArray description#>
    ///   - colorAttachment: <#colorAttachment description#>
    /// - Throws: <#throws value description#>
    public func attach(layer: Int,
                       of texture2DArray: GLTexture2DArray,
                       to colorAttachment: GLColorAttachment) throws {
        if texture2DArray.size.width != size.width ||
            texture2DArray.size.height != size.height {
            throw GLObject.SizeError.invalidSize(details: "Attempt to attach a texture array the size of which (w: \(texture2DArray.size.width), h: \(texture2DArray.size.width)) doesn't match the framebuffer's size (w: \(size.width), h: \(size.width))")
        }
        colorAttachments[colorAttachment] = texture2DArray
        use()
        texture2DArray.use()
        
        glFramebufferTextureLayer(GLenum(GL_FRAMEBUFFER),
                                  colorAttachment.glRepresentation,
                                  texture2DArray.name,
                                  0,
                                  GLint(layer))
    }
}
