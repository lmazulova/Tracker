
import UIKit

enum ControllersIdentifier: String {
    case habit = "Привычка"
    case irregularEvent = "Нерегулярное событие"
}

final class TrackerCreationViewController: UIViewController {
    
    //т.к. тому кто реализует TrackerPresenterProtocol не нужно знать ничего о классе который управляет созданием ячейки, делегат можно сделать одностронним, и тогда приставка weak не нужна, т.к. нет условий для retain cycle
    var delegate: TrackerPresenterProtocol?

    private var scheduleSelected: Bool = false
    private var titleFilled: Bool = false
    
    var identifier: ControllersIdentifier
    var schedule: Schedule?
    var trackerTitle: String?
    var categoryTitle: String?
    
    init(identifier: ControllersIdentifier) {
        self.identifier = identifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Properties
    private let characterLimit = 38
    // UI Elements
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "deleteButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(clearTextView), for: .touchUpInside)
        return button
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = "Введите название трекера"
        label.textColor = UIColor.customGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 2
        textView.textContainer.heightTracksTextView = true
        textView.textContainer.lineBreakMode = .byTruncatingHead
        
        let paragrafStyle = NSMutableParagraphStyle()
        paragrafStyle.lineSpacing = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .paragraphStyle: paragrafStyle
        ]
        textView.typingAttributes = attributes
        
        return textView
    }()

    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .customBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        view.addSubview(deleteButton)
        textView.addSubview(placeHolderLabel)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -41),
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            deleteButton.heightAnchor.constraint(equalToConstant: 17),
            deleteButton.widthAnchor.constraint(equalToConstant: 17),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            placeHolderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeHolderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        if identifier == ControllersIdentifier.irregularEvent && titleFilled {
            createButton.backgroundColor = UIColor.customBlack
            createButton.isEnabled = true
        }
        else if titleFilled && scheduleSelected {
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
        textView.delegate = self
        categoryTitle = "Важное"
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
        let tracker = Tracker(id: UUID(), title: trackerTitle!, color: UIColor.colorSelection1, emoji: "✨", schedule: schedule)
        delegate?.addTracker(for: TrackerCategory(categoryTitle: categoryTitle!, trackersInCategory: [tracker]))
        delegate?.cancelingTrackerCreation()
    }
     
    @objc
    func clearTextView() {
        textView.text = ""
        warningLabel.isHidden = true
        deleteButton.isHidden = true
        placeHolderLabel.isHidden = false
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
                self.tableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCell.identifier) as? ItemsCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.setupCellTitle(title: "Категория")
            cell.setupSelectedCategory(title: categoryTitle)
            if identifier == ControllersIdentifier.irregularEvent {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            }
            
            return cell
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        cell.setupCellTitle(title: "Расписание")
        cell.setupSelectedSchedule(schedule: schedule)
        return cell
    }
}

// MARK: - UITableViewCell
final class ItemsCell: UITableViewCell {
    
    static let identifier = "Item cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.accessoryType = .disclosureIndicator
        self.accessoryView = UIImageView(image: UIImage(named: "chevronRight"))
        self.selectionStyle = .none
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, selectedItemsLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        
        NSLayoutConstraint.activate([
            
        ])
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .customBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private let selectedItemsLabel: UILabel = {
        let selectedItemsLabel = UILabel()
        selectedItemsLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        selectedItemsLabel.textColor = .customGray
        selectedItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedItemsLabel.isHidden = true
        
        return selectedItemsLabel
    }()
    
    private func setupConstraints() {
        self.addSubview(stackView)
        selectedItemsLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -56),
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            selectedItemsLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            selectedItemsLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
    
    func setupCellTitle(title: String) {
        titleLabel.text = title
    }
    
    func setupSelectedSchedule(schedule: Schedule?) {
        guard let schedule = schedule else { return }
        selectedItemsLabel.isHidden = false
        if schedule.days.count == 7 {
            selectedItemsLabel.text = "Каждый день"
        }
        else {
            let days = schedule.days
            .sorted {WeekDay.allCases.firstIndex(of: $0)! < WeekDay.allCases.firstIndex(of: $1)! }
            var labelText = ""
            for day in days {
                switch day {
                case .monday:
                    labelText += "Пн, "
                case .tuesday:
                    labelText += "Вт, "
                case .wednesday:
                    labelText += "Ср, "
                case .thursday:
                    labelText += "Чт, "
                case .friday:
                    labelText += "Пт, "
                case .saturday:
                    labelText += "Сб, "
                case .sunday:
                    labelText += "Вс, "
                }
            }
            labelText.removeLast(2)
            selectedItemsLabel.text = labelText
        }
    }
    
    func setupSelectedCategory(title: String?) {
        guard let title = title else { return }
        selectedItemsLabel.text = title
        selectedItemsLabel.isHidden = false
    }
}

extension TrackerCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        deleteButton.isHidden = textView.text.isEmpty
        placeHolderLabel.isHidden = !textView.text.isEmpty
        if textView.text.isEmpty {
            warningLabel.isHidden = true
            titleFilled = false
            checkingButtonActivation()
            return
        }
        
        if textView.text.count > characterLimit {
            warningLabel.isHidden = false
            titleFilled = false
            checkingButtonActivation()
        }
        
        else {
            warningLabel.isHidden = true
            setTitle(title: textView.text)
        }
    }
}
