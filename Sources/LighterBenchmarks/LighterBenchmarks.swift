import DatabaseBenchmark
import struct Foundation.Date
import Lighter

public final class LighterBenchmarks: DatabaseBenchmark {
 var db: PeopleDB!

 public func prepare() async throws {
  let url = baseURL.appendingPathComponent(sqliteName)
  db = try await PeopleDB.bootstrap(at: url)
 }

 @MainActor
 public func performInsert(id: Int, name: String) throws {
   try db.insert(Person(id: id, name: name))
 }

 @MainActor
 public func performRemove(id: Int) throws {
  try db.delete(from: \.people, id: id)
 }

 @MainActor
 public func performRemove(name: String) throws {
  try db.delete(from: \.people, where: \.name, is: name)
 }

 @MainActor
 public func clear() throws {
  try db.delete(db.people.fetch())
 }

 // FIXME: incorrect count
 // seems to be caused by every value not being removed
 // TODO: investigate removal methods above
 public func count() async throws -> Int {
  try await db.people.fetchCount()
 }

 public func close() throws {
  (db.connectionHandler as! SQLConnectionHandler.SimplePool)
   .closePooledConnections()
  db = nil
 }

 public func remove() throws {
  try folder.file(named: sqliteName).delete()
  // note: could be here in some cases
  try? folder.file(named: sqliteName + "-journal").delete()
 }

 public init() {}
}

extension Person {
 init(id: Int, name: String) {
  self.init(
   id: id, name: name, created: Int(Date.timeIntervalSinceReferenceDate * 10e8)
  )
 }

 var added: Date {
  Date(timeIntervalSinceReferenceDate: Double(created) / 10e8)
 }
}
