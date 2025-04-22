import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "color cell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let view: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.customWhite.cgColor
        
        return view
    }()
    
    func cellDidSelect() {
        if let color = colorView.backgroundColor {
            view.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }
    
    func resetSelectedCell() {
        view.layer.borderColor = UIColor.customWhite.cgColor
    }
    
    func configureCell(with color: UIColor) {
        colorView.backgroundColor = color
        contentView.addSubview(view)
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: contentView.frame.width - 12),
            colorView.heightAnchor.constraint(equalToConstant: contentView.frame.width - 12)
        ])
    }
}
