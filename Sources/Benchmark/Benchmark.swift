import Command
import DatabaseBenchmark
import LighterBenchmarks
#if os(macOS) || os(iOS)
import CoreDataBenchmarks
import GRDBBenchmarks
import SwiftDataBenchmarks
import Swizzle
#endif
import Tests
import VaporSQLiteBenchmarks

@main
struct DatabaseBenchmarks: TestsCommand {
 @Flag
 var breakOnError: Bool
 /// Include trivial benchmarks (JSON)
 @Flag
 var includeTrivial: Bool
 /// The scale of database operations (0.1-5)
 @Option
 var scale: Double?
 /// The scale of benchmark operations (1-5)
 @Option
 var pressure: Size?

 func setUp() throws {
  if let scale, scale > 0 {
   benchmarkScale = min(5, max(0.1, scale))
  }
  
  if let pressure {
   benchmarkPressure = benchmarkPressure > 5 ? 5 : pressure
  }
  
  let folder = Folder.current
  notify(
   """
   Current working directory is:
   \t\(folder, color: .extended(11), style: [.bold, .underlined])\n
   """,
   with: .info
  )

  #if os(macOS) || os(iOS)
  if Bundle.main.bundleIdentifier == nil {
   notify(
    """
    Swizzling \("`Bundle`", color: .extended(11), style: .bold) \
    to initialize \("`ModelContainer`", color: .extended(11), style: .bold)
    """,
    with: .info
   )

   try Swizzle(Bundle.self) {
    #selector(getter: $0.infoDictionary)
     <-> #selector(getter: $0.newInfoDictionary)
   }

   print()
  }
  #endif
 }

 var tests: some Testable {
  if includeTrivial {
   JSONBenchmarks()
  }
  #if os(macOS) || os(iOS)
  /*if Bundle.main.bundleIdentifier != nil {
   CoreDataBenchmarks()
  } else {
   Perform(detached: true) {
    print()
    notify(
     "skipping CoreData benchmarks\n\tBundle identifier unavailable",
     with: .notice
    )
   }
  }*/
  GRDBBenchmarks()
  #endif
  LighterBenchmarks()

  #if os(macOS) || os(iOS)

  if #available(macOS 14, iOS 17, *) {
   if Bundle.main.bundleIdentifier != nil {
    SwiftDataBenchmarks()
   } else {
    Perform(detached: true) {
     print()
     notify(
      "skipping SwiftData benchmarks\n\tBundle identifier unavailable",
      with: .notice
     )
    }
   }
  } else {
   Perform(detached: true) {
    print()
    notify(
     """
     skipping SwiftData benchmarks
     \tSwiftData supports macOS => 14 || iOS => 17 only
     """,
     with: .notice
    )
   }
  }
  #endif

  VaporSQLiteBenchmarks()
 }
}

#if os(Linux)
/// A test that calls `static func main()` with command and context support
public protocol TestsCommand: Tests & AsyncCommand {}
public extension TestsCommand {
 mutating func main() async throws {
  do { try await callAsTestFromContext() }
  catch {
   exit(Int32(error._code))
  }
 }
}
#endif
