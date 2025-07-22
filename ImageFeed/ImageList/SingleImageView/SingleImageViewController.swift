import UIKit

final class SingleImageViewController: UIViewController {
    private var scrollView = UIScrollView()
    private var singleImageView = UIImageView()
    private var backButton = UIButton(type: .system)
    private var shareButton = UIButton(type: .system)
    private var imageHeight = NSLayoutConstraint()
    private var imageWidth = NSLayoutConstraint()

    var image: UIImage? {
        didSet {
            guard let image else { return }
            if isViewLoaded {
                singleImageView.image = image
                imageWidth.constant = image.size.width
                imageHeight.constant = image.size.height
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        setupView()
        setupScroll()
        if let image = image, singleImageView.image == nil {
            singleImageView.image = image
            imageWidth.constant = image.size.width
            imageHeight.constant = image.size.height
            rescaleAndCenterImageInScrollView(image: image)
        }
        print("SingleImageViewController: viewDidLoad, image: \(singleImageView.image != nil)")
    }

    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)

        scrollView.backgroundColor = UIColor(resource: .ypBlack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        singleImageView.backgroundColor = UIColor(resource: .ypBlack)
        singleImageView.contentMode = .scaleAspectFit
        singleImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(singleImageView)

        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.tintColor = UIColor(resource: .ypWhite)
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = UIColor(resource: .ypWhite)
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            singleImageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 130),
            backButton.heightAnchor.constraint(equalToConstant: 42),

            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        imageWidth = singleImageView.widthAnchor.constraint(equalToConstant: 0)
        imageHeight = singleImageView.heightAnchor.constraint(equalToConstant: 0)
        imageWidth.isActive = true
        imageHeight.isActive = true
    }

    func setupScroll() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }

    // MARK: Buttons actions

    @objc func backButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func shareButtonTap(_ sender: Any) {
        guard let image = singleImageView.image else {
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

        let horizontalInset = max(0, (newContentSize.width) / 2)
        let verticalInset = max(0, (newContentSize.height) / 2)
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
        return singleImageView
    }
}
