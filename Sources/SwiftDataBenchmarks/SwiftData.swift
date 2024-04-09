import DatabaseBenchmark
import SwiftData

@available(macOS 14, iOS 17, *)
public final class SwiftDataBenchmarks: DatabaseBenchmark {
 var container: ModelContainer!

 public func prepare() throws {
  let location = Folder.current.url
  let configuration =
   ModelConfiguration(url: location.appendingPathComponent(sqliteName))
  let container = try ModelContainer(
   for: Person.self,
   configurations: configuration
  )

  self.container = container
 }

 lazy var context: ModelContext! = ModelContext(container)

 public func performInsert(id: Int, name: String) throws {
  context.insert(Person(id: id, name: name))
  try context.save()
 }

 public func performRemove(id: Int) throws {
  var desc = FetchDescriptor(predicate: #Predicate<Person> { $0.id == id })
  desc.fetchLimit = 1

  if let model = try context.fetch(desc).first {
   context.delete(model)
   try context.save()
  }
 }

 public func performRemove(name: String) throws {
  for model in try context.fetch(
   FetchDescriptor(predicate: #Predicate<Person> { $0.name == name })
  ) {
   context.delete(model)
  }

  try context.save()
 }

 public func clear() throws {
  for person in try context.fetch(FetchDescriptor<Person>()) {
   context.delete(person)
  }
 }

 public func count() throws -> Int {
  try context.fetchCount(FetchDescriptor<Person>())
 }

 public func close() throws {
  container.deleteAllData()
  context = nil
  container = nil
 }

 public func remove() throws {
  for filename in [sqliteName, sqliteName + "-wal", sqliteName + "-shm"] {
   try folder.file(named: filename).delete()
  }
 }

 public init() {}
}

@available(macOS 14, iOS 17, *)
@Model
final class Person: Identifiable {
 @Attribute(.unique)
 var id: Int
 var name: String
 var created = Date.now

 init(id: Int, name: String, created: Date = Date.now) {
  self.id = id
  self.name = name
  self.created = created
 }
}
