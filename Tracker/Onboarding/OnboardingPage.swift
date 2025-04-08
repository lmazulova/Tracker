import UIKit

enum OnboardingPageState: String {
    case firstScreen = "Отслеживайте только то, что хотите"
    case secondScreen = "Даже если это не литры воды и йога"
}

final class OnboardingPage: UIViewController {
    
    init(state: OnboardingPageState = .firstScreen) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var state: OnboardingPageState
    
    lazy var backgroundImage: UIImageView = {
        let imageName = state == .firstScreen ? "backgroundFirst" : "backgroundSecond"
        let image = UIImage(named: imageName) ?? UIImage()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var okButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showTabBarController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = state.rawValue
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(backgroundImage)
        view.addSubview(okButton)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -160),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func showTabBarController() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let window = UIApplication.shared.windows.first
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        UIView.transition(with: window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }
}
