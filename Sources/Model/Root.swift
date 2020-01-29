import GRPC
import NIO
import FlatBuffers
import Foundation

public protocol GRPCFlatBufPayload: GRPCPayload, FlatBufferObject {}

public extension GRPCFlatBufPayload {
    init(serializedByteBuffer: inout NIO.ByteBuffer) throws {
        let bb = FlatBuffers.ByteBuffer(data: serializedByteBuffer.readData(length: serializedByteBuffer.readableBytes)!)
        self.init(bb, o: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))
    }
    
    func serialize(into buffer: inout NIO.ByteBuffer) throws {
        buffer.writeBytes(data)
    }
}
