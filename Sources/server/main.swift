//
//  main.swift
//  GRPCserver
//
//  Created by Mustafa Khalil on 1/26/20.
//  Copyright © 2020 Mustafa Khalil. All rights reserved.
//

import GRPC
import NIO
import FlatBuffers
import Logging
import Model

class GreeterProvider: Helloworld_GreeterProvider {
  func sayHello(
    request: HelloFlatRequest,
    context: StatusOnlyCallContext
  ) -> EventLoopFuture<HelloFlatResponse> {
    print("server id")
    
    let recipient: String
    if let object = request.o?.name {
        recipient = object
    } else {
        recipient = "UNKNOWN ISSUE"
    }
    
    let builder = FlatBufferBuilder()
    let off = builder.create(string: recipient)
    let root = HelloReply.createHelloReply(builder, offsetOfMessage: off)
    builder.finish(offset: root)
    let response = HelloFlatResponse(data: builder.data)
    return context.eventLoop.makeSucceededFuture(response)
  }
}

// Quieten the logs.
LoggingSystem.bootstrap {
  var handler = StreamLogHandler.standardOutput(label: $0)
  handler.logLevel = .critical
  return handler
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
  try! group.syncShutdownGracefully()
}

// Create some configuration for the server:
let configuration = Server.Configuration(
  target: .hostAndPort("localhost", 0),
  eventLoopGroup: group,
  serviceProviders: [GreeterProvider()]
)

// Start the server and print its address once it has started.
let server = Server.start(configuration: configuration)
server.map {
  $0.channel.localAddress
}.whenSuccess { address in
  print("server started on port \(address!.port!)")
}

// Wait on the server's `onClose` future to stop the program from exiting.
_ = try server.flatMap {
  $0.onClose
}.wait()
