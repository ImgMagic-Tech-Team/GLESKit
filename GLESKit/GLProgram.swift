//
//  GLProgram.swift
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
/// - unableToLink: <#unableToLink description#>
/// - nonexistentUniform: <#nonexistentUniform description#>
/// - tooManyUniformTextures: <#tooManyUniformTextures description#>
public enum GLProgramError: Error {
    case unableToLink(details: String)
    case nonexistentUniform
    case tooManyUniformTextures
}

/// <#Description#>
public class GLProgram: GLObject, GLObjectUsable {
    
    /// <#Description#>
    private static var availableTextureUnits: [Int32] = {
        var maximumTextureUnits: GLint = 0
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_IMAGE_UNITS), &maximumTextureUnits)
        return [Int32](0..<maximumTextureUnits)
    }()
    
    /// <#Description#>
    private var usedTextureUnits = Set<Int32>()
    
    /// <#Description#>
    private var uniforms = [String: Int32]()
    
    /// <#Description#>
    private var vertexShader: GLShader
    
    /// <#Description#>
    private var fragmentShader: GLShader
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - vertexShader: <#vertexShader description#>
    ///   - fragmentShader: <#fragmentShader description#>
    /// - Throws: <#throws value description#>
    public init(vertexShader: GLShader,
                fragmentShader: GLShader) throws {
        let programName = glCreateProgram()
        
        self.vertexShader = vertexShader
        self.fragmentShader = fragmentShader
        
        glAttachShader(programName, vertexShader.name)
        glAttachShader(programName, fragmentShader.name)
        
        try super.init(name: programName)
        try link()
        obtainUniforms()
    }
    
    /// <#Description#>
    ///
    /// - Throws: <#throws value description#>
    private func link() throws {
        glLinkProgram(name)
        
        var linked: GLint = 0
        glGetProgramiv(name, GLenum(GL_LINK_STATUS), &linked)
        
        if linked == 0 {
            var infoLength: GLint = 0
            glGetProgramiv(name, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            var errMsg: String = ""
            if infoLength > 1 {
                let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLength))
                glGetProgramInfoLog(name, infoLength, nil, infoLog)
                errMsg = String(cString: infoLog)
                free(infoLog)
            }
            glDeleteProgram(name)
            
            throw GLProgramError.unableToLink(details: errMsg)
        }
    }
    
    /// <#Description#>
    private func obtainUniforms() {
        let lines = fragmentShader.source.components(separatedBy: ";")
        let uniformNames = lines.filter { $0.contains("uniform") }.map { $0.components(separatedBy: " ").last! }
        uniforms = uniformNames.reduce([String: Int32](), { [weak self] (namesAndLocations, uniformName) in
            var namesAndLocations = namesAndLocations
            if let programName = self?.name {
                namesAndLocations[uniformName] = glGetUniformLocation(programName, uniformName)
            }
            return namesAndLocations
        })
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - texture: <#texture description#>
    /// - Throws: <#throws value description#>
    private func modifyUniform<TextureType: GLObject>(named name: String,
                                                    withGeneric texture: TextureType) throws where TextureType: GLObjectUsable {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        let nonUsedTextureUnits = usedTextureUnits.symmetricDifference(GLProgram.availableTextureUnits)
        guard let textureUnit = nonUsedTextureUnits.first else {
            throw GLProgramError.tooManyUniformTextures
        }
        usedTextureUnits.insert(textureUnit)
        
        glActiveTexture(GLenum(GL_TEXTURE0 + textureUnit))
        glUniform1i(uniformLocation, textureUnit)
        texture.use()
    }
    
    /// <#Description#>
    public func use() {
        glUseProgram(name)
    }
    
    public func prepareForRendering() {
        usedTextureUnits.removeAll()
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - texture: <#texture description#>
    /// - Throws: <#throws value description#>
    public func modifyUniform(named name: String,
                              with texture: GLTexture2D) throws {
        try modifyUniform(named: name,
                          withGeneric: texture)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - texture: <#texture description#>
    /// - Throws: <#throws value description#>
    public func modifyUniform(named name: String,
                              with texture: GLTexture2DArray) throws {
        try modifyUniform(named: name,
                          withGeneric: texture)
    }
    
    public func modifyUniform(named name: String,
                              with value: Int) throws {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        glUniform1i(uniformLocation, GLint(value))
    }
    
    public func modifyUniform(named name: String,
                              with value: Float) throws {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        glUniform1f(uniformLocation, value)
    }
    
    public func modifyUniform(named name: String,
                              with vector: GLKVector2) throws {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        let vector = vector
        glUniform2fv(uniformLocation, 1, vector.primitiveSequence)
    }
    
    public func modifyUniform(named name: String,
                              with vector: GLKVector3) throws {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        let vector = vector
        glUniform3fv(uniformLocation,
                     1,
                     vector.primitiveSequence)
    }
    
    public func modifyUniform(named name: String,
                              with vector: GLKVector4) throws {
        guard let uniformLocation = uniforms[name] else {
            throw GLProgramError.nonexistentUniform
        }
        let vector = vector
        glUniform4fv(uniformLocation,
                     1,
                     vector.primitiveSequence)
    }
    
}
