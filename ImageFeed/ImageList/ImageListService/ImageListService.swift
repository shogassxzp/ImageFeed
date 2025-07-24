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
        
        init(from result: PhotoResult) {
                self.id = result.id
                self.size = CGSize(width: result.width, height: result.height)
                self.createdAt = result.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) }
                self.welcomeDescription = result.description
                self.thumbImageURL = result.urls.thumb
                self.largeImageURL = result.urls.regular
                self.isLiked = result.likedByUser
            }
    }

    
     func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeNextPageRequest(page: nextPage) else {
            print("Не удалось создать запрос для получения фото")
            return
        }
                
        task = urlSession.objectTask(for: request) {[weak self] (result: Result<[PhotoResult],Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let photoResult):
                print("[ImageListServise]: Загрузка JSON успешна")
                let newPhotos = photoResult.map { Photo(from: $0) }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                }
            case .failure(let error):
                print("[ImageListServise]: Ошибка загрузки \(error)")
            }
        }
        task?.resume()
    }
    
    private func makeNextPageRequest(page: Int) -> URLRequest? {
        
        guard let url = URL(string:"https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(storage.token ?? " ")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}

extension ImageListService {
    static let shared = ImageListService()
}
