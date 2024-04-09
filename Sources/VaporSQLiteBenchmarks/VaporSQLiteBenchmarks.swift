import DatabaseBenchmark
import Fluent
import FluentSQLiteDriver
import Vapor

public final class VaporSQLiteBenchmarks: DatabaseBenchmark {
 var app: Application!
 var db: Database!

 public func prepare() async throws {
  var env = Environment.production
  let path =
   baseURL.appendingPathComponent(sqliteName).path(percentEncoded: false)
  try LoggingSystem.bootstrap(from: &env)
  // note: calling in xcode produces a warning about setting a custom directory
  let app = Application(env)
  app.logger.logLevel = .error
  app.databases.use(.sqlite(.file(path)), as: .sqlite, isDefault: true)
  app.migrations.add(PersonMigration())

  try await app.autoMigrate().get()
  self.app = app
  db = app.db

  Task(priority: .utility) {
   try await app.execute()
  }
 }

 public func performInsert(id: Int, name: String) async throws {
  try await Person(id: id, name: name).save(on: db).get()
 }

 public func performRemove(id: Int) async throws {
  try await db.query(Person.self).filter(\.$id == id).first()?.delete(on: db)
 }

 public func clear() async throws {
  try await db.query(Person.self).delete().get()
 }

 public func performRemove(name: String) async throws {
  try await db.query(Person.self).filter(\.$name == name).all().delete(on: db)
 }

 public func count() async throws -> Int {
  try await db.query(Person.self).count()
 }

 public func close() throws {
  app.shutdown()
  db = nil
  app = nil
 }

 public func remove() throws {
  try folder.file(named: sqliteName).delete()
 }

 public init() {}
}

final class Person: Model {
 static let schema = "person"

 @ID(custom: "id")
 var id: Int?
 @Field(key: "name")
 var name: String
 @Timestamp(key: "created", on: .create, format: .unix)
 var created: Date?

 init(id: Int, name: String) {
  self.id = id
  self.name = name
 }

 init() {}
}

struct PersonMigration: AsyncMigration {
 func prepare(on database: Database) async throws {
  try await database.schema(Person.schema)
   .id()
   .field("name", .string, .required)
   .field("created", .time, .required)
   .unique(on: .id)
   .create()
 }

 func revert(on database: Database) async throws {
  try await database.schema(Person.schema).delete()
 }
}
