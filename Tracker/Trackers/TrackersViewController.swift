import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    
    private let params = GeometricParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
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
        setupNavigationController()
        if categories.isEmpty {
            setupStub()
        }
        else {
            setupCollectionView()
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.isEmpty ? 0 : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.isEmpty ? 0 : categories[section].trackersInCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = categories[indexPath.section].trackersInCategory[indexPath.row]
        cell.configureCell(for: tracker)
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        return CGSize(width: availableWidth/CGFloat(params.cellCount), height: availableWidth/CGFloat(params.cellCount)*0.89)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension TrackersViewController: TrackerPresenterProtocol {
    func cancelingTrackerCreation() {
        self.dismiss(animated: true)
    }
    
    func addTracker(for category: TrackerCategory) {
        var newCategories = categories
        if let index = newCategories.firstIndex(where: {$0.categoryTitle == category.categoryTitle}) {
            let updatedCategory = TrackerCategory(
                categoryTitle: category.categoryTitle,
                trackersInCategory: newCategories[index].trackersInCategory + category.trackersInCategory
            )
            newCategories[index] = updatedCategory
        }
        else {
            newCategories.append(category)
        }
        categories = newCategories
        
        collectionView.performBatchUpdates({
            if let index = newCategories.firstIndex(where: {$0.categoryTitle == category.categoryTitle}) {
                let count = categories.count - 1
                
                if index != count {
                    collectionView.reloadSections(IndexSet(integer: index))
                }
                
                else if index == 0 {
                    collectionView.reloadSections(IndexSet(integer: index))
                    setupCollectionView()
                }
                
                else {
                    collectionView.insertSections(IndexSet(integer: index))
                }
            }
        })
    }
}
