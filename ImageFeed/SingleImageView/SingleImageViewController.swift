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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        SingleImageView.image = image
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
        
        //Размеры экрана и фотки
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        //Минимальный и максимальный масштаб
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        //Вычисляем масштаб
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(minZoomScale, min(maxZoomScale, max(hScale, vScale)))
        
        //Устанавливаем масштаб
        scrollView.setZoomScale(scale, animated: false)
        
        //Убеждаемся, что layout обновился после изменения масштаба
        scrollView.layoutIfNeeded()
        
        let newContenSize = scrollView.contentSize

        let horizontalInset = min(0, (visibleRectSize.width - newContenSize.width) / 2)
        let verticalInset = max(0, ((visibleRectSize.height - 0) - newContenSize.height) / 2)
        //Устанавливаем изображение по середине
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    
}
    
    
    // MARK: Extensions
    
    extension SingleImageViewController: UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return SingleImageView
        }
    }

