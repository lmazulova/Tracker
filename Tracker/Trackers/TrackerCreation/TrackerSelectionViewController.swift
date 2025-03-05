import UIKit

final class TrackerSelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    private let habitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
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
    @objc func habitButtonTapped() {
        let habitCreationViewController = HabitCreationViewController()
        present(habitCreationViewController, animated: true)
    }
    
    @objc func irregularEventButtonTapped() {
        let irregularEventCreationViewController = IrregularEventCreationViewController()
        present(irregularEventCreationViewController, animated: true)
    }
}



