import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            SingleImageView.image = image
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var SingleImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        SingleImageView.image = image
    }
    @IBAction func BackButtonTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
