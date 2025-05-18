import UIKit

// MARK: Controller
class ImageListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private var photos: [(image: String, date: Date)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        photos = photosName.enumerated().map { (index, name) in
            let date = Date().addingTimeInterval(-Double(index) * 86400)
            return (image: name, date: date)
        }
    }
    // MARK: Configure cell
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoData = photos[indexPath.row]
        guard let image = UIImage(named: photoData.image) else {
            cell.tableImageView.image = UIImage(systemName: "photo")
            cell.tableDataLabel.text = photoData.date.formattedDate()
            //button
            return
        }
        cell.tableImageView.image = image
        cell.tableDataLabel.text = photoData.date.formattedDate()
        // button
        
      
    }
}
    // MARK: Extensions
    extension ImageListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
            
            guard let imageListCell = cell as? ImagesListCell else {
                return UITableViewCell()
            }
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
    }
    extension ImageListViewController:UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
    }

