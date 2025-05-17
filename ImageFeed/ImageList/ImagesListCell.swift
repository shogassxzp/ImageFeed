import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var tableLikeButton: UIButton!
    @IBOutlet weak var tableDataLabel: UILabel!
    @IBOutlet weak var tableImageView: UIImageView!
    static let reuseIdentifier = "ImagesListCell"
}
