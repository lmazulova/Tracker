import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "trackerCell"
    var trackerID: UUID?
    var daysAmount: Int = 0
    private var isPinned = false
    weak var delegate: TrackerCellDelegate?
    private let analyticsService = AnalyticsService()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellConstraints()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Interaction
    
    private lazy var interaction = UIContextMenuInteraction(delegate: self)
    
    // MARK: - Private Properties
    
    private var daysString: String { return String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: "number of days in which the task was completed"), daysAmount) }
    private let card: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private let emojiView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.white
        view.alpha = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let quantityManagementView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let dayCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 17
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 10.6, weight: .bold)
        let plusIcon = UIImage(systemName: "plus", withConfiguration: iconConfig)
        button.setImage(plusIcon, for: .normal)
        button.setImage(UIImage(named: "doneButton"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.adjustsImageWhenDisabled = false
        return button
    }()
    
    private lazy var pinView: UIImageView = {
        let image = UIImage(named: "pin")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = !isPinned
        return imageView
    }()
    
    // MARK: - Private Methods
    private func updateDayCounterLabel() {
        if plusButton.isSelected {
            daysAmount += 1
        }
        else {
            daysAmount -= 1
        }
        dayCounterLabel.text = daysString
    }
    
    private func setupCellConstraints() {
        contentView.addSubview(card)
        contentView.addSubview(quantityManagementView)
        quantityManagementView.addSubview(dayCounterLabel)
        quantityManagementView.addSubview(plusButton)
        card.addSubview(cardText)
        card.addSubview(emojiView)
        card.addSubview(emojiLabel)
        card.addSubview(pinView)
        
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.61),
            pinView.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            pinView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            pinView.heightAnchor.constraint(equalToConstant: 12),
            pinView.widthAnchor.constraint(equalToConstant: 8),
            cardText.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            cardText.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            cardText.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            emojiView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            quantityManagementView.topAnchor.constraint(equalTo: card.bottomAnchor),
            quantityManagementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quantityManagementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quantityManagementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dayCounterLabel.leadingAnchor.constraint(equalTo: quantityManagementView.leadingAnchor, constant: 12),
            dayCounterLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: quantityManagementView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: quantityManagementView.topAnchor, constant: 8),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configureCell(for tracker: Tracker, with plusButtonState: Bool, counterValue: Int, currentDate: Date) {
        trackerID = tracker.id
        daysAmount = counterValue
        emojiLabel.text = tracker.emoji
        cardText.text = tracker.title
        card.backgroundColor = tracker.color
        plusButton.isSelected = plusButtonState
        plusButton.isEnabled = (currentDate <= Calendar.current.startOfDay(for: Date()))
        plusButton.backgroundColor = plusButtonState ? tracker.color.withAlphaComponent(0.3) : tracker.color
        dayCounterLabel.text = daysString
        isPinned = tracker.isPinned
        pinView.isHidden = !isPinned
        //Interaction
        card.addInteraction(interaction)
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        plusButton.backgroundColor = plusButton.isSelected ? plusButton.backgroundColor?.withAlphaComponent(0.3) : plusButton.backgroundColor?.withAlphaComponent(1)
        guard let id = trackerID else { return }
        delegate?.updateCompletedTrackers(for: id)
        analyticsService.report(event: .click, screen: .main, item: .track)
        updateDayCounterLabel()
    }
    
    var pinHandle: Binding<UUID>?
    var editHandle: Binding<String>?
    var deleteHandle: Binding<UUID>?
    
    private func pinTracker(with id: UUID) {
        self.pinHandle?(id)
        pinView.isHidden.toggle()
        isPinned.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        interactions
            .filter { $0 is UIContextMenuInteraction }
            .forEach{ self.removeInteraction($0) }
        deleteHandle = nil
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                let pinAction = UIAction(title: self.isPinned == true ? "Открепить" : "Закрепить") { [weak self] _ in
                    guard let self = self,
                          let id = trackerID else {
                        print("[\(#function)] - Трекер для закрепления не найден")
                        return
                    }
                    self.pinTracker(with: id)
                }
                let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self else { return }
                    analyticsService.report(event: .click, screen: .main, item: .edit)
                    self.editHandle?(daysString)
                }
                let deleteAction = UIAction(title: "Удалить", attributes: [.destructive]) { [weak self] _ in
                    guard let self = self,
                          let id = trackerID
                    else {
                        print("[\(#function)] - Трекер для удаления не найден")
                        return
                    }
                    analyticsService.report(event: .click, screen: .main, item: .delete)
                    self.deleteHandle?(id)
                }
                return UIMenu(children: [pinAction, editAction, deleteAction])
            }
        )
        return configuration
    }
}
