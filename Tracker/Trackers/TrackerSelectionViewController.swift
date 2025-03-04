import UIKit

final class TrackerSelectionViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        setupNavigationBar()
        setupConstraintsAndActions()
        
    }
    
    private func setupConstraintsAndActions() {
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            habitButton.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    @objc func habitButtonTapped() {
        let habitCreationViewController = HabitCreationViewController()
        present(habitCreationViewController, animated: true)
    }
    
    @objc func irregularEventButtonTapped() {
        let irregularEventCreationViewController = IrregularEventCreationViewController()
        present(irregularEventCreationViewController, animated: true)
    }
    
}



