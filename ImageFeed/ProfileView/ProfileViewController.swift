//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Игнат Рогачевич on 21.05.25.
//

import UIKit

final class ProfileViewController:UIViewController {
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var UserPhotoImageVIew: UIImageView!
    
    @IBOutlet weak var BioLabel: UILabel!
    @IBOutlet weak var UserNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func LogoutPressed(_ sender: Any) {
    }
}
