import Core
import DatabaseBenchmark
import Tests

struct Person: Identifiable, Codable, Hashable {
 var id: Int
 let name: String
 var created: Date = .now
}

// TODO: cover other decoders such as YAML, XML, CSV, & Plist
/// A JSON Benchmark that would probably make a good defaults library
final class JSONBenchmarks: DatabaseBenchmark {
 let name: String = "People.json"
 var encoder: JSONEncoder!
 var decoder: JSONDecoder!
 var values: [Int: Person]?

 lazy var url = folder.url.appendingPathComponent(name, conformingTo: .json)
 func prepare() throws {
  encoder = JSONEncoder()
  decoder = JSONDecoder()
  try encoder.encode([Int: Person]()).write(to: url)
  values = .empty
 }

 public func performInsert(id: Int, name: String) throws {
  var copy = try values ?? decoder.decode(
   [Int: Person].self,
   from: Data(contentsOf: url)
  )
  copy[id] = Person(id: id, name: name)

  if values != copy {
   values = copy
   try encoder.encode(copy).write(to: url)
  }
 }

 public func performRemove(id: Int) throws {
  var copy = try values ?? decoder.decode(
   [Int: Person].self,
   from: Data(contentsOf: url)
  )
  copy.removeValue(forKey: id)

  if values != copy {
   values = copy
   try encoder.encode(copy).write(to: url)
  }
 }

 public func performRemove(name: String) throws {
  var copy = try values ?? decoder.decode(
   [Int: Person].self,
   from: Data(contentsOf: url)
  )

  for (key, value) in copy where value.name == name {
   copy.removeValue(forKey: key)
  }

  if values != copy {
   values = copy
   try encoder.encode(copy).write(to: url)
  }
 }

 public func clear() throws {
  if values != .empty {
   try encoder.encode([Int: Person]()).write(to: url)
   values = .empty
  }
 }

 public func count() throws -> Int {
  try values?.count ?? decoder.decode(
   [Int: Person].self,
   from: Data(contentsOf: url)
  ).count
 }

 public func close() async throws {
  values = nil
  encoder = nil
  decoder = nil
 }

 public func remove() throws {
  try folder.file(named: name).delete()
 }
}
