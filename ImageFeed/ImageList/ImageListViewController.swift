import UIKit

// MARK: Controller
class ImageListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private var photos: [(image: String, date: Date, isLiked: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        photos = photosName.enumerated().map { (index, name) in
            let date = Date().addingTimeInterval(-Double(index) * 86400)
            return (image: name, date: date, isLiked: false)
        }
    }
    // MARK: Configure cell
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoData = photos[indexPath.row]
        guard let image = UIImage(named: photoData.image) else {
            cell.tableImageView.image = UIImage(systemName: "photo")
            cell.tableDataLabel.text = photoData.date.formattedDate()
            
            return
        }
        cell.tableImageView.image = image
        cell.tableDataLabel.text = photoData.date.formattedDate()
        let likeImage = photoData.isLiked ? UIImage( named: "Active") : UIImage(named: "No Active")
        cell.tableLikeButton.setImage(likeImage, for: .normal)
        
        cell.onLikeButtonTapped = { [weak self] in
            guard let self = self else {return}
            self.photos[indexPath.row].isLiked.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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

