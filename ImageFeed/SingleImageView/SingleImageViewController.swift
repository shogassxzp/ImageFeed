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

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var SingleImageView: UIImageView!

    private var zoomPointBeforeZoom: CGPoint?
    private var lastZoomScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.bounces = false
        SingleImageView.image = image
        SingleImageView.frame.size = image?.size ?? CGSize(width: 1000, height: 600)
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
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let widthScale = visibleRectSize.width / imageSize.width
        let heightScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(widthScale, heightScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        centerImageWithInsets()
    }
    //Center with insets
    private func centerImageWithInsets() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        
        let horizontalInset = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let verticalInset = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        
        //Рассчитываем contentOffset, чтобы фотка была по центру
        let xOffset = max(0, (newContentSize.width - visibleRectSize.width) / 2)
        let yOffset = max(0, (newContentSize.height - visibleRectSize.height) / 2)
        
        //Принудительно устанавливаем contentOffset
        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
        
        //Защита от автоматического сброса contentOffset
        scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
    }
}

// MARK: Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return SingleImageView
    }
    //Запоминаем точку,в координатах контента до зума
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        let visibleRectSize = scrollView.bounds.size
        let contentOffset = scrollView.contentOffset
        let zoomPointX = contentOffset.x + visibleRectSize.width / 2
        let zoomPointY = contentOffset.y + visibleRectSize.height / 2
        zoomPointBeforeZoom = CGPoint(x: zoomPointX, y: zoomPointY)
        lastZoomScale = scrollView.zoomScale // Сохраняем масштаб перед зумом
    }
    //Пересчитываем contentInset, исправляем contentOffset
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale newScale: CGFloat) {
        
        centerImageWithInsets()
        
        if let zoomPoint = zoomPointBeforeZoom {
            let visibleRectSize = scrollView.bounds.size
            let newContentSize = scrollView.contentSize
            
            let oldScale = scrollView.zoomScale / newScale
            
            let newZoomPointX = zoomPoint.x * newScale / oldScale
            let newZoomPointY = zoomPoint.y * newScale / oldScale
            
            let newOffsetX = max(0, min(newZoomPointX - visibleRectSize.width / 2, newContentSize.width - visibleRectSize.width))
            let newOffsetY = max(0, min(newZoomPointY - visibleRectSize.height / 2, newContentSize.height - visibleRectSize.height))
            
            scrollView.setContentOffset(CGPoint(x: newOffsetX, y: newOffsetY), animated: false)
            
            zoomPointBeforeZoom = nil
        }
    }
}
