import Foundation

protocol FileManagerServiceProtocol: AnyObject {
    func contentsOfDirectory(fromURL url: URL) -> [Content]
    func createDirectory(inParentDirectory parentDirectoryURL: URL, withName directoryName: String)
    func createFile(inParentDirectory parentDirectoryURL: URL, data: Data, imageName: String)
    func removeContent(atPath path: String)
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
                if itemURL.lastPathComponent != ".DS_Store" {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: itemURL.path(), isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            arrayOfContent.append(Content(name: itemURL.lastPathComponent, type: .folder, path: url.path()))
                        } else {
                            arrayOfContent.append(Content(name: itemURL.lastPathComponent, type: .file, path: url.path()))
                        }
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
        do {
            try fileManager.createDirectory(at: newDirectoryURL, withIntermediateDirectories: false)
        } catch {
            print("❌", error.localizedDescription)
        }
    }

    func createFile(inParentDirectory parentDirectoryURL: URL, data: Data, imageName: String) {
        let filePath = parentDirectoryURL.appending(path: imageName)
        let isCreated = fileManager.createFile(atPath: filePath.path(), contents: data)
        if !isCreated {
            print("❌ Error with creating image")
        }
    }

    func removeContent(atPath path: String) {
        let contentURL = URL(fileURLWithPath: path)
        do {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(at: contentURL)
                print("✅ Content removed successfully at path: \(path)")
            } else {
                print("❌ Content does not exist at path: \(path)")
            }
        } catch {
            print("❌ Error removing content at path \(path): \(error.localizedDescription)")
        }
    }

}


