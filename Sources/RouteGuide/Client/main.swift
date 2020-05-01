/*
 * Copyright 2019, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import GRPC
import NIO
import Logging
import FlatBuffers
import FLATRouteGuideModel

// Quieten the logs.
LoggingSystem.bootstrap {
    var handler = StreamLogHandler.standardOutput(label: $0)
    handler.logLevel = .critical
    return handler
}

/// Makes a `RouteGuide` client for a service hosted on "localhost" and listening on the given port.
func makeClient(port: Int, group: EventLoopGroup) -> Routeguide_RouteGuideServiceClient {
  let channel = ClientConnection.insecure(group: group)
    .connect(host: "localhost", port: port)

  return Routeguide_RouteGuideServiceClient(channel: channel)
}

/// Unary call example. Calls `getFeature` and prints the response.
func getFeature(using client: Routeguide_RouteGuideServiceClient, latitude: Int, longitude: Int) {
    print("→ GetFeature: lat=\(latitude) lon=\(longitude)")
    var builder = FlatBufferBuilder()
    let root = Point.createPoint(&builder, latitude: Int32(latitude), longitude: Int32(longitude))
    builder.finish(offset: root)
    let call = client.getFeature(Message(builder: &builder))
    let message: Message<Feature>
    
    do {
        message = try call.response.wait()
    } catch {
        print("RPC failed: \(error)")
        return
    }
    let feature = message.object
    let lat = feature.location!.latitude
    let lon = feature.location!.longitude
    
    if !(feature.name?.isEmpty ?? false) {
        print("Found feature called '\(feature.name!)' at \(lat), \(lon)")
    } else {
        print("Found no feature at \(lat), \(lon)")
    }
}

/// Server-streaming example. Calls `listFeatures` with a rectangle of interest. Prints each
/// response feature as it arrives.
func listFeatures(
    using client: Routeguide_RouteGuideServiceClient,
    lowLatitude: Int,
    lowLongitude: Int,
    highLatitude: Int,
    highLongitude: Int
) {
    print("→ ListFeatures: lowLat=\(lowLatitude) lowLon=\(lowLongitude), hiLat=\(highLatitude) hiLon=\(highLongitude)")
    var builder = FlatBufferBuilder()
    let lo = Point.createPoint(&builder, latitude: Int32(lowLatitude), longitude: Int32(lowLongitude))
    let hi = Point.createPoint(&builder, latitude: Int32(highLatitude), longitude: Int32(highLongitude))
    let rec = Rectangle.createRectangle(&builder, offsetOfLo: lo, offsetOfHi: hi)
    builder.finish(offset: rec)
    var resultCount = 1
    let call = client.listFeatures(Message(builder: &builder)) { feature in
        print("Result #\(resultCount): \(feature.object)")
        resultCount += 1
    }
    
    let status = try! call.status.recover { _ in .processingError }.wait()
    if status.code != .ok {
        print("RPC failed: \(status)")
    }
}

/// Client-streaming example. Sends `featuresToVisit` randomly chosen points from `features` with
/// a variable delay in between. Prints the statistics when they are sent from the server.
public func recordRoute(
    using client: Routeguide_RouteGuideServiceClient,
    features: [Feature],
    featuresToVisit: Int
) {
    print("→ RecordRoute")
    let options = CallOptions(timeout: .minutes(rounding: 1))
    let call = client.recordRoute(callOptions: options)
    
    call.response.whenSuccess { o in
        let summary = o.object
        print(
            "Finished trip with \(summary.pointCount) points. Passed \(summary.featureCount) features. " +
            "Travelled \(summary.distance) meters. It took \(summary.elapsedTime) seconds."
        )
    }
    
    call.response.whenFailure { error in
        print("RecordRoute Failed: \(error)")
    }
    
    call.status.whenComplete { _ in
        print("Finished RecordRoute")
    }
    
    for _ in 0..<featuresToVisit {
        let index = Int.random(in: 0..<features.count)
        let point = features[index].location
        print("Visiting point \(point!.latitude), \(point!.longitude)")
        var builder = FlatBufferBuilder()
        let root = Point.createPoint(&builder, latitude: point!.latitude, longitude: point!.longitude)
        builder.finish(offset: root)
        call.sendMessage(Message(builder: &builder), promise: nil)
        
        // Sleep for a bit before sending the next one.
        Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.5..<1.5))
    }
    
    call.sendEnd(promise: nil)
    
    // Wait for the call to end.
    _ = try! call.status.wait()
}

/// Bidirectional example. Send some chat messages, and print any chat messages that are sent from
/// the server.
func routeChat(using client: Routeguide_RouteGuideServiceClient) {
    print("→ RouteChat")
    var builder = FlatBufferBuilder()
    let call = client.routeChat { object in
        let note = object.object
        print("Got message \"\(note.message!)\" at \(note.location!.latitude), \(note.location!.longitude)")
    }
    
    call.status.whenSuccess { status in
        if status.code == .ok {
            print("Finished RouteChat")
        } else {
            print("RouteChat Failed: \(status)")
        }
    }
    
    let noteContent = [
        ("First message", 0, 0),
        ("Second message", 0, 1),
        ("Third message", 1, 0),
        ("Fourth message", 1, 1)
    ]
    
    for (message, latitude, longitude) in noteContent {
        let str = builder.create(string: message)
        let location = Point.createPoint(&builder, latitude: Int32(latitude), longitude: Int32(longitude))
        let root = RouteNote.createRouteNote(&builder, offsetOfLocation: location, offsetOfMessage: str)
        builder.finish(offset: root)
        let note = RouteNote.getRootAsRouteNote(bb: builder.buffer)
        print("Sending message \"\(note.message!)\" at \(note.location!.latitude), \(note.location!.longitude)")
        call.sendMessage(Message(builder: &builder), promise: nil)
    }
    // Mark the end of the stream.
    call.sendEnd(promise: nil)
    
    // Wait for the call to end.
    _ = try! call.status.wait()
}

func main(args: [String]) throws {
    // arg0 (dropped) is the program name. We expect arg1 to be the port.
    guard case .some(let port) = args.dropFirst(1).first.flatMap(Int.init) else {
        print("Usage: \(args[0]) PORT")
        exit(1)
    }
    
    // Load the features.
    let features = try loadFeatures()
    
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    defer {
        try? group.syncShutdownGracefully()
    }
    
    // Make a client, make sure we close it when we're done.
    let routeGuide = makeClient(port: port, group: group)
    defer {
        try? routeGuide.channel.close().wait()
    }
    
    // Look for a valid feature.
    getFeature(using: routeGuide, latitude: 409146138, longitude: -746188906)
    
    // Look for a missing feature.
    getFeature(using: routeGuide, latitude: 0, longitude: 0)
    
    // Looking for features between 40, -75 and 42, -73.
    listFeatures(
        using: routeGuide,
        lowLatitude: 400000000,
        lowLongitude: -750000000,
        highLatitude: 420000000,
        highLongitude: -730000000
    )
    
    // Record a few randomly selected points from the features file.
    recordRoute(using: routeGuide, features: features, featuresToVisit: 10)
    
    // Send and receive some notes.
    routeChat(using: routeGuide)
}

try main(args: CommandLine.arguments)
