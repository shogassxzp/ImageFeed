import UIKit

final class ImagesListCell: UITableViewCell {
    var tableLikeButton = UIButton(type: .system)
    var tableDataLabel = UILabel()
    var tableImageView = UIImageView()
    var gradientView = UIView()

    static let reuseIdentifier = "ImagesListCell"

    var onLikeButtonTapped: (() -> Void)? // Clouser for work with button from ViewController

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        contentView.backgroundColor = UIColor(resource: .ypBlack)
        // imageView settings
        tableImageView.contentMode = .scaleAspectFill
        tableImageView.layer.masksToBounds = true
        tableImageView.layer.cornerRadius = 16
        tableImageView.translatesAutoresizingMaskIntoConstraints = false
        tableImageView.backgroundColor = UIColor(resource: .ypBlack)
        contentView.addSubview(tableImageView)
        // gradientView settings
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 16
        contentView.addSubview(gradientView)
        // dataLabel settings
        tableDataLabel.font = .systemFont(ofSize: 13)
        tableDataLabel.textColor = UIColor(resource: .ypWhite)
        tableDataLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(tableDataLabel)
        // likeButton settings
        tableLikeButton.setImage(UIImage(resource: .noActive), for: .normal)
        tableLikeButton.tintColor = .white
        tableLikeButton.addTarget(self, action: #selector(likeButtonClick), for: .touchUpInside)
        contentView.addSubview(tableLikeButton)
        // layout
        NSLayoutConstraint.activate([
            tableImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            tableImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            tableLikeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            tableLikeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
        setupGradient()
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
        gradientView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }

    @objc func likeButtonClick(_ sender: Any) {
        onLikeButtonTapped?()
    }
}
