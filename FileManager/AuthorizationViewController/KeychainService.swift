
import KeychainAccess
import Foundation

protocol KeychainServiceProtocol {
    var isPasswordExists: Bool { get }
    var isTemporaryPasswordExists: Bool { get }
    func savePassword(_ password: String)
    func deletePassword()
    func checkPassword(_ password: String) -> Bool
    func saveTemporaryPassword(_ password: String)
    func deleteTemporaryPassword()
    func checkTemporaryPassword(_ password: String) -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    
    private let keychain = Keychain(service: "com.krostal.FileManager")
    private let myKey = "FileManagerAppPasswordKey"
    private let temporaryKey = "TemporaryFileManagerPasswordKey"
    
    var isPasswordExists: Bool {
        do {
            let existingPassword = try keychain.getString(myKey)
            return (existingPassword != nil)
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    var isTemporaryPasswordExists: Bool {
        do {
            let existingPassword = try keychain.getString(temporaryKey)
            return (existingPassword != nil)
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func savePassword(_ password: String) {
        do {
            try keychain.set(password, key: myKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deletePassword() {
        do {
            try keychain.remove(myKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkPassword(_ password: String) -> Bool {
        do {
            let savedPassword = try keychain.get(myKey)
            return savedPassword == password
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func saveTemporaryPassword(_ password: String) {
        do {
            try keychain.set(password, key: temporaryKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteTemporaryPassword() {
        do {
            try keychain.remove(temporaryKey)
        } catch {
            print(error.localizedDescription)
        }
    }

    func checkTemporaryPassword(_ password: String) -> Bool {
        do {
            let savedPassword = try keychain.get(temporaryKey)
            return savedPassword == password
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
}
