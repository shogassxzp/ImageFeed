import Foundation

final class ImageListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?

    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared

    private init() {}

    struct PhotoResult: Codable {
        let id: String
        let createdAt: String?
        let width: Int
        let height: Int
        let description: String?
        let urls: UrlsResult
        let likedByUser: Bool
    }

    struct UrlsResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }

    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool

        // for decoder
        init(from result: PhotoResult) {
            id = result.id
            size = CGSize(width: result.width, height: result.height)
            createdAt = result.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) }
            welcomeDescription = result.description
            thumbImageURL = result.urls.thumb
            largeImageURL = result.urls.regular
            isLiked = result.likedByUser
        }

        // for local changes
        init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
            self.id = id
            self.size = size
            self.createdAt = createdAt
            self.welcomeDescription = welcomeDescription
            self.thumbImageURL = thumbImageURL
            self.largeImageURL = largeImageURL
            self.isLiked = isLiked
        }
    }

    func fetchPhotosNextPage() {
        guard task == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeNextPageRequest(page: nextPage) else {
            print("Не удалось создать запрос для получения фото")
            return
        }

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil

            switch result {
            case let .success(photoResult):
                print("[ImageListServise]: Загрузка JSON успешна")
                let newPhotos = photoResult.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                }
            case let .failure(error):
                print("[ImageListServise]: Ошибка загрузки \(error)")
            }
        }
        task?.resume()
    }

    private func makeNextPageRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(storage.token ?? " ")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard task == nil else {
            print("[ImageListService]: Запрос уже выполняется")
            completion(.failure(NetworkError.alreadyInProgress))
            return
        }
        guard let request = makeRequestForLike(photoId: photoId, isLiked: isLike) else {
            print("[ImageListService]: Не удалось создать запрос для лайка")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        print("[ImageListService]: Отправляем \(isLike ? "POST" : "DELETE") запрос")
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            guard let self else { return }
            self.task = nil

            switch result {
            case let .success(photoResult):
                print("[ImageListService]: Лайк для фото изменён")
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: photoResult.likedByUser
                        )
                        self.photos[index] = newPhoto
                        NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                        completion(.success(()))
                    } else {
                        print("[ImageListService]: Фото \(photoId) не найдено в массиве")
                        completion(.failure(NetworkError.invalidRequest))
                    }
                }
            case .failure(let error):
                print("[ImageListService]: Ошибка лайка \(error)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    private func makeRequestForLike(photoId: String, isLiked: Bool) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(storage.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLiked ? "POST" : "DELETE"
        return request
    }
}

extension ImageListService {
    static let shared = ImageListService()
}
