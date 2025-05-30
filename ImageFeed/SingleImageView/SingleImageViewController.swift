import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            SingleImageView.image = image
            if let image = image {
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var SingleImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        SingleImageView.image = image
        // Изменение констант размера, чтобы всё считалось правильно
        imageWidth.constant = SingleImageView.image?.size.width ?? 0
        imageHeight.constant = SingleImageView.image?.size.height ?? 0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if let image = image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: Buttons actions

    @IBAction func BackButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func ShareButtonTap(_ sender: Any) {
        guard let image = SingleImageView.image else {
            return
        }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        present(activityController, animated: true, completion: nil)
    }

    // MARK: Rescale and center

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        // Размеры экрана и фотки
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        // Минимальный и максимальный масштаб
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        // Вычисляем масштаб
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(minZoomScale, min(maxZoomScale, max(hScale, vScale)))

        // Устанавливаем масштаб
        scrollView.setZoomScale(scale, animated: false)

        // Убеждаемся, что layout обновился после изменения масштаба
        scrollView.layoutIfNeeded()

        let newContentSize = scrollView.contentSize

        let horizontalInset = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let verticalInset = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        // Добавляем inset
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        
        // Высчитываем центр
        let xOffset = max(0, (newContentSize.width - visibleRectSize.width) / 2)
        let yOffset = max(0, (newContentSize.height - visibleRectSize.height) / 2)
        // Устанавливаем центр
        scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
        
    }
}

// MARK: Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return SingleImageView
    }
}
