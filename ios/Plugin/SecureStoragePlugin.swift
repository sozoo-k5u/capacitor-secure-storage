import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SecureStoragePlugin)
public class SecureStoragePlugin: CAPPlugin {
    let kKeyOption = "key"
    let kDataOption = "data"
    let kSyncOption = "sync"
    let keychain = KeychainSwift()
    let _sync = false; //we WONT sync data with cloud
    let _prefix = "CAPACITOR_SECURE_STORAGE_"
    
    
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": value
        ])
    }
    
    
    @objc func setItem(_ call: CAPPluginCall) {
        guard let key = getKeyParam(from: call),
            let data = getDataParam(from: call)
        else {
            return
        }

        tryKeychainOp(call, _sync, {
            try storeData(data, withKey: key)
            call.resolve()
        })
    }

    @objc func getItem(_ call: CAPPluginCall) {
        guard let key = getKeyParam(from: call)
        else {
            return
        }

        tryKeychainOp(call, _sync, {
            let data = getData(withKey: key)
            call.resolve(["data": data])
        })
    }

    @objc func removeItem(_ call: CAPPluginCall) {
        guard let key = getKeyParam(from: call) else {
        return
        }

        tryKeychainOp(call, _sync, {
            let success = try deleteData(withKey: key)
            call.resolve(["success": success])
        })
    }

    @objc func clear(_ call: CAPPluginCall) {
        tryKeychainOp(call, _sync, {
            try clearData(withPrefix: _prefix)
            call.resolve()
        })
    }

    

    func getKeyParam(from call: CAPPluginCall) -> String? {
        if let key = call.getString(kKeyOption),
        !key.isEmpty {
            return _prefix + key
        }

        KeychainError.reject(call: call, kind: .missingKey)
        return nil
    }

    func getDataParam(from call: CAPPluginCall) -> String? {
        if let value = call.getString(kDataOption) {
        return value
        }

        KeychainError.reject(call: call, kind: .invalidData)
        return nil
    }


    func tryKeychainOp(_ call: CAPPluginCall, _ sync: Bool, _ operation: () throws -> Void) {
        var err: KeychainError?

        let saveSync = keychain.synchronizable
        keychain.synchronizable = sync

        do {
            try operation()
        } catch let error as KeychainError {
            err = error
        } catch {
            err = KeychainError(.unknownError)
        }

        keychain.synchronizable = saveSync

        if let err = err {
            err.rejectCall(call)
        }
    }

    func storeData(_ data: String, withKey key: String) throws {
        let success = keychain.set(data, forKey: key)

        if !success {
            throw KeychainError(.osError, status: keychain.lastResultCode)
        }
    }

    func getData(withKey key: String) -> Any {
        return keychain.get(key) as Any
    }

    func deleteData(withKey key: String) throws -> Bool {
        let success = keychain.delete(key)

        if !success && keychain.lastResultCode != 0 && keychain.lastResultCode != errSecItemNotFound {
            throw KeychainError(.osError, status: keychain.lastResultCode)
        }

        return success
    }

    func clearData(withPrefix prefix: String) throws {
        for key in keychain.allKeys {
            if key.starts(with: prefix) {
                // delete() adds the prefix, but keychain.keyPrefix is empty,
                // so we don't need to remove the prefix.
                if !keychain.delete(key) {
                    throw KeychainError(.osError, status: keychain.lastResultCode)
                }
            }
        }
    }
}
