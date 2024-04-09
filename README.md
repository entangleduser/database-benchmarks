### Database Benchmarks
A database should be a practical search implementation and an efficient storage system with use cases varying across different devices and apps. 
This benchmark uses [Acrylic](https://github.com/acrlc/acrylic), a declarative syntax framework for modules that’s evolving and useful for testing apps.

> [!NOTE]
> Get started with `swift run` or `swift run -c release`

### Implementations
#### SQLite
##### [GRDB](https://github.com/entangleduser/GRDB.swift)
[x] Supports iOS 11.0+ / macOS 10.13+ / tvOS 11.0+ / watchOS 4.0+
[] No object relationship mapping (ORM), [GRDB-ORM](https://github.com/Jasperav/GRDB-ORM) may help with this and improve performance (haven't tested).

##### [Lighter](https://github.com/Lighter-swift/Lighter) 
[x] Supports Linux / macOS 10.15+ / iOS 13.0+
[x] Uses a build plugin to generate queries
[] No object relationship mapping

##### SwiftData
[x] Supports iOS 17.0+ / iPadOS 17.0+ / macOS 14.0+ / Mac Catalyst 17.0+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+
[x] Supports object relationship mapping

##### [Vapor](https://github.com/vapor/Vapor) with [SQLite](https://github.com/vapor/fluent-sqlite-driver) / [Fluent](https://github.com/vapor/Fluent)
- Supports Linux / macOS 10.15+ / iOS 13.0+ / watchOS 6.0+ / tvOS 13.0+
- Supports object relationship mapping


#### Others
- JSON (for challenging the status quo)

#### Future Implementations
- CoreData and *others* ...

### Requirements
- **sqlite** (for frameworks that don't include the entire implementation')
```sh
brew install sqlite
```

> [!NOTE]
> `Lighter` and `GRDB` **benchmarks** are first time implementations, so please modify where necessary, to get the best results
