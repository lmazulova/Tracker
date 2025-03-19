import UIKit

final class EmojiCell: UICollectionViewCell {
    static let identifier = "emoji cell"
    private let emojiLabel: UILabel = {
        let emoji = UILabel()
        emoji.font = UIFont.systemFont(ofSize: 32)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        return emoji
    }()
    
    private let view: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func cellDidSelect() {
        view.backgroundColor = .customLightGray
    }
    
    func resetSelectedCell() {
        view.backgroundColor = .customWhite
    }
    
    func configureCell(with emoji: String) {
        emojiLabel.text = emoji
        contentView.addSubview(view)
        view.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
