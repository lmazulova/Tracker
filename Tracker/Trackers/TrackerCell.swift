import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "trackerCell"
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellConstraints()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Properties
  
    private let card: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .customWhite
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
    
    private let QuantityManagementView: UIView = {
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
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    private func setupCellConstraints() {
        contentView.addSubview(card)
        contentView.addSubview(QuantityManagementView)
        QuantityManagementView.addSubview(dayCounterLabel)
        QuantityManagementView.addSubview(plusButton)
        card.addSubview(cardText)
        card.addSubview(emojiView)
        card.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.61),
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
            QuantityManagementView.topAnchor.constraint(equalTo: card.bottomAnchor),
            QuantityManagementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            QuantityManagementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            QuantityManagementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dayCounterLabel.leadingAnchor.constraint(equalTo: QuantityManagementView.leadingAnchor, constant: 12),
            dayCounterLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: QuantityManagementView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: QuantityManagementView.topAnchor, constant: 8),
            plusButton.bottomAnchor.constraint(equalTo: QuantityManagementView.bottomAnchor, constant: -16),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
        ])
    }
  
    func configureCell(for tracker: Tracker) {
        emojiLabel.text = tracker.emoji
        cardText.text = tracker.title
        card.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        dayCounterLabel.text = "0 дней"
    }
    
    @objc
    func plusButtonTapped() {
        
    }
}
