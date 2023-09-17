
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
    }
    
    private func updateTableView() {
        contentOfFolder = fileManagerService.contentsOfDirectory(fromURL: URL(filePath: folderPath))
        tableView.reloadData()
    }
    
    private func swipeForEdit() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGestureRecognizer.direction = .left
        tableView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    private func showAlert() {
        let folderNameAlert = UIAlertController(title: "Create new folder", message: "Enter folder name ", preferredStyle: .alert)
        
        folderNameAlert.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        
        folderNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        folderNameAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self, weak folderNameAlert] _ in
            guard let self else { return }
            guard let alert = folderNameAlert else { return }
            if let folderName = alert.textFields?.first?.text {
                let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
                let folderNameCharacterSet = CharacterSet(charactersIn: folderName)
                if folderName.isEmpty || !allowedCharacterSet.isSuperset(of: folderNameCharacterSet) {
                    let errorAlert = UIAlertController(title: "Ошибка", message: "Folder name contains invalid characters", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.showAlert()
                    }))
                    present(errorAlert, animated: true)
                } else {
                    fileManagerService.createDirectory(inParentDirectory: URL(filePath: folderPath), withName: folderName)
                    updateTableView()
                }
            }
        }))
        present(folderNameAlert, animated: true)
    }
    
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createNewFolder(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    @objc func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if tableView.isEditing {
                tableView.setEditing(false, animated: true)
            } else {
                tableView.setEditing(true, animated: true)
            }
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let content = contentOfFolder[indexPath.row]
            let folderPath = URL(filePath: folderPath).appendingPathComponent(content.name).path
            fileManagerService.removeContent(atPath: folderPath)
            updateTableView()
        }
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
