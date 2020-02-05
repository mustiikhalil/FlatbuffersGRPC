import GRPC
import NIO
import FlatBuffers

public protocol GRPCFlatBufPayload: GRPCPayload, FlatBufferObject {}

public extension GRPCFlatBufPayload {
    init(serializedByteBuffer: inout NIO.ByteBuffer) throws {
        let buf = FlatBuffers.ByteBuffer(bytes: Array(serializedByteBuffer.readableBytesView))
        self.init(buf, o: Int32(buf.read(def: UOffset.self, position: buf.reader)) + Int32(buf.reader))
    }
    
    func serialize(into buffer: inout NIO.ByteBuffer) throws {
        let buf = UnsafeRawBufferPointer(start: self.buffer!.memory.advanced(by: self.buffer.reader), count: Int(self.buffer.size))
        buffer.writeBytes(buf)
    }
}
