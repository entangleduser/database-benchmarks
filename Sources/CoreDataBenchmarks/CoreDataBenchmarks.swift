import AppKit
import CoreData
import DatabaseBenchmark

public final class CoreDataBenchmarks: DatabaseBenchmark {
 var container: NSPersistentContainer!
 
 public func prepare() throws {
  let location = Folder.current.url

  
  let model = NSManagedObjectModel()

  model.entities.append(Person.entity())
  
  let container =
   NSPersistentContainer(name: "PersonModel", managedObjectModel: model)

  container.persistentStoreDescriptions.first!.url =
   location.appendingPathComponent(sqliteName)

  container.loadPersistentStores(
   completionHandler: { _, error in
    if let error = error as NSError? {
     fatalError(
      "Unresolved error \(error), \(error.userInfo)"
     )
    }
   }
  )
  self.container = container
 }

 lazy var context: NSManagedObjectContext! = NSManagedObjectContext(.mainQueue)

 @MainActor
 public func performInsert(id: Int, name: String) throws {
  let person = Person(entity: Person.entity(), insertInto: context)
  person.id = id
  person.name = name
  try context.save()
 }

 @MainActor
 public func performRemove(id: Int) throws {
  let request = NSFetchRequest<Person>(entityName: "Person")
  if #available(macOS 14.0, *) {
   request.predicate =
    NSPredicate(#Predicate<Person> { $0.id == id })
  } else {
   request.predicate =
    NSPredicate(format: "id == %@", id)
  }
  request.fetchLimit = 1
  
  if let model = try context.fetch(request).first {
   context.delete(model)
   try context.save()
  }
 }

 @MainActor
 public func performRemove(name: String) throws {
  let request = NSFetchRequest<Person>(entityName: "Person")
  if #available(macOS 14.0, *) {
   request.predicate =
    NSPredicate(#Predicate<Person> { $0.name == name })
  } else {
   request.predicate =
   NSPredicate(format: "name == %@", name)
  }

  for model in try context.fetch(request) {
   context.delete(model)
  }

  try context.save()
 }

 public func clear() throws {
  for person in try context.fetch(NSFetchRequest<Person>()) {
   context.delete(person)
  }
 }

 public func count() throws -> Int {
  try context.count(for: NSFetchRequest<Person>())
 }

 public func close() throws {
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

@objc(Person)
@objcMembers
final class Person: NSManagedObject, Identifiable {
 @NSManaged
 var id: Int
 @NSManaged
 var name: String
 @NSManaged
 var created: Date

 convenience init(id: Int, name: String, created: Date = Date.now) {
  self.init()
  self.id = id
  self.name = name
  self.created = created
 }

 override static func entity() -> NSEntityDescription {
  let desc = NSEntityDescription()
  desc.name = "Person"
  desc.managedObjectClassName = "PersonModel"

  let idAttribute = NSAttributeDescription()
  idAttribute.name = "id"
  idAttribute.type = .integer64

  desc.properties.append(idAttribute)

  let nameAttribute = NSAttributeDescription()
  nameAttribute.name = "name"
  nameAttribute.type = .string
  desc.properties.append(nameAttribute)

  let dateAttribute = NSAttributeDescription()
  dateAttribute.name = "date"
  dateAttribute.type = .date
  desc.properties.append(dateAttribute)
  return desc
 }
}

final class PersonModel: NSManagedObjectModel {
 override init() {
  super.init()
  //entities.append(Person.entity())
 }

 @available(*, unavailable)
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
}
