
import Foundation

protocol FileManagerServiceProtocol: AnyObject {
    func contentsOfDirectory(fromURL url: URL) -> [Content]
    func createDirectory(inParentDirectory parentDirectoryURL: URL, withName directoryName: String)
    func createFile(inParentDirectory parentDirectoryURL: URL, data: Data, imageName: String)
    func removeContent()
}

enum ContentType {
    case folder
    case file
}

struct Content {
    let name: String
    let type: ContentType
    let path: String
}

class FileManagerService: FileManagerServiceProtocol {
    
    let fileManager = FileManager.default
    
    func contentsOfDirectory(fromURL url: URL) -> [Content] {
        do {
            
            let contentOfDirectory = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: .none, options: [])
            var arrayOfContent: [Content] = []
            contentOfDirectory.forEach { itemURL in
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemURL.path(), isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        arrayOfContent.append(Content(name: itemURL.lastPathComponent, type: .folder, path: url.path()))
                    } else {
                        arrayOfContent.append(Content(name: itemURL.lastPathComponent, type: .file, path: url.path()))
                    }
                }
            }
            return arrayOfContent
        } catch {
            print("❌", error.localizedDescription)
            return []
        }
    }
    
    func createDirectory(inParentDirectory parentDirectoryURL: URL, withName directoryName: String) {
        let newDirectoryURL = parentDirectoryURL.appending(path: directoryName)
        print(newDirectoryURL)
        
        do {
            try fileManager.createDirectory(at: newDirectoryURL, withIntermediateDirectories: false)
        } catch {
            print("❌", error)
        }
    }
    
    func createFile(inParentDirectory parentDirectoryURL: URL, data: Data, imageName: String) {
        let filePath = parentDirectoryURL.appending(path: imageName)
        let isCreated = fileManager.createFile(atPath: filePath.path(), contents: data)
        if !isCreated {
            print("❌ Не удалось создать картинку")
        }
    }
    
    func removeContent() {
        
    }

}


