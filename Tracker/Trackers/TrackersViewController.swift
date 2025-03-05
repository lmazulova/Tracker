import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        return collectionView
    }()
    
    private let stubImageView: UIImageView = {
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customWhite
        configureUI()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setupCollectionView()
        setupNavigationController()
        if categories.isEmpty {
            setupStub()
        }
    }
    
    private func setupStub() {
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubLabel.heightAnchor.constraint(equalToConstant: 18),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.customBlack
        ]
        navigationItem.title = "Трекеры"
        
        setupNavigationBarItems()
    }
    
    private func setupNavigationBarItems() {
        let button = UIBarButtonItem(
            image: UIImage(named: "plusButton"),
            style: .plain,
            target: self,
            action: #selector(plusButtonTapped)
        )
        button.tintColor = .customBlack
        navigationItem.leftBarButtonItem = button
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        let dateItem = UIBarButtonItem(customView: datePicker)
        self.navigationItem.rightBarButtonItem = dateItem
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        self.navigationItem.searchController = searchController
    }
    
    // MARK: - Actions
    @objc func plusButtonTapped() {
        let trackerSelectionController = TrackerSelectionViewController()
        present(trackerSelectionController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}
