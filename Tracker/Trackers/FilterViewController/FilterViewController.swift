import UIKit

enum FilterModes: String {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

protocol FilterDelegate: AnyObject {
    func filterTracker(with mode: FilterModes, date: Date)
}

final class FilterViewController: UIViewController {
    private var selectedMode: FilterModes {
        return filters.filter{ $0.isSelected }.first?.mode ?? .all
    }
    
    var selectedDate: (() -> Date)?
    
//  Действия которые должен делать TrackersViewController при установке фильтра
    var allSelected: (() -> Void)?
    var todaySelected: (() -> Void)?
    var completedSelected: (() -> Void)?
    var notCompletedSelected: (() -> Void)?
    var filterSelected: (() -> Void)?
    
    weak var delegate: FilterDelegate?
    
    private var filters: [FilterCellModel] = [
        FilterCellModel(mode: FilterModes.all, isSelected: false),
        FilterCellModel(mode: FilterModes.today, isSelected: false),
        FilterCellModel(mode: FilterModes.completed, isSelected: false),
        FilterCellModel(mode: FilterModes.notCompleted, isSelected: false)
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .customGray
        tableView.allowsMultipleSelection = false
        
        return tableView
    }()
    
    private let navigationBar = UINavigationBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let title = UINavigationItem(title: "Фильтры")
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

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterCell else {
            return
        }
        filters[indexPath.row].isSelected = true
        cell.setup(with: filters[indexPath.row])
        guard let selectedDate = selectedDate else {
            print("[\(#function)] - Текущая дата не указана.")
            return
        }
        delegate?.filterTracker(with: selectedMode, date: selectedDate())
        switch selectedMode {
        case .all:
            self.allSelected?()
        case .completed:
            self.completedSelected?()
        case .notCompleted:
            self.notCompletedSelected?()
        case .today:
            self.todaySelected?()
        }
        DispatchQueue.main.async {
            self.filterSelected?()
        }
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            filters[indexPath.row].isSelected = false
            cell.accessoryType = .none
        }
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell
        else {
            return UITableViewCell()
        }
        
        let cellViewModel = filters[indexPath.row]
        cell.setup(with: cellViewModel)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }
}
