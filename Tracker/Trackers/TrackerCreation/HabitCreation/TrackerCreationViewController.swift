
import UIKit

enum ControllersIdentifier: String {
    case habit = "Привычка"
    case irregularEvent = "Нерегулярное событие"
}

final class TrackerCreationViewController: UIViewController {
    
    private var scheduleSelected: Bool = false
    private var titleFilled: Bool = false
    
    var identifier: ControllersIdentifier
    var schedule: Schedule?
    var trackerTitle: String?
    
    init(identifier: ControllersIdentifier) {
        self.identifier = identifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //т.к. тому кто реализует TrackerPresenterProtocol не нужно знать ничего о классе который управляет созданием ячейки, делегат можно сделать одностронним, и тогда приставка weak не нужна, т.к. нет условий для retain cycle
    var delegate: TrackerPresenterProtocol?
    
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
        button.setTitleColor(UIColor.customWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        
        return button
    }()
    
    private func checkingButtonActivation() {
        if titleFilled && scheduleSelected {
            createButton.backgroundColor = UIColor.customBlack
            createButton.isEnabled = true
        }
        else {
            createButton.backgroundColor = UIColor.customGray
            createButton.isEnabled = false
        }
    }
    
    private func setSchedule(for weekDays: Set<WeekDay>) {
        schedule = Schedule(days: weekDays)
        scheduleSelected = true
        checkingButtonActivation()
    }
    
    private func setTitle(title: String) {
        trackerTitle = title
        titleFilled = true
        checkingButtonActivation()
    }
    
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
            tableView.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 24)
        ])
        if identifier == ControllersIdentifier.habit {
            tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
        else {
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }
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
        delegate?.cancelingTrackerCreation()
    }
    
    @objc
    func createButtonTapped() {
        let tracker = Tracker(id: UUID(), title: trackerTitle!, color: UIColor.colorSelection1, emoji: "✨", schedule: schedule!)
        delegate?.addTracker(for: TrackerCategory(categoryTitle: "Важное", trackersInCategory: [tracker]))
        delegate?.cancelingTrackerCreation()
    }
    
    @objc
    func characterLimitReached() {
        guard let text = textField.text else {
            warningLabel.isHidden = true
            titleFilled = false
            checkingButtonActivation()
            return
        }
        if text.count > characterLimit {
            warningLabel.isHidden = false
            titleFilled = false
            checkingButtonActivation()
        }
        else {
            warningLabel.isHidden = true
            setTitle(title: text)
        }
    }
    
    @objc
    func clearTextField() {
        textField.text = ""
        warningLabel.isHidden = true
        titleFilled = false
        checkingButtonActivation()
    }
}


// MARK: - UITableViewDelegate
extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.addSchedule = { [weak self] selectedWeekDays in
                guard let self = self else { return }
                setSchedule(for: selectedWeekDays)
            }
            present(scheduleViewController, animated: false)
        default:
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension TrackerCreationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if identifier == ControllersIdentifier.habit { return 2}
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCell.identifier) else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            if identifier == ControllersIdentifier.irregularEvent {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            }
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

