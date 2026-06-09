import UIKit
import CoreLocation


class WelcomeController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    
    @IBOutlet weak var westImageView: UIImageView!
    @IBOutlet weak var eastImageView: UIImageView!
    
    var isInEast: Bool = true
    let locationManager = CLLocationManager()
    let centerLongitude: CLLocationDegrees = 34.817589 // Afeka

       override func viewDidLoad() {
           super.viewDidLoad()
           
           locationManager.delegate = self
           locationManager.requestWhenInUseAuthorization()
           
           greetingLabel.text = ""
           insertButton.isEnabled = true

           if let name = UserDefaults.standard.string(forKey: "playerName") {
               greetingLabel.text = "Hi, \(name)!"
               nameTextField.isHidden = true
               insertButton.isHidden = true
               startGameButton.isEnabled = true
               startGameButton.alpha = 1.0
               
               let savedIsInEast = UserDefaults.standard.bool(forKey: "isInEast")
               updateMapUI(for: savedIsInEast)
           } else {
               startGameButton.isEnabled = false
               startGameButton.alpha = 0.5
           }
       }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        isInEast = location.coordinate.longitude >= centerLongitude
        UserDefaults.standard.set(isInEast, forKey: "isInEast")
        updateMapUI(for: isInEast)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

       @IBAction func insertNameTapped(_ sender: UIButton) {
           guard let name = nameTextField.text,
                 !name.isEmpty,
                 name != nameTextField.placeholder else {
               return
           }

           UserDefaults.standard.set(name, forKey: "playerName")
           greetingLabel.text = "Hi, \(name)!"
           nameTextField.isHidden = true
           insertButton.isHidden = true
           startGameButton.isEnabled = true

           UIView.animate(withDuration: 0.3) {
               self.startGameButton.alpha = 1.0
           }

           locationManager.requestLocation()
       }

       func updateMapUI(for isInEast: Bool) {
           eastImageView.alpha = isInEast ? 1.0 : 0.3
           westImageView.alpha = isInEast ? 0.3 : 1.0
       }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameVC",
           let gameVC = segue.destination as? GameController {
            let savedIsInEast = UserDefaults.standard.bool(forKey: "isInEast")
            gameVC.isInEast = savedIsInEast
        }
    }
}
