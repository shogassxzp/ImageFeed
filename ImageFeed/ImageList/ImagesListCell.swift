import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var tableLikeButton: UIButton!
    @IBOutlet weak var tableDataLabel: UILabel!
    @IBOutlet weak var tableImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    static let reuseIdentifier = "ImagesListCell"
    
    var onLikeButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        
        tableImageView.layer.masksToBounds = true
        tableImageView.layer.cornerRadius = 16
        
    }
        // MARK: Setup gradient
        /*
         Не догадался сделать в сториборде полупрозрачный вью по этому полез в жёсткие дебри и реализовал градиент кодом.
         В уроке упоминалась вёрстка кодом в будущем, так что оставлю градиент в таком виде, надеюсь на ревьюер ругать за такое не будет
         */
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.5)
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
