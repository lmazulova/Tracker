import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "trackerCell"
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.addSubview()
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
    
    private let emoji: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 68
        view.backgroundColor = UIColor.customWhite
        view.alpha = 30
        let emoji = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emoji)
        
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
}
