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
        addSubviews()
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        [tableImageView, gradientView, tableDataLabel, tableLikeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupCell() {
        contentView.backgroundColor = UIColor(resource: .ypBlack)
        // imageView settings
        tableImageView.contentMode = .center
        tableImageView.layer.masksToBounds = true
        tableImageView.layer.cornerRadius = 16
        tableImageView.backgroundColor = .ypWhiteAlpha
        // gradientView settings
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 16
        // dataLabel settings
        tableDataLabel.font = .systemFont(ofSize: 13)
        tableDataLabel.textColor = UIColor(resource: .ypWhite)
        // likeButton settings
        tableLikeButton.setImage(UIImage(resource: .noActive), for: .normal)
        tableLikeButton.tintColor = .ypWhite
        tableLikeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
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
            placeholder: UIImage(resource: .scribble),
        ) { [weak tableView] result in
            guard let tableView else { return }

            switch result {
            case .success:
                print("[KF]: Изображение загружено, устанавливаю")
                tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableImageView.contentMode = .scaleAspectFit
                self.tableImageView.backgroundColor = .ypBlack
            case let .failure(error):
                print("[KF]: Ошибка загрузки изображения \(error)")
                return
            }
        }
        tableDataLabel.text = photo.createdAt?.formattedDate() ?? "Дата неизвестна"
        tableLikeButton.setImage(UIImage(resource: photo.isLike ? .active : .noActive), for: .normal)
        tableLikeButton.tintColor = photo.isLike ? .ypRed : .ypGray
        photoId = photo.id

        if let observer = likeNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        likeNotificationObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.likeChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let userInfo = notification.userInfo,
                  let photoId = userInfo["photoId"] as? String,
                  let currentPhoto = ImageListService.shared.photos.first(where: { $0.id == photoId })
            else { return }

            if self.photoId == photoId {
                self.setLikeButtonState(isLiked: currentPhoto.isLike)
            }
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
        tableImageView.contentMode = .center
        tableImageView.backgroundColor = .ypWhiteAlpha
        tableDataLabel.text = nil
        tableLikeButton.setImage(.noActive, for: .normal)
        if let observer = likeNotificationObserver {
            NotificationCenter.default.removeObserver(observer)
            likeNotificationObserver = nil
        }
        photoId = nil
        delegate = nil
    }
}
