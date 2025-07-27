import Kingfisher
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    private var photoId: String?
    private var likeNotificationObserver: NSObjectProtocol?

    var tableLikeButton = UIButton(type: .system)
    var tableDataLabel = UILabel()
    var tableImageView = UIImageView()
    var gradientView = UIView()

    weak var delegate: ImagesListCellDelegate?

    static let reuseIdentifier = "ImagesListCell"

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
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradientView)
        // dataLabel settings
        tableDataLabel.font = .systemFont(ofSize: 13)
        tableDataLabel.textColor = UIColor(resource: .ypWhite)
        tableDataLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(tableDataLabel)
        // likeButton settings
        tableLikeButton.setImage(UIImage(resource: .noActive), for: .normal)
        tableLikeButton.tintColor = .ypWhite
        tableLikeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        tableLikeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableLikeButton)
        //
        contentView.sendSubviewToBack(tableImageView)

        // layout
        NSLayoutConstraint.activate([
            tableImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            tableImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            gradientView.bottomAnchor.constraint(equalTo: tableImageView.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: tableImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: tableImageView.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30),

            tableDataLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 10),
            tableDataLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -5),

            tableLikeButton.topAnchor.constraint(equalTo: tableImageView.topAnchor, constant: 10),
            tableLikeButton.trailingAnchor.constraint(equalTo: tableImageView.trailingAnchor, constant: -10),
        ])
        setupGradient()
    }

    func configure(with photo: ImageListService.Photo, tableView: UITableView, indexPath: IndexPath) {
        tableImageView.kf.indicatorType = .activity
        tableImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(resource: ._0),
        ) { [weak tableView] result in
            guard let tableView else { return }

            switch result {
            case .success:
                print("[KF]: Изображение загружено, устанавливаю")
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case let .failure(error):
                print("[KF]: Ошибка загрузки изображения \(error)")
                return
            }
        }
        tableDataLabel.text = photo.createdAt?.formattedDate() ?? "Дата неизвестна"
        tableLikeButton.setImage(UIImage(resource: photo.isLike ? .active : .noActive), for: .normal)
        photoId = photo.id

        if let observer = likeNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        likeNotificationObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.likeChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self,
                  let photoId = self.photoId,
                  let currentPhoto = ImageListService.shared.photos.first(where: { $0.id == photoId })
            else { return }

            self.setLikeButtonState(isLiked: currentPhoto.isLike)
        }
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

    @objc func likeButtonClicked(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableLikeButton.isEnabled = false
        }
        delegate?.imageListCellDidTapLike(self)
    }

    func setLikeButtonState(isLiked: Bool) {
        DispatchQueue.main.async {
            self.tableLikeButton.setImage(UIImage(resource: isLiked ? .active : .noActive), for: .normal)
            self.tableLikeButton.tintColor = isLiked ? .ypRed : .ypWhite
            self.tableLikeButton.isEnabled = true
        }
    }
}

extension ImagesListCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        tableImageView.kf.cancelDownloadTask()
        tableImageView.image = nil
        tableDataLabel.text = nil
        tableLikeButton.setImage(nil, for: .normal)
        if let observer = likeNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            likeNotificationObserver = nil
        }
        photoId = nil
        delegate = nil
    }
}
