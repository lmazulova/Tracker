import UIKit

final class TrackersViewController: UIViewController {
    
    private let stubView: UIImageView = {
        let stub = UIImageView(image: UIImage(named: "trackerStub"))
        stub.translatesAutoresizingMaskIntoConstraints = false
        return stub
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor.customBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupStub() {
        view.addSubview(stubView)
        view.addSubview(stubLabel)
        
        NSLayoutConstraint.activate([
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            /* 0.52 это результат деления расстояния от изображения до верхней части экрана из макета figma на длину всего экрана, таким образом на разных устройствах пропорции будут сохранены */
            stubView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height*0.52),
            stubView.widthAnchor.constraint(equalToConstant: 80),
            stubView.heightAnchor.constraint(equalToConstant: 80),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubView.bottomAnchor, constant: 8)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customWhite
        setupNavigationController()
        if true {
            setupStub()
        }
    }
    
    private func setupNavigationController() {
    
        let button = UIBarButtonItem(
            image: UIImage(named: "plusButton"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        button.tintColor = .customBlack
        self.navigationItem.leftBarButtonItem = button
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        let dateItem = UIBarButtonItem(customView: datePicker)
        self.navigationItem.rightBarButtonItem = dateItem
    
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.customBlack
        ]
        self.navigationItem.title = "Трекеры"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        self.navigationItem.searchController = searchController
    }
    
    @objc func plusButtonTapped() {
        
    }
}
