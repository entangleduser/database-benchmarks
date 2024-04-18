@_exported import Acrylic
import Benchmarks
@_exported import Configuration
@_exported import Tests

public let notify: Configuration = .default
public let folder = Folder.current
public let baseURL = folder.url

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
 internal static var name: String {
  String(describing: Self.self).replacingOccurrences(of: "Benchmarks", with: "")
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

 @Modular
 var tests: some Testable {
  get async throws {
   Perform.Async("Prepare \(Self.name)") { try await self.prepare() }
   Benchmark("\(Self.name) Insert") {
    Measure.Async("Insert", warmup: 33, iterations: 444) {
     try await blackHole(performInsert(id: .zero, name: "Kevin"))
    } onCompletion: {
     try await performRemove(id: .zero)
    }
   }

   Benchmark("\(Self.name) Remove") {
    Measure.Async("Remove", warmup: 33, iterations: 444) {
     try await blackHole(performRemove(id: .zero))
    } onCompletion: {
     try await performInsert(id: .zero, name: "Kevin")
    }
   }

   Perform.Async("Clear", action: clear)
   Identity("Empty Database", count) == .zero

   Perform.Async(
    "Check Insert",
    action: { try await performInsert(id: .zero, name: "William") }
   )
   Identity("Count One", count) == 1

   Perform.Async("Check Remove", action: { try await performRemove(id: .zero)
   })

   Identity("Count Zero", count) == .zero

   Benchmark("\(Self.name) Insert 111") {
    Measure.Async("Insert", warmup: 1, iterations: 11) {
     for int in 0 ..< 111 {
      try await blackHole(performInsert(id: int, name: "Jasmine"))
     }
    } onCompletion: {
     for int in 0 ..< 111 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove 111") {
    Measure.Async("Insert", warmup: 1, iterations: 11) {
     for int in 0 ..< 111 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< 111 {
      try await performInsert(id: int, name: "Jade")
     }
    }
   }

   Identity("Count 111", count) == 111
   Perform.Async(detached: true, action: clear)

   Benchmark("\(Self.name) Insert 333") {
    Measure.Async("Insert", iterations: 3) {
     for int in 0 ..< 333 {
      try await blackHole(performInsert(id: int, name: "Jade"))
     }
    } onCompletion: {
     for int in 0 ..< 333 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove 333") {
    Measure.Async("Insert", iterations: 3) {
     for int in 0 ..< 333 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< 333 {
      try await performInsert(id: int, name: "Jade")
     }
    }
   }

   Identity("Count 333", count) == 333
   Perform.Async(detached: true, action: clear)

   Benchmark("\(Self.name) Insert 777") {
    Measure.Async("Insert", iterations: 3) {
     for int in 0 ..< 777 {
      try await blackHole(performInsert(id: int, name: "Frank"))
     }
    } onCompletion: {
     for int in 0 ..< 777 {
      try await performRemove(id: int)
     }
    }
   }

   Benchmark("\(Self.name) Remove 777") {
    Measure.Async("Insert", iterations: 3) {
     for int in 0 ..< 777 {
      try await blackHole(performRemove(id: int))
     }
    } onCompletion: {
     for int in 0 ..< 777 {
      try await performInsert(id: int, name: "Frank")
     }
    }
   }

   Identity("Count 777", count) == 777

   Blackhole("\(Self.name) Remove User Frank") {
    try await performRemove(name: "Frank")
   }

   // FIXME: the database should bottom out here
   // after removing the only name that should be in the database
   // Identity("Empty Database", count) == .zero

   try await benchmarks

   Perform.Async("Close Database", action: close)
   Perform("Remove Database", action: remove)
  }
 }

 // if an error is thrown, ensure database is closed and files are removed
 func cleanUp() async throws {
  try? await close()
  try? remove()
 }
}
