import UIKit

final class TrackerSelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    private let habitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.setTitle(ControllersIdentifier.habit.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.setTitle(ControllersIdentifier.irregularEvent.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navigationBar = UINavigationBar()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        setupNavigationBar()
        setupConstraintsAndActions()
        
    }
    
    // MARK: - UI Configuration
    private func setupConstraintsAndActions() {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        view.addSubview(stackView)
        
        habitButton.addTarget(self, action: #selector(TrackerCreationButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(TrackerCreationButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 114/2),
            habitButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            habitButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        let title = UINavigationItem(title: "Создание трекера")
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.customBlack
        ]
        
        navigationBar.barTintColor = .customWhite
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        
        
        NSLayoutConstraint.activate([
            navigationBar.heightAnchor.constraint(equalToConstant: 114),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func TrackerCreationButtonTapped(_ button: UIButton) {
        if let buttonTitle = button.titleLabel?.text {
            if let identifier = ControllersIdentifier(rawValue: buttonTitle) {
                let creationViewController = TrackerCreationViewController(identifier: identifier)
                if let tabBarController = self.view.window?.rootViewController as? TabBarController {
                    guard let trackerViewController = tabBarController.viewControllers?.first as? TrackersViewController else { 
                        print("[\(#function)] - ошибка перенаправления на TrackersViewController")
                        return }
                    creationViewController.delegate = trackerViewController
                    present(creationViewController, animated: true)
                }
            }
        }
    }
}



