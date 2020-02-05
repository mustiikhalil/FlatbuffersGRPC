//
//  File.swift
//  
//
//  Created by Mustafa Khalil on 2/1/20.
//
import Foundation
import FlatBuffers

public struct _Point_: Codable {
    public var latitude: Int32
    public var longitude: Int32
}

public struct _Feature_: Codable {
    public var name: String
    public var location: _Point_
}

///// Loads the features from `route_guide_db.json`, assumed to be in the directory above this file.
public func loadFeatures() throws -> [Feature] {
    let url = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()  // main.swift
        .deletingLastPathComponent()  // Server/
        .appendingPathComponent("route_guide_db.json")
    
    let data = try Data(contentsOf: url)
    let features = try JSONDecoder().decode([_Feature_].self, from: data)
    let builder = FlatBufferBuilder()
    var flatFeatures: [Feature] = []
    
    features.forEach { (f) in
        let str = builder.create(string: f.name)
        let point = Point.createPoint(builder, latitude: f.location.latitude, longitude: f.location.longitude)
        let feature = Feature.createFeature(builder, offsetOfName: str, offsetOfLocation: point)
        builder.finish(offset: feature)
        flatFeatures.append(Feature.getRootAsFeature(bb: builder.sizedBuffer))
        builder.clear()
    }
    return flatFeatures
}
