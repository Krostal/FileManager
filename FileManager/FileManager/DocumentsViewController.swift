
import UIKit

class DocumentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var isSortingEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "isSortingEnabled")
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSortingEnabled {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
        tableView.reloadData()
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
        if isSortingEnabled {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
        print(contentOfDocuments)
    }
    
    private func updateTableView() {
        contentOfDocuments = fileManagerService.contentsOfDirectory(fromURL: documentsURL)
        if isSortingEnabled {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfDocuments = contentOfDocuments.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
        tableView.reloadData()
    }
    
    private func swipeForEdit() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGestureRecognizer.direction = .left
        tableView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    @IBAction func addImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createNewFolder(_ sender: UIBarButtonItem) {
        Alert().setName(
            on: self,
            title: "Create new folder",
            message: "Enter folder name",
            placeholder: "Folder name"
        ) {
            [weak self] enteredName in
            guard let self else { return }
            if let name = enteredName {
                self.fileManagerService.createDirectory(inParentDirectory: self.documentsURL, withName: name)
                self.updateTableView()
            }
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let content = contentOfDocuments[indexPath.row]
            let folderPath = documentsURL.appendingPathComponent(content.name).path
            fileManagerService.removeContent(atPath: folderPath)
            updateTableView()
        }
    }
}

extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            Alert().setName(
                on: self,
                title: "Save Image",
                message: "Enter a name for the image",
                placeholder: "Image name") { enteredName in
                    guard let name = enteredName else { return }
                    if let image = info[.originalImage] as? UIImage,
                       let imageData = image.jpegData(compressionQuality: 1.0) {
                        self.fileManagerService.createFile(inParentDirectory: self.documentsURL, data: imageData, imageName: name + ".jpeg")
                        self.updateTableView()
                    }
                }
        }
    }
}
