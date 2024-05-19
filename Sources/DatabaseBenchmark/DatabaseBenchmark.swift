@_spi(ModuleReflection) import Acrylic
@_exported import Acrylic
@_exported import Benchmarks
@_exported import Configuration
@_exported import Paths
@_exported import Tests
@_exported import struct Time.Size
import struct Foundation.URL

public let notify: Configuration = .default
public let folder = Folder.current
public let baseURL = folder.url
public var benchmarkScale: Double = 2
public var benchmarkPressure: Size = 2

public protocol DatabaseBenchmark: Tests {
 func prepare() async throws
 func performInsert(id: Int, name: String) async throws
 func performRemove(id: Int) async throws
 func performRemove(name: String) async throws

 func clear() async throws
 func count() async throws -> Int
 func close() async throws
 func remove() throws

 associatedtype ExtendedBenchmarks: Testable

 @Modular
 var benchmarks: ExtendedBenchmarks { get async throws }
}

public extension DatabaseBenchmark {
 @usableFromInline
 internal static var name: String {
  var typeName = typeConstructorName
  let suffixes = ["Benchmarks", "Benchmark"]
  
  for suffix in suffixes where typeName.hasSuffix(suffix) {
   guard typeName != suffix else { return suffix }
   
   let startIndex = typeName.index(typeName.endIndex, offsetBy: -suffix.count)
   
   typeName.removeSubrange(startIndex...)
   typeName.append(" \(suffix)")
   break
  }
  return typeName
 }

 var testName: String? {
  Self.name
 }
 

 var sqliteName: String {
  "\(Self.self).sqlite"
 }

 func setUp() throws {
  try? remove()
 }

 @_disfavoredOverload
 @Modular
 var benchmarks: some Testable {
  EmptyModule()
 }

 var scale1: Int { Int(45 * benchmarkScale) }
 var scale2: Int { Int(67 * benchmarkScale) }
 var scale3: Int { Int(89 * benchmarkScale) }

 @Modular
 var tests: some Testable {
  get async throws {
   Perform.Async("Prepare \(Self.name)") { try await self.prepare() }
   Benchmark("\(Self.name) Insert") {
    Measure.Async(
     "Insert",
     warmup: 11 * benchmarkPressure,
     iterations: 222 * benchmarkPressure
    ) {
     try await blackHole(performInsert(id: .zero, name: "Kevin"))
    } onCompletion: {
     try await performRemove(id: .zero)
    }
   }

   Benchmark("\(Self.name) Remove") {
    Measure.Async(
     "Remove",
     warmup: 11 * benchmarkPressure,
     iterations: 222 * benchmarkPressure
    ) {
     try await blackHole(performRemove(id: .zero))
    } onCompletion: {
     try await performInsert(id: .zero, name: "Kevin")
    }
   }

   Perform.Async("Clear", action: { try await clear() })
   await Identity("Empty Database") { try await count() } == .zero

   Perform.Async(
    "Check Insert",
    action: { try await performInsert(id: .zero, name: "William") }
   )
   await Identity("Count One") { try await count() } == 1

   Perform.Async("Check Remove", action: { try await performRemove(id: .zero) })

   await Identity("Count Zero") { try await count() } == .zero

   Benchmark("\(Self.name) Insert \(scale1)") {
    Measure.Async(
     "Insert",
     warmup: 1 * benchmarkPressure,
     iterations: 5 * benchmarkPressure
    ) {
     for int in 0 ..< scale1 {
      try await blackHole(performInsert(id: int, name: "Jasmine"))
     }
    } onCompletion: {
     for int in 0 ..< scale1 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove \(scale1)") {
    Measure.Async(
     "Remove",
     warmup: 1 * benchmarkPressure,
     iterations: 5 * benchmarkPressure
    ) {
     for int in 0 ..< scale1 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< scale1 {
      try await performInsert(id: int, name: "Jade")
     }
    }
   }

   await Identity("Count \(scale1)") { try await count() } == scale1
   Perform.Async(detached: true, action: { try await clear() })

   Benchmark("\(Self.name) Insert \(scale2)") {
    Measure.Async("Insert", iterations: 3 * benchmarkPressure) {
     for int in 0 ..< scale2 {
      try await blackHole(performInsert(id: int, name: "Jade"))
     }
    } onCompletion: {
     for int in 0 ..< scale2 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove \(scale2)") {
    Measure.Async("Remove", iterations: 3 * benchmarkPressure) {
     for int in 0 ..< scale2 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< scale2 {
      try await performInsert(id: int, name: "Jade")
     }
    }
   }

   await Identity("Count \(scale2)") { try await count() } == scale2
   Perform.Async(detached: true, action: { try await clear() })

   Benchmark("\(Self.name) Insert \(scale3)") {
    Measure.Async("Insert", iterations: 1 * benchmarkPressure) {
     for int in 0 ..< scale3 {
      try await blackHole(performInsert(id: int, name: "Frank"))
     }
    } onCompletion: {
     for int in 0 ..< scale3 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove \(scale3)") {
    Measure.Async("Remove", iterations: 1 * benchmarkPressure) {
     for int in 0 ..< scale3 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< scale3 {
      try await performInsert(id: int, name: "Frank")
     }
    }
   }

   await Identity("Count \(scale3)") { try await count() } == scale3

   Blackhole("\(Self.name) Remove User Frank") {
    try await performRemove(name: "Frank")
   }

   // FIXME: the database should bottom out here
   // after removing the only name that should be in the database
   // Identity("Empty Database", count) == .zero

   try await benchmarks

   Perform.Async("Close Database", action: { try await close() })
   Perform("Remove Database", action: { try remove() })
  }
 }

 // if an error is thrown, ensure database is closed and files are removed
 func cleanUp() async throws {
  try? await close()
  try? remove()
 }
}

// MARK: Size Extensions
extension Size: LosslessStringConvertible {
 public init?(_ description: String) {
  self.init(stringValue: description)
 }
}
