import UIKit

final class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        TrackerRecordStore.shared.delegate = self
        setupUI()
    }
    
    private var numberOfCompletedTrackers: Int {
        return TrackerRecordStore.shared.numberOfCompletedTrackers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statisticView.addGradientBorder(colors: [.colorSelection1, .colorSelection9, .colorSelection3], width: 1, radius: 16)
    }
    
    private struct StatisticsView {
        let number: Int = 0
        let title: String = ""
    }
    
    func updateUI() {
        stubStackView.isHidden = numberOfCompletedTrackers > 0
        statisticView.isHidden = numberOfCompletedTrackers == 0
        numberLabel.text = String(numberOfCompletedTrackers)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(container)
        view.addSubview(stubStackView)
        view.addSubview(statisticView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stubStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            statisticView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func updateLabel() {
        
    }
    
    private let container: UIView = {
        let container = UIView()
        container.isHidden = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statisticsTitle", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "statisticsStub"))
        stubImageView.backgroundColor = .customWhite
        let stubLabel = UILabel()
        stubLabel.text = NSLocalizedString("statistics_screen_stub", comment: "")
        stubLabel.textColor = UIColor.customBlack
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = (numberOfCompletedTrackers > 0)
        
        return stackView
    }()
    
    private lazy var numberLabel: UILabel = {
        let numberLabel = UILabel()
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .customBlack
        numberLabel.text = String(numberOfCompletedTrackers)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return numberLabel
    }()
    
    private lazy var categoryTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        title.text = NSLocalizedString("trackersCompleted", comment: "")
        title.textColor = .customBlack
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
     
    private lazy var statisticView: UIView = {
        let statisticView = UIView()
        
        statisticView.addSubview(numberLabel)
        statisticView.addSubview(categoryTitle)
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12),
            categoryTitle.bottomAnchor.constraint(equalTo: statisticView.bottomAnchor, constant: -12),
            categoryTitle.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12)
        ])
        
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        statisticView.isHidden = (numberOfCompletedTrackers == 0)
        return statisticView
    }()
}
        
extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat, radius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: width/2, dy: width/2),
            cornerRadius: radius
        ).cgPath
        shapeLayer.lineWidth = width
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineCap = .round
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
}
