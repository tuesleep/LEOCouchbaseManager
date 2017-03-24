# LEOCouchbaseManager

[![CI Status](http://img.shields.io/travis/leonardo-hammer/LEOCouchbaseManager.svg?style=flat)](https://travis-ci.org/leonardo-hammer/LEOCouchbaseManager)

## Why needs a Couchbase lite manager ?

When use Couchbase doing iOS local database, add Sync gateway to Sync data between multi device, it's must handle most work that contains database open, replication management, conflict handle, register models factory, and setup some Views to index. 

These works are boring, and it's may cost lot of time to do.

So let this manager to do this.

## Usage

LEOCouchbaseManager is a singleton like a worker, handle Couchbase lite events.

### Start manager

```swift
let manager = LEOCouchbaseManager.sharedInstance
manager.databaseName = "demo-db"
manager.startManager()
```

### Create models

Models should directly or indirectly inherited `LEOCouchbaseModel` class, because it's override deleteDocument function, and auto handle relation of model with other models.

a Couchbase iOS model look like this:

```swift
@objc(Notebook)
class Notebook: LEOCouchbaseModel {
@NSManaged var name: String!
@NSManaged var noteIds: [String]?

override func subRelationTypes() -> [AnyClass]? {
	return [Note.self]
}
```

*Notebook* has sub relation type *Note*. A *Notebook* contains some *Note*, so override `subRelationTypes` function mark it, when *Notebook* deleting, the *Note* auto delete too.

Other fucntion in `LEOCouchbaseModel`:

```swift
// For example: Notebook.self
func parentRelationType() -> AnyClass?

// optional override, Note default is noteIds, noteIds is a property in Notebook model.(parentRelationType())
func parentRelationKey() -> String

// notebookId, it's parent relation id property string.
func parentIdKey() -> String?

// Notebook model must override this and return [Note.self] array.
func subRelationTypes() -> [AnyClass]?

// optional override
func subRelationKey() -> String

// Query sub models by Type.
func subModels(with type: LEOCouchbaseModel.Type) -> [LEOCouchbaseModel]

// Link relation with subModel.
func linkSubModel(_ subModel: LEOCouchbaseModel, save: Bool)
```

## Simple Example

Notebook

```swift
@objc(Notebook)
class Notebook: LEOCouchbaseModel {
    @NSManaged var name: String!
    @NSManaged var noteIds: [String]?
    
    override func subRelationTypes() -> [AnyClass]? {
        return [Note.self]
    }
    
    override class func conflict(revs: [CBLSavedRevision]) {
        LEOCouchbaseLogger.debug("Notebook Conflict..")
    }
}
```

Note

```swift
@objc(Note)
class Note: LEOCouchbaseModel {
    // Relation id
    @NSManaged var notebookId: String!
    
    @NSManaged var title: String?
    @NSManaged var content: String?
    
    
    override func parentRelationType() -> AnyClass? {
        return Notebook.self
    }
}
```

Demo code

```swift
let notebook = Notebook(forNewDocumentIn: LeoDB)
notebook.name = "Default notebook"

let note = Note(forNewDocumentIn: LeoDB)
note.title = "Untitled"
note.content = "Today is wunderful"

note.notebookId = notebook.document!.documentID

notebook.linkSubModel(note, save: false)
			
try! notebook.save()
try! note.save()
			
let model = CBLModel(for: LeoDB.document(withID: note.document!.documentID)!)
try! model?.deleteDocument()
```

## Sync Conflict

Every model class handle thier self conflict.

When a conflict occouring, manager will switch model type and dispath this to specify model. `Model.conflict(revs)`.

```swift
override class func conflict(revs: [CBLSavedRevision])
```

Override conflict function handle model conflict is reuqired, conflict must to be solved. [Couchbase iOS Sync Documentation](https://developer.couchbase.com/documentation/mobile/1.3/training/develop/adding-synchronization/index.html)

## Requirements

Swift 3.0 +
Couchbase lite

## Installation

Copy LEOCouchbaseManager/Classes/ directory to your project.

Make sure your project have Couchbase lite iOS framework.

## Author

leonardo-hammer, leonardo_hammer@zoho.com

