import DatabaseBenchmark
import struct Foundation.Date
import Lighter

public final class LighterBenchmarks: DatabaseBenchmark {
 var db: PeopleDB!

 public func prepare() async throws {
  let url = baseURL.appendingPathComponent(sqliteName)
  db = try await PeopleDB.bootstrap(at: url, readOnly: false, overwrite: false)
 }

 public func performInsert(id: Int, name: String) async throws {
  try await db.insert(Person(id: id, name: name))
 }

 public func performRemove(id: Int) async throws {
  try await db.delete(from: \.people, id: id)
 }

 public func performRemove(name: String) async throws {
  try await db.delete(from: \.people, where: \.name, is: name)
 }

 public func clear() async throws {
  try await db.delete(db.people.fetch())
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
