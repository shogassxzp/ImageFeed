import UIKit

// MARK: Controller

final class ImageListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageIdentifer = "ShowSingleImage"
    private let photosName: [String] = Array(0 ..< 20).map { "\($0)" }
    private var photos: [(image: String, date: Date, isLiked: Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        photos = photosName.enumerated().map { _, name in
            let date = Date()
            return (image: name, date: date, isLiked: false)
        }
    }

    // MARK: Configure cell

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photoData = photos[indexPath.row]
        // Placeholder if we cant create cell from our data
        guard let image = UIImage(named: photoData.image) else {
            cell.tableImageView.image = UIImage(systemName: "photo")
            cell.tableDataLabel.text = photoData.date.formattedDate()

            return
        }
        // Main cell settings setup
        cell.tableImageView.image = image
        cell.tableDataLabel.text = photoData.date.formattedDate()
        let likeImage = photoData.isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        let isLiked = indexPath.row % 2 == 0
        let countedLike = isLiked ? UIImage(named: "No Active") : UIImage(named: "Active")

        cell.tableLikeButton.setImage(likeImage, for: .normal)
        cell.tableLikeButton.setImage(countedLike, for: .normal)

        cell.onLikeButtonTapped = { [weak self] in // Clouser from ListCell for change LikeButton and update cell
            guard let self = self else { return }
            self.photos[indexPath.row].isLiked.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: Segue to SingleImageView

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifer {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: Extensions

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    // MARK: Cell reuse

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageIdentifer, sender: indexPath)
    }

    // MARK: Dynamic height for image in cell

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoData = photos[indexPath.row]
        guard let image = UIImage(named: photoData.image) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        guard imageViewWidth > 0 else {
            return 16 + 30 // Отступ + Высота gradientView
        }
        let imageWidth = image.size.width
        guard imageWidth != 0 else {
            return 16 + 30
        }
        let scale = imageViewWidth / imageWidth
        let cellHigh = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHigh
    }
}
