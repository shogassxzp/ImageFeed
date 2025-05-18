import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var tableLikeButton: UIButton!
    @IBOutlet var tableDataLabel: UILabel!
    @IBOutlet var tableImageView: UIImageView!
    @IBOutlet var gradientView: UIView!
    static let reuseIdentifier = "ImagesListCell"

    var onLikeButtonTapped: (() -> Void)? // Clouser for work with button from ViewController

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()

        tableImageView.layer.masksToBounds = true
        tableImageView.layer.cornerRadius = 16
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 16
    }

    // MARK: Setup gradient

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }

    @IBAction func LikeButtonClick(_ sender: Any) {
        onLikeButtonTapped?()
    }
}
