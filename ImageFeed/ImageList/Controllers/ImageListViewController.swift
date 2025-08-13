import UIKit

protocol ImageListViewProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updatePhotos(_ photos: [ImageListService.Photo])
    func showLoading()
    func hideLoading()
    func presentDetailViewController(for photo: ImageListService.Photo, at indexPath: IndexPath)
}

// MARK: Controller

import UIKit

final class ImageListViewController: UIViewController & ImageListViewProtocol {
    var presenter: ImageListPresenterProtocol?
     let tableView = UITableView()
    private var photos: [ImageListService.Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ImageListPresenter(view: self)
        setupTableView()
        presenter?.viewDidLoad()
    }

    private func setupTableView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)

        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func updatePhotos(_ photos: [ImageListService.Photo]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let oldCount = self.photos.count
            self.photos = photos
            let newCount = self.photos.count

            let indexPaths = (oldCount ..< newCount).map { IndexPath(row: $0, section: 0) }
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }

    func presentDetailViewController(for photo: ImageListService.Photo, at indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.setImage(with: photo, indexPath: indexPath)
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true)
        print("[ImageListViewController]: Показан SingleImageViewController для фото: \(photo.id)")
    }
}

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        let photo = photos[indexPath.row]
        cell.delegate = self
        cell.configure(with: photo, tableView: tableView, indexPath: indexPath)
        return cell
    }
}

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectPhoto(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        guard imageViewWidth > 0 else {
            return 30 // Высота gradientView
        }
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImageListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("[ImageListViewController]: Не удалось получить indexPath для ячейки")
            return
        }
        presenter?.didTapLike(at: indexPath) { isLiked in
            cell.setLikeButtonState(isLiked: isLiked)
        }
        print("[ImageListViewController]: Нажат лайк на indexPath: \(indexPath)")
    }
}
