import Foundation

final class ImageListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    static let likeChangedNotification = Notification.Name(rawValue: "likeSucess")

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
        let fullImageURL: String
        var isLike: Bool

        // for decoder
        init(from result: PhotoResult) {
            id = result.id
            size = CGSize(width: result.width, height: result.height)
            createdAt = result.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) }
            welcomeDescription = result.description
            thumbImageURL = result.urls.thumb
            fullImageURL = result.urls.full
            isLike = result.likedByUser
        }

        // for local changes
        init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, fullImageURL: String, isLike: Bool) {
            self.id = id
            self.size = size
            self.createdAt = createdAt
            self.welcomeDescription = welcomeDescription
            self.thumbImageURL = thumbImageURL
            self.fullImageURL = fullImageURL
            self.isLike = isLike
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
        request.httpMethod = HTTPMethod.get
        return request
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard task == nil else {
            print("[ImageListService]: Запрос уже выполняется, пропускаем changeLike")
            completion(.failure(NetworkError.alreadyInProgress))
            return
        }

        guard let request = makeRequestForLike(photoId: photoId, isLiked: isLike) else {
            print("[ImageListService]: Не удалось создать запрос для лайка фото \(photoId)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        print("[ImageListService]: Отправляем \(isLike ? "POST" : "DELETE") запрос для фото \(photoId)\(Date())")
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            self.task = nil

            if let error {
                print("[ImageListService]: Ошибка лайка: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                print("[ImageListService]: Неверный HTTP-статус: \(String(describing: response))")
                completion(.failure(NetworkError.invalidRequest))
                return
            }

            guard let data else {
                print("[ImageListService]: Данные не получены")
                completion(.failure(NetworkError.invalidRequest))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let photoData = json?["photo"], let photoDataEncoded = try? JSONSerialization.data(withJSONObject: photoData) else {
                    print("[ImageListService]: Не удалось извлечь поле 'photo'")
                    completion(.failure(NetworkError.invalidRequest))
                    return
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let photoResult = try decoder.decode(PhotoResult.self, from: photoDataEncoded)

                print("[ImageListService]: Лайк для фото \(photoId) успешно изменён, likedByUser: \(photoResult.likedByUser)")
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLike = photoResult.likedByUser 

                        NotificationCenter.default.post(
                            name: ImageListService.likeChangedNotification,
                            object: nil,
                            userInfo: ["photoId": photoId]
                        )
                        completion(.success(()))
                    } else {
                        print("[ImageListService]: Фото \(photoId) не найдено в массиве photos")
                        completion(.failure(NetworkError.invalidRequest))
                    }
                }
            } catch {
                print("[ImageListService]: Ошибка декодирования: \(error)")
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
        request.httpMethod = isLiked ? HTTPMethod.post : HTTPMethod.delete
        return request
    }
}

extension ImageListService {
    static let shared = ImageListService()
}
