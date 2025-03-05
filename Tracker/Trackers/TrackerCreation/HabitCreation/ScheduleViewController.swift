import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Private Properties
    // UI Elements
    private let navigationBar = UINavigationBar()
    var selectedWeekDays: [WeekDay] = []
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(DayOfWeekCell.self, forCellReuseIdentifier: DayOfWeekCell.identifier)
        tableView.rowHeight = 75
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.customBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        tableView.delegate = self
        tableView.dataSource = self
        setupNavigationBar()
        setupConstraints()
    }
    
    // MARK: - UI Configuration
    private func setupConstraints() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39)
        ])
    }

    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let title = UINavigationItem(title: "Расписание")
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.customBlack
        ]
        navigationBar.barTintColor = .customWhite
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayOfWeekCell.identifier) else { return UITableViewCell()}
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = WeekDay.monday.rawValue
            return cell
        case 1:
            cell.textLabel?.text = WeekDay.tuesday.rawValue
            return cell
        case 2:
            cell.textLabel?.text = WeekDay.wednesday.rawValue
            return cell
        case 3:
            cell.textLabel?.text = WeekDay.thursday.rawValue
            return cell
        case 4:
            cell.textLabel?.text = WeekDay.friday.rawValue
            return cell
        case 5:
            cell.textLabel?.text = WeekDay.saturday.rawValue
            return cell
        case 6:
            cell.textLabel?.text = WeekDay.sunday.rawValue
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            return cell
        default:
            return cell
        }
    }
}

// MARK: - UITableViewCell
final class DayOfWeekCell: UITableViewCell {
    static let identifier = "Switch cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textLabel?.textColor = .customBlack
        self.selectionStyle = .none
        contentView.addSubview(switcher)
        NSLayoutConstraint.activate([
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.widthAnchor.constraint(equalToConstant: 51),
            switcher.heightAnchor.constraint(equalToConstant: 31)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = UIColor.customBlue
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
}
