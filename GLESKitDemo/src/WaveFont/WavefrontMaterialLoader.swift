//
//  WavefrontMaterialLoader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import GLESKit

internal class WavefrontMaterialLoader {
    
    private let fileReader: WavefrontMaterialReader
    private var materials: [WavefrontMaterial]
    
    init(name: String, bundle: Bundle) throws {
        fileReader = try WavefrontMaterialReader(fileName: name, type: "mtl", bundle: bundle)
        materials = [WavefrontMaterial]()
    }
    
    func loadMaterials() throws -> [WavefrontMaterial] {
        while fileReader.contentAvailable {
            let currentMaterial = materials.last
            
            switch try fileReader.readMarker() {
            case .newMaterial:
                let newMaterial = WavefrontMaterial()
                newMaterial.name = try fileReader.readToken(errorMessage: "Unable to read material name") as String?
                materials.append(newMaterial)
            case .ambientColor:
                currentMaterial!.ambientColor = try fileReader.readColor()
            case .diffuseColor:
                currentMaterial!.diffuseColor = try fileReader.readColor()
            case .specularColor:
                currentMaterial!.specularColor = try fileReader.readColor()
            case .emissiveColor:
                currentMaterial!.emissiveColor = try fileReader.readColor()
            case .opticalDensity:
                currentMaterial!.opticalDensity = try fileReader.readFloat(errorMessage: "Unable to read optical density")
            case .specularExponent:
                currentMaterial!.specularExponent = try fileReader.readFloat(errorMessage: "Unable to read specular exponent")
            case .illuminationModel:
                currentMaterial!.illuminationModel = try fileReader.readIlluminationModel()
            case .dissolve:
                currentMaterial!.dissolve = try fileReader.readFloat(errorMessage: "Unable to read dissolve component")
            case .transparency:
                currentMaterial!.transparency = try fileReader.readFloat(errorMessage: "Unable to read transparency value")
            case .transmissionFilter:
                currentMaterial!.transmissionFilter = try fileReader.readTransmissionFilter()
            case .ambientMap:
                let ambientMapName = try fileReader.readToken(errorMessage: "Unable to read ambient texture file name")
                currentMaterial!.ambientMap = try? GLTexture2D(resourceName: ambientMapName as String)
            case .diffuseMap:
                let diffuseMapName = try fileReader.readToken(errorMessage: "Unable to read diffuse texture file name")
                currentMaterial!.diffuseMap = try? GLTexture2D(resourceName: diffuseMapName as String)
            case .specularMap:
                let specularMapName = try fileReader.readToken(errorMessage: "Unable to read specular texture file name")
                currentMaterial!.specularMap = try? GLTexture2D(resourceName: specularMapName as String)
            case .specularExponentMap: // a.k.a specular highlight map
                let specularExponentMapName = try fileReader.readToken(errorMessage: "Unable to read specular exponent texture file name")
                currentMaterial!.specularExponentMap = try? GLTexture2D(resourceName: specularExponentMapName as String)
            case .alphaMap:
                let alphaMapName = try fileReader.readToken(errorMessage: "Unable to read alpha texture file name")
                currentMaterial!.alphaMap = try? GLTexture2D(resourceName: alphaMapName as String)
            case .bumpMap:
                let bumpMapName = try fileReader.readToken(errorMessage: "Unable to read bump texture file name")
                currentMaterial!.bumpMap = try? GLTexture2D(resourceName: bumpMapName as String)
            case .displacementMap:
                let displacementMapName = try fileReader.readToken(errorMessage: "Unable to displacement texture file name")
                currentMaterial!.displacementMap = try? GLTexture2D(resourceName: displacementMapName as String)
            case .stencilDecal:
                let stencilDecalTextureName = try fileReader.readToken(errorMessage: "Unable to stencil decal texture file name")
                currentMaterial!.stencilDecalMap = try? GLTexture2D(resourceName: stencilDecalTextureName as String)
            }
            
            fileReader.moveToNextLine()
        }
        
        return materials
    }
}
