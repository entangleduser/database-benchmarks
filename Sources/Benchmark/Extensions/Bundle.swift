#if os(macOS) || os(iOS)
import Foundation

@objc
extension Bundle {
 var newInfoDictionary: [String: Any]? {
  [
   kIOBundleIdentifierKey: "acrylic.database-benchmarks",
   kIOBundleNameKey: "DatabaseBenchmarks"
  ]
 }
}
#endif
