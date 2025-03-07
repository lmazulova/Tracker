
import UIKit

final class HabitCreationViewController: UIViewController {
    // MARK: - Private Properties
    private let characterLimit = 38
    
    // UI Elements
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor.customBlack
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.rightViewMode = .whileEditing
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(named: "deleteButton"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonView = UIView()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 17),
            deleteButton.heightAnchor.constraint(equalToConstant: 17),
            buttonView.widthAnchor.constraint(equalToConstant: 29)
        ])
        
        deleteButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        textField.rightView = buttonView
        
        return textField
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .customBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(characterLimit) символов"
        label.textColor = UIColor.customRed
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let navigationBar = UINavigationBar()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customRed.cgColor
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.customRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .clear

        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.customGray
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.register(ItemsCell.self, forCellReuseIdentifier: ItemsCell.identifier)
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        tableView.delegate = self
        tableView.dataSource = self
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Configuration
    private func setupConstraints() {
        let textFieldStack = UIStackView(arrangedSubviews: [textFieldView, warningLabel])
        textFieldStack.translatesAutoresizingMaskIntoConstraints = false
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 8
        warningLabel.isHidden = true
        
        view.addSubview(textFieldStack)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textFieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldStack.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
            textFieldView.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
            textFieldView.heightAnchor.constraint(equalToConstant: 75),
            warningLabel.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
            warningLabel.centerXAnchor.constraint(equalTo: textFieldStack.centerXAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            tableView.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(characterLimitReached), for: .editingChanged)
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        let title = UINavigationItem(title: "Новая привычка")
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.customBlack
        ]
        
        navigationBar.barTintColor = .customWhite
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Actions
    @objc
    func cancelButtonTapped() {
        (0..<2).forEach{ _ in
            if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true)
            }
        }
    }
    
    @objc
    func createButtonTapped() {
        
    }
    
    @objc
    func characterLimitReached() {
        guard let text = textField.text else {
            warningLabel.isHidden = true
            return
        }
        if text.count > characterLimit {
            warningLabel.isHidden = false
        }
        else {
            warningLabel.isHidden = true
        }
    }
    
    @objc
    func clearTextField() {
        textField.text = ""
        warningLabel.isHidden = true
    }
}


// MARK: - UITableViewDelegate
extension HabitCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            let scheduleViewController = ScheduleViewController()
            present(scheduleViewController, animated: false)
        default:
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension HabitCreationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCell.identifier) else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            return cell
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        cell.textLabel?.text = "Расписание"
        return cell
    }
}

// MARK: - UITableViewCell
final class ItemsCell: UITableViewCell {
    
    static let identifier = "Item cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textLabel?.textColor = .customBlack
        self.accessoryType = .disclosureIndicator
        self.accessoryView = UIImageView(image: UIImage(named: "chevronRight"))
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

