import UIKit

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
    
    func setupSelectedSchedule(schedule: Set<WeekDay>?) {
        guard let schedule = schedule, !schedule.isEmpty else { return }
        selectedItemsLabel.isHidden = false
        var selectedSchedule = Array(schedule)
        if selectedSchedule.count == 7 {
            selectedItemsLabel.text = "Каждый день"
        }
        else {
            let days = selectedSchedule.sorted {WeekDay.allCases.firstIndex(of: $0)! < WeekDay.allCases.firstIndex(of: $1)! }
            var labelText = ""
            for day in days {
                switch day {
                case .Monday:
                    labelText += "Пн, "
                case .Tuesday:
                    labelText += "Вт, "
                case .Wednesday:
                    labelText += "Ср, "
                case .Thursday:
                    labelText += "Чт, "
                case .Friday:
                    labelText += "Пт, "
                case .Saturday:
                    labelText += "Сб, "
                case .Sunday:
                    labelText += "Вс, "
                }
            }
            if labelText.count > 2 {
                labelText.removeLast(2)
            }
            selectedItemsLabel.text = labelText
        }
    }
    
    func setupSelectedCategory(title: String?) {
        guard let title = title else { return }
        selectedItemsLabel.text = title
        selectedItemsLabel.isHidden = false
    }
}
