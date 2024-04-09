import DatabaseBenchmark
import GRDB

public final class GRDBBenchmarks: DatabaseBenchmark {
 var queue: DatabaseQueue!

 public func prepare() throws {
  let path =
   baseURL.appendingPathComponent(sqliteName).path(percentEncoded: false)
  let queue = try DatabaseQueue(path: path)

  try queue.write { db in
   try db.create(table: "person") { t in
    t.primaryKey("id", .integer).unique()
    t.column("name", .text).notNull()
    t.column("created", .date).notNull()
   }
  }
  self.queue = queue
 }

 public func performInsert(id: Int, name: String) async throws {
  try await queue.barrierWriteWithoutTransaction { db in
   try Person(id: id, name: name).insert(db)
  }
 }

 public func performRemove(id: Int) async throws {
  _ = try await queue.barrierWriteWithoutTransaction { db in
   if let model = try Person.fetchOne(db, key: id) {
    try model.delete(db)
   }
  }
 }

 public func performRemove(name: String) async throws {
  _ = try await queue.barrierWriteWithoutTransaction { db in
   for person in try Person.filter(Column("name") == name).fetchAll(db) {
    _ = try person.delete(db)
   }
  }
 }

 public func clear() async throws {
  try await queue.barrierWriteWithoutTransaction { db in
   for person in try Person.fetchAll(db) {
    _ = try person.delete(db)
   }
  }
 }

 public func count() throws -> Int {
  try queue.read { db in
   try Person.fetchCount(db)
  }
 }

 public func close() throws {
  try queue.close()
  queue = nil
 }

 public func remove() throws {
  try folder.file(named: sqliteName).delete()
 }

 public init() {}

 struct Person: Codable, FetchableRecord, PersistableRecord {
  var id: Int
  var name: String
  var created: Date = .now
 }
}
