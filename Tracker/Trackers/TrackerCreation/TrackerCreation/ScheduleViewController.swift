import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private Properties
    // UI Elements
    private let navigationBar = UINavigationBar()
    var selectedWeekDays: Set<WeekDay> = []
    var addSchedule: ((Set<WeekDay>) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(DayOfWeekCell.self, forCellReuseIdentifier: DayOfWeekCell.identifier)
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
    
    override func viewDidLayoutSubviews() {
        tableView.rowHeight = max(75, (tableView.frame.height/7))
    }
    
    // MARK: - UI Configuration
    private func setupConstraints() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
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
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39),
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
    @objc private func doneButtonTapped() {
        addSchedule?(selectedWeekDays)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate&DayOfWeekCellDelegate {
    func didToggleSwitch(for day: WeekDay, isOn: Bool) {
        if isOn {
            selectedWeekDays.insert(day)
        }
        else {
            selectedWeekDays.remove(day)
        }
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DayOfWeekCell.identifier) as? DayOfWeekCell else { return UITableViewCell()}
        let day = WeekDay.allCases[indexPath.row]
        cell.configureCell(with: day)
        cell.delegate = self
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.width)
            return cell
        }
        return cell
    }
}

// MARK: - UITableViewCell
final class DayOfWeekCell: UITableViewCell {
    static let identifier = "Switch cell"
    weak var delegate: DayOfWeekCellDelegate?
    private var day: WeekDay?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    func configureCell(with day: WeekDay) {
        self.backgroundColor = .clear
        self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textLabel?.textColor = .customBlack
        self.selectionStyle = .none
        self.textLabel?.text = day.rawValue
        self.day = day
        
        contentView.addSubview(switcher)
        NSLayoutConstraint.activate([
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.widthAnchor.constraint(equalToConstant: 51),
            switcher.heightAnchor.constraint(equalToConstant: 31)
        ])
        switcher.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    @objc private func switchChanged() {
        guard let day = day else { return }
        delegate?.didToggleSwitch(for: day, isOn: switcher.isOn)
    }
}

protocol DayOfWeekCellDelegate: AnyObject {
    func didToggleSwitch(for day: WeekDay, isOn: Bool)
}
