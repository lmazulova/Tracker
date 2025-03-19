import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.customWhite
        setupUI()
    }
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] = []
    var categoriesArrayForUsage: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    // MARK: - Private Properties
    
    private let params = GeometricParamsForCollectionView(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
    //UIElements
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plusButton"), for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.tintColor = .customBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var selectedDateButton: UIButton = {
        let dateButton = UIButton(type: .custom)
        dateButton.layer.cornerRadius = 8
        dateButton.backgroundColor = UIColor(cgColor: CGColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1))
        dateButton.setTitle(formattedDate(currentDate), for: .normal)
        dateButton.setTitleColor(UIColor(cgColor: CGColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)), for: .normal)
        dateButton.titleLabel?.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.addTarget(self, action: #selector(setupDatePicker), for: .touchUpInside)
        
        return dateButton
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.setValue("Отменить", forKey: "cancelButtonText")
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.clearButtonMode = .never
        }
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(HeaderForSection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    private let stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "trackerStub"))
        let stubLabel = UILabel()
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.textColor = UIColor.customBlack
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let searchStubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "noResultStub"))
        let stubLabel = UILabel()
        stubLabel.text = "Ничего не найдено"
        stubLabel.textColor = UIColor.customBlack
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var datePickerContainer: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 13
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 30
        containerView.layer.masksToBounds = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor),
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor)
        ])
        
        return containerView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        else {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.layer.cornerRadius = 13
        datePicker.layer.masksToBounds = true
        datePicker.backgroundColor = .customWhite
        datePicker.datePickerMode = .date
        datePicker.date = currentDate
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    // MARK: - UI Configuration
    
    private func setupUI() {
        setupHeader()
        view.addSubview(stubStackView)
        view.addSubview(collectionView)
        view.addSubview(searchStubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            searchStubStackView.centerXAnchor.constraint(equalTo: stubStackView.centerXAnchor),
            searchStubStackView.centerYAnchor.constraint(equalTo: stubStackView.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        updateUI()
    }
    
    private func updateUI() {
        let state = categoriesArrayForUsage.isEmpty
        
        if searchBar.showsCancelButton == true {
            searchStubStackView.isHidden = !state
            stubStackView.isHidden = true
            collectionView.isHidden = state
            collectionView.reloadData()
        }
        else {
            stubStackView.isHidden = !state
            searchStubStackView.isHidden = true
            collectionView.isHidden = state
            collectionView.reloadData()
        }
    }
    
    private func setupHeader() {
        view.addSubview(plusButton)
        view.addSubview(selectedDateButton)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            selectedDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            selectedDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedDateButton.heightAnchor.constraint(equalToConstant: 34),
            selectedDateButton.widthAnchor.constraint(equalToConstant: 77),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 1),
            titleLabel.heightAnchor.constraint(equalToConstant: 36),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        let trackerSelectionController = TrackerSelectionViewController()
        present(trackerSelectionController, animated: true)
    }
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        filterByDates(by: currentDate)
        selectedDateButton.setTitle(formattedDate(currentDate), for: .normal)
        datePickerContainer.isHidden.toggle()
        updateUI()
    }
    
    @objc private func setupDatePicker() {
        if view.subviews.contains(datePickerContainer) {
            datePickerContainer.isHidden.toggle()
        }
        else {
            view.addSubview(datePickerContainer)
            view.bringSubviewToFront(datePickerContainer)
            NSLayoutConstraint.activate([
                datePickerContainer.topAnchor.constraint(equalTo: searchBar.topAnchor),
                datePickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                datePickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                datePickerContainer.heightAnchor.constraint(equalTo: datePickerContainer.widthAnchor, multiplier: 0.95)
            ])
            datePicker.isHidden = false
        }
    }
    
    // MARK: - Private Methods
    
    private func countRecordsByID(records: Set<TrackerRecord>, by id: UUID) -> Int {
        var counts: [UUID: Int] = [:]
        
        for record in records {
            counts[record.id, default: 0] += 1
        }
        return counts[id] ?? 0
    }
    
    private func filterByDates(by selectedDate: Date) {
        let weekDays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let selectedWeekDay = weekDays[Calendar.current.component(.weekday, from: selectedDate) - 1]
        
        categoriesArrayForUsage = categories.compactMap { category in
            let filteredTrackers = category.trackersInCategory.filter { $0.schedule?.days.contains(selectedWeekDay) == true || ($0.schedule == nil && selectedDate == Calendar.current.startOfDay(for: Date()))}
            return filteredTrackers.isEmpty ? nil : TrackerCategory(categoryTitle: category.categoryTitle, trackersInCategory: filteredTrackers)
        }
    }
    
    private func filterByTitles(by text: String) {
        categoriesArrayForUsage = categories.compactMap {category in
            let filteredTrackers = category.trackersInCategory.filter { $0.title.lowercased().contains(text.lowercased()) }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(categoryTitle: category.categoryTitle, trackersInCategory: filteredTrackers)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoriesArrayForUsage.isEmpty ? 0 : categoriesArrayForUsage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArrayForUsage.isEmpty ? 0 : categoriesArrayForUsage[section].trackersInCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = categoriesArrayForUsage[indexPath.section].trackersInCategory[indexPath.row]
        let trackerIsCompleted: Bool
        if currentDate <= Calendar.current.startOfDay(for: Date()) {
            trackerIsCompleted = completedTrackers.contains(TrackerRecord(id: tracker.id, date: currentDate))
        }
        else {
            trackerIsCompleted = false
        }
        cell.configureCell(for: tracker, with: trackerIsCompleted, counterValue: countRecordsByID(records: completedTrackers, by: tracker.id), currentDate: currentDate)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderForSection else { return UICollectionReusableView()}
        view.titleLabel.text = categoriesArrayForUsage[indexPath.section].categoryTitle
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        return CGSize(width: availableWidth/CGFloat(params.cellCount), height: availableWidth/CGFloat(params.cellCount)*0.89)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 0, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
}

// MARK: - TrackerPresenterProtocol
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
        } else {
            newCategories.append(category)
        }
        categories = newCategories
        
        filterByDates(by: datePicker.date)
        
        collectionView.performBatchUpdates({
            if categoriesArrayForUsage.isEmpty {
                updateUI()
            }
            else if let index = categoriesArrayForUsage.firstIndex(where: {$0.categoryTitle == category.categoryTitle}) {
                if collectionView.numberOfSections > index {
                    collectionView.reloadSections(IndexSet(integer: index))
                }
                else {
                    collectionView.insertSections(IndexSet(integer: index))
                }
            }
        })
        collectionView.isHidden = categoriesArrayForUsage.isEmpty
        stubStackView.isHidden = !categoriesArrayForUsage.isEmpty
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func updateCompletedTrackers(for id: UUID) {
        let trackerRecord = TrackerRecord(id: id, date: currentDate)
        if completedTrackers.contains(trackerRecord) {
            completedTrackers.remove(trackerRecord)
        } else {
            completedTrackers.insert(trackerRecord)
        }
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        animateCancelButton(visible: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        animateCancelButton(visible: false)
        filterByDates(by: currentDate)
        updateUI()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterByTitles(by: searchText)
        updateUI()
    }
    private func animateCancelButton(visible: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.searchBar.showsCancelButton = visible
            self.searchBar.layoutIfNeeded()
        })
    }
}
