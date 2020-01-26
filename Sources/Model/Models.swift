//
//  Models.swift
//  GRPCserver
//
//  Created by Mustafa Khalil on 1/26/20.
//  Copyright © 2020 Mustafa Khalil. All rights reserved.
//

import GRPC
import SwiftProtobuf
import FlatBuffers
import Foundation

public struct HelloFlatRequest: Message {
    typealias T = HelloRequest
    public var o: HelloRequest!
    public var data: Data!
    
    public static var protoMessageName: String { "HelloFlatRequest" }
    public var unknownFields: UnknownStorage
    
    public init(data _data: Data) { unknownFields = UnknownStorage(); data = _data }
    public init() { unknownFields = UnknownStorage() }
    
    public mutating func getRoot(grpcData: Data) {
        o = HelloRequest.getRootAsHelloRequest(bb: ByteBuffer(data: grpcData))
    }
    
    mutating public func decodeMessage<D>(decoder: inout D) throws where D : Decoder {
        print("Decode")
    }

    public func traverse<V>(visitor: inout V) throws where V : Visitor {
        print("traverse")
    }
    
    func serializedData(partial: Bool = false) throws -> Data {
        if !partial {
            throw BinaryEncodingError.missingRequiredFields
        }
        print("SHOULD BE HERE!!")
        return data
    }
    
    public mutating func merge(serializedData data: Data, extensions: ExtensionMap? = nil, partial: Bool = false, options: BinaryDecodingOptions = BinaryDecodingOptions()) throws {
        guard !data.isEmpty else {
            throw FlatbufferErrors.emptyData
        }
        getRoot(grpcData: data)
    }

    public func isEqualTo(message: Message) -> Bool { return message.unknownFields == unknownFields  }
}

public struct HelloFlatResponse: Message {
    public var data: Data!
    
    typealias T = HelloReply
    public var o: HelloReply!
    
    public static var protoMessageName: String { "HelloFlatResponse" }
    public var unknownFields: UnknownStorage
    
    
    public init(data _data: Data) { unknownFields = UnknownStorage(); data = _data }
    public init() { unknownFields = UnknownStorage() }
    
    public mutating func getRoot(grpcData: Data) {
        o = HelloReply.getRootAsHelloReply(bb: ByteBuffer(data: grpcData))
    }
    
    public mutating func merge(serializedData data: Data, extensions: ExtensionMap? = nil, partial: Bool = false, options: BinaryDecodingOptions = BinaryDecodingOptions()) throws {
        guard !data.isEmpty else {
            throw FlatbufferErrors.emptyData
        }
        print("Merge")
        getRoot(grpcData: data)
    }
    
    func serializedData(partial: Bool = false) throws -> Data {
        if !partial {
            throw BinaryEncodingError.missingRequiredFields
        }
        print("SHOULD BE HERE!!")
        return data
    }
    
    mutating public func decodeMessage<D>(decoder: inout D) throws where D : Decoder {}

    public func traverse<V>(visitor: inout V) throws where V : Visitor {
        try visitor.visitSingularBytesField(value: data, fieldNumber: 1)
    }

    public func isEqualTo(message: Message) -> Bool { return message.unknownFields == unknownFields }
}


public struct HelloRequest: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsHelloRequest(bb: ByteBuffer) -> HelloRequest { return HelloRequest(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var name: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
    public var nameSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
    public static func startHelloRequest(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    public static func add(name: Offset<String>, _ fbb: FlatBufferBuilder) { fbb.add(offset: name, at: 0)  }
    public static func endHelloRequest(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
    public static func createHelloRequest(_ fbb: FlatBufferBuilder,
        offsetOfName name: Offset<String> = Offset()) -> Offset<UOffset> {
        let start = HelloRequest.startHelloRequest(fbb)
        HelloRequest.add(name: name, fbb)
        return HelloRequest.endHelloRequest(fbb, start: start)
    }
}

public struct HelloReply: FlatBufferObject {
    private var _accessor: Table
    public static func getRootAsHelloReply(bb: ByteBuffer) -> HelloReply { return HelloReply(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

    private init(_ t: Table) { _accessor = t }
    public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

    public var message: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
    public var messageSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
    public static func startHelloReply(_ fbb: FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
    public static func add(message: Offset<String>, _ fbb: FlatBufferBuilder) { fbb.add(offset: message, at: 0)  }
    public static func endHelloReply(_ fbb: FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
    public static func createHelloReply(_ fbb: FlatBufferBuilder,
        offsetOfMessage message: Offset<String> = Offset()) -> Offset<UOffset> {
        let start = HelloReply.startHelloReply(fbb)
        HelloReply.add(message: message, fbb)
        return HelloReply.endHelloReply(fbb, start: start)
    }
}

