import DatabaseBenchmark
import LighterBenchmarks
#if os(macOS) || os(iOS)
import GRDBBenchmarks
import SwiftDataBenchmarks
import Swizzle
#endif
import Tests
import VaporSQLiteBenchmarks

@main
struct DatabaseBenchmarks: StaticTests {
 func setUp() throws {
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

   try Swizzle(Bundle.self) { Bundle in
    #selector(getter: Bundle.infoDictionary)
     <-> #selector(getter: Bundle.newInfoDictionary)
   }

   print()
  }
  #endif
 }

 var tests: some Testable {
  JSONBenchmarks()
  #if os(macOS) || os(iOS)
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
