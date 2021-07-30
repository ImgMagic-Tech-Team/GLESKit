//
//  WavefrontObjectLoader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import GLKit

fileprivate class TemporaryModelDataContainer {
    var positions = [GLKVector4]()
    var textureCoordinates = [GLKVector3]()
    var normals = [GLKVector3]()
    var materials = [String: WavefrontMaterial]()
}

public class WavefrontObjectLoader {
    
    private let fileReader: WavefrontGeometryReader
    private let model: WavefrontGroup
    private let temporaryModelData: TemporaryModelDataContainer
    
    public init(modelName: String, bundle: Bundle = Bundle.main) throws {
        fileReader = try WavefrontGeometryReader(fileName: modelName, type: "obj", bundle: bundle)
        model = WavefrontGroup()
        temporaryModelData = TemporaryModelDataContainer()
    }
    
    public func loadModel() throws -> WavefrontGroup {
        while fileReader.contentAvailable {
            switch try fileReader.readMarker() {
            case .vertex:
                let position = try fileReader.readVertexPosition()
                model.vertices.append(WavefrontVertex(position: position))
                temporaryModelData.positions.append(position)
                
            case .textureCoordinates:
                temporaryModelData.textureCoordinates.append(try fileReader.readTextureCoordinates())
                
            case .normal:
                temporaryModelData.normals.append(try fileReader.readNormal())
                
            case .face:
                let face = try fileReader.readFace()
                for indexSet in face.indexSets {
                    var normalizedPositionIndex = normalizeIndex(index: indexSet.positionIndex, totalAmount: temporaryModelData.positions.count)
                    model.vertices[normalizedPositionIndex].position = temporaryModelData.positions[normalizedPositionIndex]
                    
                    // Texture coordinates are optional
                    if let index = indexSet.textureCoordinateIndex {
                        let normalizedTextureCoodinatesIndex = normalizeIndex(index: index, totalAmount: temporaryModelData.textureCoordinates.count)
                        model.vertices[normalizedPositionIndex].textureCoordinates = temporaryModelData.textureCoordinates[normalizedTextureCoodinatesIndex]
                    }
                    
                    // As well as normals
                    if let index = indexSet.normalIndex {
                        let normalizedNormalIndex = normalizeIndex(index: index, totalAmount: temporaryModelData.normals.count)
                        model.vertices[normalizedPositionIndex].normal = temporaryModelData.normals[normalizedNormalIndex]
                    }
                    
                    model.indices.append(GLushort(normalizedPositionIndex))
                }
                
            case .object: print("object")
            case .group: print("group")
            case .materialLibrary:
                let libraryName = try fileReader.readMaterialLibraryName()
                if let materialLoader = try? WavefrontMaterialLoader(name: libraryName, bundle: fileReader.bundle) {
                    temporaryModelData.materials = try materialLoader.loadMaterials().reduce([String: WavefrontMaterial](), { (map, material) -> [String: WavefrontMaterial] in
                        var map = map
                        map[material.name] = material
                        return map
                    })
                }
                
            case .materialName:
                let materialName = try fileReader.readToken() as String
                model.material = temporaryModelData.materials[materialName]
            case .smoothShading: print("smoothShading")
            case .comment: break
            }
            
            fileReader.moveToNextLine()
        }
        
        return model
    }
    
    private func normalizeIndex(index: Int, totalAmount: Int) -> Int {
        if index == 0 {
            return index
        }
        
        if index > 0 {
            return index - 1
        }
        
        return index - totalAmount - 1
    }
}
