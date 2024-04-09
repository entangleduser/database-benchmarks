#!/usr/bin/env swift-shell
import Shell // @git/acrlc/shell

do {
 let resources =
  try Folder.current.parent.throwing(reason: "parent folder is missing")
   .subfolder(named: "Resources")
 
 let destination =
  resources.url.appendingPathComponent("PeopleDB.db")
   .path(percentEncoded: false)
 
 try process(.touch, with: destination)
} catch {
 exit(error)
}
