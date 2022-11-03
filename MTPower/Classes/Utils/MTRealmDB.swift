

import Foundation
import RealmSwift


/*
    replace /XXX.realm
 */
open class MTProtoRealmDB: NSObject{
    @MTAssignOnce<UInt64> static var dbVersion: UInt64?
    
    public static func setup(){
        let __dbVersion = dbVersion ?? 1
        let __path = dbPath()
        let config = Realm.Configuration(fileURL: URL(string: __path),
                                         schemaVersion: __dbVersion,
                                         migrationBlock: { migration, oldVersion in
            /*
            migration.enumerateObjects(ofType: XXX.className()) { oldObject, newObject in
                if let oldObj = oldObject,oldVersion == 2{
                    //new property no needs update
                }
            }
             */
        })
        Realm.Configuration.defaultConfiguration = config
        Realm.asyncOpen { result in
            switch result {
            case .success:
                print("-----------Realm Setup Success")
            case .failure(let error):
                print("-----------!!!Realm Setup Failue：\(error.localizedDescription)")
            }
        }
        
    }
    /// you needs override this method
    public static func dbPath()-> String{
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dbPath = cachePath + "/XXX.realm"
        return dbPath
    }
    
    static func insert<T: Object>(elements: [T]) {
        do {
            let realm = try MTProtoRealmDB.realm()
            try realm.write { realm.add(elements, update: .modified) }
        } catch {
            MTLog(">>>>>>realmDB insert \(T.className()) failure")
        }
    }

    static func query<T: Object>(type: T.Type,
                                 sortedKeyPath: String? = nil,
                                 ascending: Bool = true) -> [T]
    {
        do {
            let realm = try MTProtoRealmDB.realm()
            var results = realm.objects(T.self)
            if let sortedKeyPath = sortedKeyPath {
                results = results.sorted(byKeyPath: sortedKeyPath, ascending: ascending)
            }
            return Array(results)
        } catch {
            MTLog(">>>>>>realmDB query \(T.className()) failure")
            return []
        }
    }

    static func delete<T: Object>(elements: [T]) {
        do {
            let realm = try MTProtoRealmDB.realm()
            try realm.write { realm.delete(elements) }
        } catch {
            MTLog(">>>>>>realmDB delete \(T.className()) failure",error.localizedDescription)
        }
    }

    static func update(updateBlock: ()->Void) {
        do {
            let realm = try MTProtoRealmDB.realm()
            try realm.write { updateBlock() }
        } catch {
            MTLog(">>>>>>realmDB update failure",error.localizedDescription)
        }
    }
    
    /// realm对象
    private static func realm() throws -> Realm {
        return try Realm(fileURL: URL(string: MTProtoRealmDB.dbPath())!)
    }
}


