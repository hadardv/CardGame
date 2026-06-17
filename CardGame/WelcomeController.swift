import UIKit
import CoreLocation

class WelcomeController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!

    @IBOutlet weak var westImageView: UIImageView!
    @IBOutlet weak var eastImageView: UIImageView!

    var isInEast = true
    private var hasReceivedLocation = false

    let locationManager = CLLocationManager()
 
    let centerLongitude: CLLocationDegrees = 34.817549168324334

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        setupPlayerNameUI()
        updateMapUI(for: false)
        updateStartButtonState()
        applyLabelColors()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocationIfAuthorized()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyLabelColors()
        }
    }

    /// Shows the name entry UI on first launch, or the saved greeting on later visits.
    private func setupPlayerNameUI() {
        if let name = UserDefaults.standard.string(forKey: "playerName") {
            greetingLabel.text = "Hi \(name)"
            nameTextField.isHidden = true
            insertButton.isHidden = true
        } else {
            greetingLabel.text = ""
            nameTextField.isHidden = false
            insertButton.isHidden = false
        }
    }

    /// Requests a one-time location sample when permission is granted.
    private func requestLocationIfAuthorized() {
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }

        hasReceivedLocation = false
        locationManager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        isInEast = location.coordinate.longitude >= centerLongitude
        UserDefaults.standard.set(isInEast, forKey: "isInEast")

        hasReceivedLocation = true
        updateMapUI(for: isInEast)
        updateStartButtonState()
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
        greetingLabel.text = "Hi \(name)"
        nameTextField.isHidden = true
        insertButton.isHidden = true
        updateStartButtonState()
    }

    /// Highlights the player's side once location is known.
    func updateMapUI(for isInEast: Bool) {
        guard hasReceivedLocation else {
            eastImageView.alpha = 0.3
            westImageView.alpha = 0.3
            return
        }

        eastImageView.alpha = isInEast ? 1.0 : 0.3
        westImageView.alpha = isInEast ? 0.3 : 1.0
    }

    /// START is enabled only when both a name and a location are available.
    private func updateStartButtonState() {
        let hasName = UserDefaults.standard.string(forKey: "playerName") != nil
        let isReady = hasName && hasReceivedLocation

        startGameButton.isEnabled = isReady
        startGameButton.alpha = isReady ? 1.0 : 0.5
    }

    private func applyLabelColors() {
        let color = UIColor.label
        greetingLabel.textColor = color
        applyLabelColor(in: view, color: color)
    }

    private func applyLabelColor(in view: UIView, color: UIColor) {
        if let label = view as? UILabel, label !== greetingLabel {
            label.textColor = color
        }
        view.subviews.forEach { applyLabelColor(in: $0, color: color) }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameVC",
           let gameVC = segue.destination as? GameController {
            gameVC.isInEast = isInEast
        }
    }
}
