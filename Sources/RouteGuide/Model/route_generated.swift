// automatically generated by the FlatBuffers compiler, do not modify

import FlatBuffers

public struct Point: FlatBufferObject {
    
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
	private var _accessor: Table
	public static func getRootAsPoint(bb: ByteBuffer) -> Point { return Point(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var latitude: Int32 { let o = _accessor.offset(4); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public var longitude: Int32 { let o = _accessor.offset(6); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public static func startPoint(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 2) }
	public static func add(latitude: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: latitude, def: 0, at: 0) }
	public static func add(longitude: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: longitude, def: 0, at: 1) }
	public static func endPoint(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createPoint(_ fbb: inout FlatBufferBuilder,
		latitude: Int32 = 0,
		longitude: Int32 = 0) -> Offset<UOffset> {
		let start = Point.startPoint(&fbb)
		Point.add(latitude: latitude, &fbb)
		Point.add(longitude: longitude, &fbb)
		return Point.endPoint(&fbb, start: start)
	}
}

public struct Rectangle: FlatBufferObject {
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
	private var _accessor: Table
	public static func getRootAsRectangle(bb: ByteBuffer) -> Rectangle { return Rectangle(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var lo: Point? { let o = _accessor.offset(4); return o == 0 ? nil : Point(_accessor.bb, o: _accessor.indirect(o + _accessor.postion)) }
	public var hi: Point? { let o = _accessor.offset(6); return o == 0 ? nil : Point(_accessor.bb, o: _accessor.indirect(o + _accessor.postion)) }
	public static func startRectangle(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 2) }
	public static func add(lo: Offset<UOffset>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: lo, at: 0)  }
	public static func add(hi: Offset<UOffset>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: hi, at: 1)  }
	public static func endRectangle(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createRectangle(_ fbb: inout FlatBufferBuilder,
		offsetOfLo lo: Offset<UOffset> = Offset(),
		offsetOfHi hi: Offset<UOffset> = Offset()) -> Offset<UOffset> {
		let start = Rectangle.startRectangle(&fbb)
		Rectangle.add(lo: lo, &fbb)
		Rectangle.add(hi: hi, &fbb)
		return Rectangle.endRectangle(&fbb, start: start)
	}
}

public struct Feature: FlatBufferObject {
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
	private var _accessor: Table
	public static func getRootAsFeature(bb: ByteBuffer) -> Feature { return Feature(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var name: String? { let o = _accessor.offset(4); return o == 0 ? nil : _accessor.string(at: o) }
	public var nameSegmentArray: [UInt8]? { return _accessor.getVector(at: 4) }
	public var location: Point? { let o = _accessor.offset(6); return o == 0 ? nil : Point(_accessor.bb, o: _accessor.indirect(o + _accessor.postion)) }
	public static func startFeature(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 2) }
	public static func add(name: Offset<String>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: name, at: 0)  }
	public static func add(location: Offset<UOffset>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: location, at: 1)  }
	public static func endFeature(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createFeature(_ fbb: inout FlatBufferBuilder,
		offsetOfName name: Offset<String> = Offset(),
		offsetOfLocation location: Offset<UOffset> = Offset()) -> Offset<UOffset> {
		let start = Feature.startFeature(&fbb)
		Feature.add(name: name, &fbb)
		Feature.add(location: location, &fbb)
		return Feature.endFeature(&fbb, start: start)
	}
}

public struct Features: FlatBufferObject {
    
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
	private var _accessor: Table
	public static func getRootAsFeatures(bb: ByteBuffer) -> Features { return Features(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var featureCount: Int32 { let o = _accessor.offset(4); return o == 0 ? 0 : _accessor.vector(count: o) }
	public func feature(at index: Int32) -> Feature? { let o = _accessor.offset(4); return o == 0 ? nil : Feature(_accessor.bb, o: _accessor.indirect(_accessor.vector(at: o) + index * 4)) }
	public static func startFeatures(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 1) }
	public static func addVectorOf(feature: Offset<UOffset>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: feature, at: 0)  }
	public static func endFeatures(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createFeatures(_ fbb: inout FlatBufferBuilder,
		vectorOfFeature feature: Offset<UOffset> = Offset()) -> Offset<UOffset> {
		let start = Features.startFeatures(&fbb)
		Features.addVectorOf(feature: feature, &fbb)
		return Features.endFeatures(&fbb, start: start)
	}
}

public struct RouteNote: FlatBufferObject {
    
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
    
	private var _accessor: Table
	public static func getRootAsRouteNote(bb: ByteBuffer) -> RouteNote { return RouteNote(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var location: Point? { let o = _accessor.offset(4); return o == 0 ? nil : Point(_accessor.bb, o: _accessor.indirect(o + _accessor.postion)) }
	public var message: String? { let o = _accessor.offset(6); return o == 0 ? nil : _accessor.string(at: o) }
	public var messageSegmentArray: [UInt8]? { return _accessor.getVector(at: 6) }
	public static func startRouteNote(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 2) }
	public static func add(location: Offset<UOffset>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: location, at: 0)  }
	public static func add(message: Offset<String>, _ fbb: inout FlatBufferBuilder) { fbb.add(offset: message, at: 1)  }
	public static func endRouteNote(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createRouteNote(_ fbb: inout FlatBufferBuilder,
		offsetOfLocation location: Offset<UOffset> = Offset(),
		offsetOfMessage message: Offset<String> = Offset()) -> Offset<UOffset> {
		let start = RouteNote.startRouteNote(&fbb)
		RouteNote.add(location: location, &fbb)
		RouteNote.add(message: message, &fbb)
		return RouteNote.endRouteNote(&fbb, start: start)
	}
}

public struct RouteSummary: FlatBufferObject {
    
    public var __buffer: ByteBuffer! { return _accessor.bb }
    public var position: Int! { Int(_accessor.postion) }
    
	private var _accessor: Table
	public static func getRootAsRouteSummary(bb: ByteBuffer) -> RouteSummary { return RouteSummary(Table(bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))) }

	private init(_ t: Table) { _accessor = t }
	public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

	public var pointCount: Int32 { let o = _accessor.offset(4); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public var featureCount: Int32 { let o = _accessor.offset(6); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public var distance: Int32 { let o = _accessor.offset(8); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public var elapsedTime: Int32 { let o = _accessor.offset(10); return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o) }
	public static func startRouteSummary(_ fbb: inout FlatBufferBuilder) -> UOffset { fbb.startTable(with: 4) }
	public static func add(pointCount: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: pointCount, def: 0, at: 0) }
	public static func add(featureCount: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: featureCount, def: 0, at: 1) }
	public static func add(distance: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: distance, def: 0, at: 2) }
	public static func add(elapsedTime: Int32, _ fbb: inout FlatBufferBuilder) { fbb.add(element: elapsedTime, def: 0, at: 3) }
	public static func endRouteSummary(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset<UOffset> { let end = Offset<UOffset>(offset: fbb.endTable(at: start)); return end }
	public static func createRouteSummary(_ fbb: inout FlatBufferBuilder,
		pointCount: Int32 = 0,
		featureCount: Int32 = 0,
		distance: Int32 = 0,
		elapsedTime: Int32 = 0) -> Offset<UOffset> {
		let start = RouteSummary.startRouteSummary(&fbb)
		RouteSummary.add(pointCount: pointCount, &fbb)
		RouteSummary.add(featureCount: featureCount, &fbb)
		RouteSummary.add(distance: distance, &fbb)
		RouteSummary.add(elapsedTime: elapsedTime, &fbb)
		return RouteSummary.endRouteSummary(&fbb, start: start)
	}
}

