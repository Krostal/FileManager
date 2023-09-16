
import UIKit

class FirstLevelFolderViewControllerViewController: UIViewController {
    
    private lazy var fileManagerService = FileManagerService()
    var contentOfFolder: [Content] = []
    
    var folderPath: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "openSecondLevelFolder" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let content = contentOfFolder[indexPath.row]
                return content.type == .folder
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openSecondLevelFolder" {
            if let destinationController = segue.destination as? SecondLevelFolderViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    let selectedContent = contentOfFolder[selectedIndexPath.row]
                    
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
                fileManagerService.createDirectory(inParentDirectory: URL(filePath: folderPath), withName: folderName)
                updateTableView()
            }
        }))
        present(alert, animated: true)
    }
}

extension FirstLevelFolderViewControllerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentOfFolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstLevelFolderCell", for: indexPath)
        
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


extension FirstLevelFolderViewControllerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

