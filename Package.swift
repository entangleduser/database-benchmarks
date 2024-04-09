// swift-tools-version:5.9
import Foundation
import PackageDescription

let package = Package(
 name: "DatabaseBenchmarks",
 platforms: [.macOS(.v13), .iOS(.v16)],
 products: [
  .executable(name: "databaseBenchmarks", targets: ["Benchmark"]),
  .library(name: "DatabaseBenchmark", targets: ["DatabaseBenchmark"]),
  .library(name: "GRDBBenchmarks", targets: ["GRDBBenchmarks"]),
  .library(name: "LighterBenchmarks", targets: ["LighterBenchmarks"]),
  .library(name: "SwiftDataBenchmarks", targets: ["SwiftDataBenchmarks"]),
  .library(name: "VaporSQLiteBenchmarks", targets: ["VaporSQLiteBenchmarks"])
 ],
 dependencies: [
  .package(url: "https://github.com/acrlc/Core.git", branch: "main"),
  .package(url: "https://github.com/acrlc/Acrylic.git", branch: "main"),
  .package(url: "https://github.com/acrlc/Benchmarks.git", branch: "main"),
  /// manually sets a bundle identifier and name, so `SwiftData` can be used
  .package(url: "https://github.com/entangleduser/Swizzle.git", branch: "main"),
  /// for logging / printing text
//  .package(url: "https://github.com/acrlc/Configuration.git", branch: "main"),
   .package(path: "../../acrlc/Configuration"),
  /* MARK: - Database packages */
  /** had to rename `CSQLite` to `GRDBSQLite` to resolve conflict with
   `CSQLite` being used as a target name in `sqlite-nio` and `GRDB.swift` **/
  .package(
   url: "https://github.com/entangleduser/GRDB.swift.git",
   branch: "database-benchmarks"
  ),
  .package(url: "https://github.com/vapor/Vapor.git", from: "4.92.5"),
  .package(url: "https://github.com/Lighter-swift/Lighter.git", from: "1.2.4"),
  .package(url: "https://github.com/vapor/Fluent.git", branch: "main"),
  .package(
   url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"
  )
 ],
 targets: [
  .executableTarget(
   name: "Benchmark",
   dependencies: [
    "Core",
    "Swizzle",
    "Acrylic",
    .product(name: "Tests", package: "Acrylic"),
    "Benchmarks",
    "Configuration",
    "DatabaseBenchmark",
    "GRDBBenchmarks",
    "LighterBenchmarks",
    "SwiftDataBenchmarks",
    "VaporSQLiteBenchmarks"
   ]
  ),
  .target(
   name: "DatabaseBenchmark",
   dependencies: [
    "Acrylic",
    .product(name: "Tests", package: "Acrylic"),
    "Benchmarks",
    "Configuration"
   ]
  ),
  .target(
   name: "GRDBBenchmarks",
   dependencies: [
    .product(name: "GRDB", package: "GRDB.swift"),
    "DatabaseBenchmark"
   ]
  ),
  .target(
   name: "LighterBenchmarks",
   dependencies: [
    "Lighter",
    "DatabaseBenchmark"
   ],
   exclude: ["PeopleDB.sql"],
   resources: [.copy("PeopleDB-001.sqlite")],
   plugins: [.plugin(name: "Enlighter", package: "Lighter")]
  ),
  .target(
   name: "SwiftDataBenchmarks",
   dependencies: ["DatabaseBenchmark"]
  ),
  .target(
   name: "VaporSQLiteBenchmarks",
   dependencies: [
    "Vapor",
    "Fluent",
    .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
    "DatabaseBenchmark"
   ]
  )
 ]
)
