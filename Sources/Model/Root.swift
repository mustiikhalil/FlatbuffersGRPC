import GRPC
import SwiftProtobuf
import FlatBuffers
import Foundation

protocol Root: Message {
    associatedtype T
    var o: T! { get }
    var data: Data! { get set }
    mutating func getRoot(grpcData: Data)
}

enum FlatbufferErrors: Error {
    case emptyData
}
