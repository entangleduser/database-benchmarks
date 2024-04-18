// swift-tools-version:5.9
import Foundation
import PackageDescription

let package = Package(
 name: "DatabaseBenchmarks",
 platforms: [.macOS(.v13), .iOS(.v16)],
 products: [
  .executable(name: "databaseBenchmarks", targets: ["Benchmark"]),
  .library(name: "DatabaseBenchmark", targets: ["DatabaseBenchmark"]),
  .library(name: "LighterBenchmarks", targets: ["LighterBenchmarks"]),
  .library(name: "VaporSQLiteBenchmarks", targets: ["VaporSQLiteBenchmarks"])
 ],
 dependencies: [
  .package(url: "https://github.com/acrlc/Core.git", branch: "main"),
   .package(url: "https://github.com/acrlc/Acrylic.git", branch: "main"),
  .package(url: "https://github.com/acrlc/Benchmarks.git", branch: "main"),
  /// for logging / printing text
  .package(url: "https://github.com/acrlc/Configuration.git", branch: "main"),
  /* MARK: - Cross Platform Dependencies */
  .package(url: "https://github.com/vapor/Vapor.git", from: "4.92.5"),
  .package(
   url: "https://github.com/entangleduser/Lighter.git",
   branch: "fix-linux-compatibility"
  ),
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
    "Acrylic",
    .product(name: "Tests", package: "Acrylic"),
    "Benchmarks",
    "Configuration",
    "DatabaseBenchmark",
    "LighterBenchmarks",
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

/* MARK: - Platform Dependencies */

#if os(macOS) || os(iOS)
package.dependencies.append(
 contentsOf: [
  /// manually sets a bundle identifier and name, so `SwiftData` can be used
  .package(url: "https://github.com/entangleduser/Swizzle.git", branch: "main"),
  /** had to rename `CSQLite` to `CSQLite_GRDB` to resolve conflict with
   `CSQLite` being used as a target name in `sqlite-nio` and `GRDB.swift` **/
  .package(
   url: "https://github.com/entangleduser/GRDB.swift.git",
   branch: "database-benchmarks"
  )
 ]
)
package.targets.append(
 contentsOf: [
  .target(
   name: "GRDBBenchmarks",
   dependencies: [
    .product(name: "GRDB", package: "GRDB.swift"),
    "DatabaseBenchmark"
   ]
  ),
  .target(
   name: "SwiftDataBenchmarks",
   dependencies: ["DatabaseBenchmark"]
  )
 ]
)

for target in package.targets {
 if target.name == "Benchmark" {
  target.dependencies += ["GRDBBenchmarks", "SwiftDataBenchmarks", "Swizzle"]
  break
 }
}

package.products.append(
 contentsOf: [
  .library(name: "GRDBBenchmarks", targets: ["GRDBBenchmarks"]),
  .library(name: "SwiftDataBenchmarks", targets: ["SwiftDataBenchmarks"])
 ]
)
#endif
