
import UIKit

class SecondLevelFolderViewController: UIViewController {
    
    private lazy var fileManagerService = FileManagerService()
    
    private var isSortingEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "isSortingEnabled")
    }
    
    var contentOfFolder: [Content] = []
    
    var folderPath: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSortingEnabled {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        contentOfFolder = fileManagerService.contentsOfDirectory(fromURL: URL(filePath: folderPath))
        if isSortingEnabled {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() > $1.name.lowercased() }
        }
    }
    
    private func updateTableView() {
        contentOfFolder = fileManagerService.contentsOfDirectory(fromURL: URL(filePath: folderPath))
        if isSortingEnabled {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            contentOfFolder = contentOfFolder.sorted { $0.name.lowercased() > $1.name.lowercased() }
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
            cell.accessoryView = nil
        } else {
            cell.accessoryType = .none
            if let imageName = content.imageName {
                let imagePath = URL(filePath: folderPath).appending(path: imageName)
                do {
                    let imageData = try Data(contentsOf: imagePath)
                    let image = UIImage(data: imageData)
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    cell.accessoryView = imageView
                } catch {
                    print("❌", error.localizedDescription)
                }
            }
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

extension SecondLevelFolderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                        self.fileManagerService.createFile(inParentDirectory: URL(filePath: self.folderPath), data: imageData, imageName: name + ".jpeg")
                        self.updateTableView()
                    }
                }
        }
    }
}
