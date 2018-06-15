# LEOCouchbaseManager

[![codebeat badge](https://codebeat.co/badges/6567f1b7-42b1-4134-90b5-2d7bd4736dee)](https://codebeat.co/projects/github-com-leonardo-hammer-leocouchbasemanager-master)

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

override func leo_subRelationTypes() -> [AnyClass]? {
	return [Note.self]
}
```

*Notebook* has sub relation type *Note*. A *Notebook* contains some *Note*, so override `leo_subRelationTypes` function mark it, when *Notebook* deleting, the *Note* auto delete too.

Other fucntion in `LEOCouchbaseModel`:

```swift
// For example: Notebook.self
func leo_parentRelationType() -> AnyClass?

// optional override, Note default is noteIds, noteIds is a property in Notebook model.(parentRelationType())
func leo_parentRelationKey() -> String

// notebookId, it's parent relation id property string.
func leo_parentIdKey() -> String?

// Notebook model must override this and return [Note.self] array.
func leo_subRelationTypes() -> [AnyClass]?

// optional override
func leo_subRelationKey() -> String

// Query sub models by Type.
func leo_subModels(with type: LEOCouchbaseModel.Type, sortDescriptors: [NSSortDescriptor]? = nil) -> [LEOCouchbaseModel]

// Link relation with subModel.
func leo_linkSubModel(_ subModel: LEOCouchbaseModel, save: Bool = false, saveSubModel: Bool = false)
```

### Global variable

```swift
var LeoDB: CBLDatabase {
    return LEOCouchbaseManager.sharedInstance.database!
}
```

### Replication Notifications
 
- LEOCouchbasePushReplicationChangedNotification
- LEOCouchbasePullReplicationChangedNotification

Notification User Info Keys

- LEOCouchbaseReplicationStatusUserInfoKey (CBLReplicationStatus)
- LEOCouchbaseReplicationProgressUserInfoKey (Double)
- LEOCouchbaseReplicationChangesCountUserInfoKey (Integer)
- LEOCouchbaseReplicationCompletedChangesCountUserInfoKey (Integer)

Observer pull changed notification to reload views.

## Simple Example

Notebook

```swift
@objc(Notebook)
class Notebook: BaseModel {
    @NSManaged var name: String!
    @NSManaged var noteIds: [String]?
    
    override func leo_subRelationTypes() -> [AnyClass]? {
        return [Note.self]
    }
    
    override class func leo_conflict(revs: [CBLSavedRevision]) {
        LEOCouchbaseLogger.debug("Notebook Conflict..")
    }
}
```

Note

```swift
@objc(Note)
class Note: BaseModel {
    // Relation id
    @NSManaged var notebookId: String!
    
    @NSManaged var title: String?
    @NSManaged var content: String?
    
    
    override func leo_parentRelationType() -> AnyClass? {
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

notebook.leo_linkSubModel(note)
			
try! notebook.save()
try! note.save()
			
let model = CBLModel(for: LeoDB.document(withID: note.document!.documentID)!)
try! model?.deleteDocument()
```

## Sync Conflict

Every model class handle thier self conflict.

When a conflict occouring, manager will switch model type and dispath this to specify model. `Model.leo_conflict(revs)`.

```swift
override class func leo_conflict(revs: [CBLSavedRevision])
```

Override conflict function handle model conflict is reuqired, conflict must to be solved. [Couchbase iOS Sync Documentation](https://developer.couchbase.com/documentation/mobile/1.3/training/develop/adding-synchronization/index.html)

## Requirements

Swift 3.0 +
Couchbase lite

## Installation

Copy LEOCouchbaseManager/Classes/LEOCouchbaseManager directory to your project.

Make sure your project have Couchbase lite iOS framework.

## Author

Tuesleep, tuesleep@gmail.com

