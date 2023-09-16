
import UIKit

class DocumentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var fileManagerService = FileManagerService()
    
    var contentOfDocuments: [Content] = []
    
    let documentsURL: URL = {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return url
        } catch {
            print(error.localizedDescription)
            return URL(fileURLWithPath: "")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "openFirstLevelFolder" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let content = contentOfDocuments[indexPath.row]
                return content.type == .folder
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openFirstLevelFolder" {
            if let destinationController = segue.destination as? FirstLevelFolderViewControllerViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    let selectedContent = contentOfDocuments[selectedIndexPath.row]
                    
                    if selectedContent.type == .folder {
                        destinationController.folderPath = selectedContent.path + "/" + selectedContent.name
                    }
                }
            }
        }
    }

    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        contentOfDocuments = fileManagerService.contentsOfDirectory(fromURL: documentsURL)
    }
    
    private func updateTableView() {
        contentOfDocuments = fileManagerService.contentsOfDirectory(fromURL: documentsURL)
        tableView.reloadData()
    }
    
    
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createNewFolder(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Создать папку", message: "Введите название папки", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Название папки"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { [weak self, weak alert] _ in
            guard let self else { return }
            guard let alert = alert else { return }
            if let folderName = alert.textFields?.first?.text {
                fileManagerService.createDirectory(inParentDirectory: documentsURL, withName: folderName)
                updateTableView()
            }
        }))
        present(alert, animated: true)
    }
}


extension DocumentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentOfDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentsTableViewCell", for: indexPath)
        
        let content = contentOfDocuments[indexPath.row]
        cell.textLabel?.text = content.name
            
        if content.type == .folder {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,
           let imageURL = info[.imageURL] as? URL {
            let imageName = imageURL.lastPathComponent
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                fileManagerService.createFile(inParentDirectory: documentsURL, data: imageData, imageName: imageName)
            }
        }
        updateTableView()
        picker.dismiss(animated: true, completion: nil)
    }
}

