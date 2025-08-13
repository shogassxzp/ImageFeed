import Foundation

protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewProtocol? { get set }
    func viewDidLoad()
    func didSelectPhoto(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func willDisplayCell(at indexPath: IndexPath)
}

final class ImageListPresenter: ImageListPresenterProtocol {
    weak var view: ImageListViewProtocol?
    private let imageListService = ImageListService.shared
    private var notificationObserver: NSObjectProtocol?

    init(view: ImageListViewProtocol) {
        self.view = view
        setupObserver()
    }

    func viewDidLoad() {
        view?.showLoading()
        imageListService.fetchPhotosNextPage()
        updatePhotos()
    }

    func didSelectPhoto(at indexPath: IndexPath) {
        let photo = imageListService.photos[indexPath.row]
        view?.presentDetailViewController(for: photo, at: indexPath)
    }

    func didTapLike(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let photo = imageListService.photos[indexPath.row]
        view?.showLoading()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLike) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.view?.hideLoading()
                switch result {
                case .success:
                    let updatedPhoto = self.imageListService.photos[indexPath.row]
                    completion(updatedPhoto.isLike)
                    print("[ImageListPresenter]: Лайк обновлён для photoId: \(photo.id), isLiked: \(updatedPhoto.isLike)")
                case let .failure(error):
                    completion(photo.isLike)
                    print("[ImageListPresenter]: Ошибка обновления лайка: \(error)")
                }
            }
        }
    }

    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
            print("[ImageListPresenter]: Запрошена следующая страница при indexPath: \(indexPath)")
        }
    }

    private func setupObserver() {
        notificationObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updatePhotos()
            print("[ImageListPresenter]: Получено уведомление об обновлении фото")
        }
    }

    private func updatePhotos() {
        view?.updatePhotos(imageListService.photos)
        view?.hideLoading()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("[ImageListPresenter]: Deinit")
    }
}
