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
import NIOConcurrencyHelpers
import FLATRouteGuideModel
import FlatBuffers

extension Point: Hashable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
}

class RouteGuideProvider: Routeguide_RouteGuideProvider {

  private let features: [Feature]
  private var notes: [Point: [RouteNote]] = [:]
  private var lock = Lock()

  init(features: [Feature]) {
    self.features = features
  }

  /// A simple RPC.
  ///
  /// Obtains the feature at a given position.
  ///
  /// A feature with an empty name is returned if there's no feature at the given position.
  func getFeature(
    request point: Message<Point>,
    context: StatusOnlyCallContext
  ) -> EventLoopFuture<Message<Feature>> {
    let buffer = point.object.__buffer
    let array = UnsafeMutableRawBufferPointer(start: buffer!.memory, count: Int(buffer!.size))
    print(Array(array))
//    p.__buffer.
    let check = self.checkFeature(at: point.object)
    return context.eventLoop.makeSucceededFuture(Message(byteBuffer: check.__buffer))
  }

  /// A server-to-client streaming RPC.
  ///
  /// Obtains the Features available within the given Rectangle. Results are streamed rather than
  /// returned at once (e.g. in a response message with a repeated field), as the rectangle may
  /// cover a large area and contain a huge number of features.
  func listFeatures(
    request: Message<Rectangle>,
    context: StreamingResponseCallContext<Message<Feature>>
  ) -> EventLoopFuture<GRPCStatus> {
    let req = request.object
    let left = min(req.lo!.longitude, req.hi!.longitude)
    let right = max(req.lo!.longitude, req.hi!.longitude)
    let top = max(req.lo!.latitude, req.hi!.latitude)
    let bottom = max(req.lo!.latitude, req.hi!.latitude)

    self.features.filter { (feature) -> Bool in
       guard let location = feature.location else { return false }
        return location.longitude >= left
            && location.longitude <= right
            && location.latitude >= bottom
            && location.latitude <= top
    }.forEach {
        _ = context.sendResponse(Message(byteBuffer: $0.__buffer))
    }

    return context.eventLoop.makeSucceededFuture(.ok)
  }

  /// A client-to-server streaming RPC.
  ///
  /// Accepts a stream of Points on a route being traversed, returning a RouteSummary when traversal
  /// is completed.
  func recordRoute(
    context: UnaryResponseCallContext<Message<RouteSummary>>
  ) -> EventLoopFuture<(StreamEvent<Message<Point>>) -> Void> {
    var pointCount: Int32 = 0
    var featureCount: Int32 = 0
    var distance = 0.0
    var previousPoint: Point?
    let startTime = Date()
    var builder = FlatBufferBuilder()
    return context.eventLoop.makeSucceededFuture({ event in
      switch event {
      case .message(let point):
        pointCount += 1
        if !(self.checkFeature(at: point.object).name?.isEmpty ?? true) {
          featureCount += 1
        }

        // For each point after the first, add the incremental distance from the previous point to
        // the total distance value.
        if let previous = previousPoint {
            distance += previous.distance(to: point.object)
        }
        previousPoint = point.object

      case .end:
        let seconds = Date().timeIntervalSince(startTime)
        let root = RouteSummary.createRouteSummary(&builder, pointCount: pointCount, featureCount: featureCount, distance: Int32(distance), elapsedTime: Int32(seconds))
        builder.finish(offset: root)
        context.responsePromise.succeed(Message(builder: &builder))
      }
    })
  }

  /// A Bidirectional streaming RPC.
  ///
  /// Accepts a stream of RouteNotes sent while a route is being traversed, while receiving other
  /// RouteNotes (e.g. from other users).
  func routeChat(
    context: StreamingResponseCallContext<Message<RouteNote>>
  ) -> EventLoopFuture<(StreamEvent<Message<RouteNote>>) -> Void> {
    return context.eventLoop.makeSucceededFuture({ event in
      switch event {
      case .message(let note):
        // Get any notes at the location of request note.
        var notes = self.lock.withLock {
            self.notes[note.object.location!, default: []]
        }

        // Respond with all previous notes at this location.
        for note in notes {
            _ = context.sendResponse(Message(byteBuffer: note.__buffer))
        }

        // Add the new note and update the stored notes.
        notes.append(note.object)
        self.lock.withLockVoid {
            self.notes[note.object.location!] = notes
        }

      case .end:
        context.statusPromise.succeed(.ok)
      }
    })
  }
}

extension RouteGuideProvider {
  private func getOrCreateNotes(for point: Point) -> [RouteNote] {
    return self.lock.withLock {
      self.notes[point, default: []]
    }
  }

  /// Returns a feature at the given location or an unnamed feature if none exist at that location.
  private func checkFeature(at location: Point) -> Feature {
    print("should be here: \(location.latitude), \(location.longitude)")
    for feature in self.features {
        if feature.location?.latitude == location.latitude && feature.location?.longitude == location.longitude {
            return feature
        }
    }
    return buildFeature(location: location)
  }
    
    private func buildFeature(location: Point) -> Feature {
        var builder = FlatBufferBuilder()
        let off = builder.create(string: "")
        let point = Point.createPoint(&builder, latitude: location.latitude, longitude: location.longitude)
        let root = Feature.createFeature(&builder, offsetOfName: off, offsetOfLocation: point)
        builder.finish(offset: root)
        return Feature.getRootAsFeature(bb: builder.sizedBuffer)
    }
}



fileprivate func degreesToRadians(_ degrees: Double) -> Double {
  return degrees * .pi / 180.0
}

fileprivate extension Point {
  func distance(to other: Point) -> Double {
    // Radius of Earth in meters
    let radius = 6_371_000.0
    // Points are in the E7 representation (degrees multiplied by 10**7 and rounded to the nearest
    // integer). See also `Point`.
    let coordinateFactor = 1.0e7

    let lat1 = degreesToRadians(Double(self.latitude) / coordinateFactor)
    let lat2 = degreesToRadians(Double(other.latitude) / coordinateFactor)
    let lon1 = degreesToRadians(Double(self.longitude) / coordinateFactor)
    let lon2 = degreesToRadians(Double(other.longitude) / coordinateFactor)

    let deltaLat = lat2 - lat1
    let deltaLon = lon2 - lon1

    let a = sin(deltaLat / 2) * sin(deltaLat / 2)
      + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return radius * c
  }
}
