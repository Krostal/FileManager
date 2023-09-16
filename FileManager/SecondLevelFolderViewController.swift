
import UIKit

class SecondLevelFolderViewController: UIViewController {
    
    private lazy var fileManagerService = FileManagerService()
    var contentOfFolder: [Content] = []
    
    var folderPath: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        contentOfFolder = fileManagerService.contentsOfDirectory(fromURL: URL(filePath: folderPath))
        print(contentOfFolder, folderPath)
    }
    
    private func updateTableView() {
        contentOfFolder = fileManagerService.contentsOfDirectory(fromURL: URL(filePath: folderPath))
        tableView.reloadData()
    }
    
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

extension SecondLevelFolderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentOfFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondLevelFolderCell", for: indexPath)
        
        let content = contentOfFolder[indexPath.row]
        cell.textLabel?.text = content.name
        
        if content.type == .folder {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension SecondLevelFolderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,
           let imageURL = info[.imageURL] as? URL {
            let imageName = imageURL.lastPathComponent
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                fileManagerService.createFile(inParentDirectory: URL(filePath: folderPath), data: imageData, imageName: imageName)
            }
        }
        updateTableView()
        picker.dismiss(animated: true, completion: nil)
    }
}
