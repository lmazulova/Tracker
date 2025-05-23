import UIKit


final class TrackersViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(FilterModes.all.rawValue, forKey: "filter")
        view.backgroundColor = .customWhite
        analyticsService.report(event: Event.open, screen: Screen.main)
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, screen: .main)
    }
    
    // MARK: - Public Properties
    
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    // MARK: - Private Properties
    private var filterViewController: FilterViewController?
    private let analyticsService = AnalyticsService()
    
    private let params = GeometricParamsForCollectionView(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9
    )
    
    private lazy var trackerDataProvider: TrackerDataProviderProtocol = {
        let trackerStore = TrackerStore.shared
        trackerStore.delegate = self
        return trackerStore
    }()
    
    //UIElements
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plusButton"), for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.tintColor = .customBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.backgroundColor = .customBlue
        let buttonText = NSLocalizedString("filter", comment: "text for filter button")
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(filterButtonTappet), for: .touchUpInside)
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
        label.text = NSLocalizedString("trackersTitle", comment: "title for trackers screen")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        let placeholderText = NSLocalizedString("search", comment: "placeholder text for UISearch")
        searchBar.placeholder = placeholderText
        let cancelText = NSLocalizedString("cancel", comment: "cancel search")
        searchBar.setValue(cancelText, forKey: "cancelButtonText")
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
        collectionView.backgroundColor = .customWhite
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(HeaderForSection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    private let stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "trackerStub"))
        stubImageView.backgroundColor = .customWhite
        let stubLabel = UILabel()
        let stubText = NSLocalizedString("trackers_screen_stub", comment: "stub if there are no trackers on the screen")
        stubLabel.text = stubText
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
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            searchStubStackView.centerXAnchor.constraint(equalTo: stubStackView.centerXAnchor),
            searchStubStackView.centerYAnchor.constraint(equalTo: stubStackView.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        trackerDataProvider.filterByDate(currentDate)
    }
    
    private func updateUI() {
        let state = trackerDataProvider.numberOfSections > 0
        if searchBar.showsCancelButton == true {
            searchStubStackView.isHidden = state
            stubStackView.isHidden = true
            collectionView.isHidden = !state
            filterButton.isHidden = true
        }
        else if UserDefaults.standard.string(forKey: "filter") == FilterModes.all.rawValue {
            filterButton.isHidden = !state
            stubStackView.isHidden = state
            searchStubStackView.isHidden = true
            collectionView.isHidden = !state
        }
        else {
            searchStubStackView.isHidden = state
            stubStackView.isHidden = true
            collectionView.isHidden = !state
            filterButton.isHidden = false
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
        analyticsService.report(event: .click, screen: .main, item: .add_track)
        present(trackerSelectionController, animated: true)
    }
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        trackerDataProvider.filterByDate(currentDate)
        selectedDateButton.setTitle(formattedDate(currentDate), for: .normal)
        datePickerContainer.isHidden.toggle()
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
    
    private func bind() {
        guard let filterViewController = filterViewController else { return }
      
        filterViewController.filterSelected = { [weak self] in
            guard let self = self else { return }
            self.trackerDataProvider.filterByDate(currentDate)
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
    @objc private func filterButtonTappet() {
        guard let filterViewController = filterViewController else {
            filterViewController = FilterViewController()
            if let filterViewController = filterViewController {
                self.bind()
                present(filterViewController, animated: true)
            }
            return
        }
        analyticsService.report(event: .click, screen: .main, item: .filter)
        present(filterViewController, animated: true)
    }
    
    // MARK: - Context Menu Actions
    private func showDeleteAlert(for trackerId: UUID) {
        let deleteText = NSLocalizedString("delete", comment: "delete tracker")
        let alertMessage = NSLocalizedString("deleteMessage", comment: "warning message about tracker deleting")
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: deleteText, style: .destructive, handler: { [weak self] _ in
            self?.trackerDataProvider.deleteTracker(with: trackerId)
        })
        )
        let cancelText = NSLocalizedString("cancel", comment: "cancel tracker deletion")
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

    private func editTracker(tracker: Tracker, numberOfDays: String) {
        let identifier: ControllersIdentifier = tracker.schedule == nil ? .irregularEvent : .habit
        let editableTrackerController = TrackerCreationViewController(identifier: identifier, editableTracker: tracker, numberOfDays: numberOfDays)
        //Bindings
        editableTrackerController.trackerEditingCanceled = { [weak self] in
            self?.dismiss(animated: true)
        }
        editableTrackerController.trackerEdited = { [weak self] tracker in
                self?.trackerDataProvider.editRecord(tracker) { success in
                    DispatchQueue.main.async {
                        if success {
                            self?.collectionView.reloadData()
                        }
                        self?.dismiss(animated: true)
                    }
                }
            }
        present(editableTrackerController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerDataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerDataProvider.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell
        else {
            return UICollectionViewCell()
        }
        
        do {
            let tracker = try trackerDataProvider.object(at: indexPath)
            let trackerIsCompleted: Bool
            if currentDate <= Calendar.current.startOfDay(for: Date()) {
                trackerIsCompleted = TrackerRecordStore.shared.trackerIsCompleted(TrackerRecord(id: tracker.id, date: currentDate))
            }
            else {
                trackerIsCompleted = false
            }
            cell.configureCell(for: tracker, with: trackerIsCompleted, counterValue: TrackerRecordStore.shared.amountOfRecords(for: tracker.id), currentDate: currentDate)
            //Bindings
            cell.deleteHandle = { [weak self] id in
                guard let self = self else { return }
                self.showDeleteAlert(for: id)
            }
            cell.pinHandle = { [weak self] id in
                guard let self = self else { return }
                trackerDataProvider.pinTracker(with: id)
            }
            cell.editHandle = { [weak self] numberOfDays in
                guard let self = self else { return }
                self.editTracker(tracker: tracker, numberOfDays: numberOfDays)
            }
            
            cell.delegate = self
            
            return cell
            
        } catch CoreDataErrors.noSectionsAvailable {
            print("[\(#function)] - В коллекции отсутсвуют секции.")
        } catch CoreDataErrors.sectionOutOfRange(let index) {
            print("[\(#function)] - Индекс секции \(index) выходит за пределы допустимых значений.")
        } catch CoreDataErrors.rowOutOfRange(let index) {
            print("[\(#function)] - Индекс элемента \(index) выходит за пределы допустимых значений.")
        } catch CoreDataErrors.trackerConversionError {
            print("[\(#function)] - Ошибка преобразования в структуру.")
        } catch {
            print("[\(#function)] - Непредвиденная ошибка: \(error).")
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderForSection else { return UICollectionReusableView()}
        view.titleLabel.text = trackerDataProvider.titleForSection(indexPath.section)
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
        return UIEdgeInsets(top: 16, left: params.leftInset, bottom: 12, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
}

// MARK: - TrackerPresenterProtocol
extension TrackersViewController: TrackerPresenterProtocol {
    func cancelingTrackerCreation() {
        self.dismiss(animated: true)
    }
    
    func addTracker(_ tracker: Tracker) {
        do {
            try self.trackerDataProvider.addRecord(tracker)
        }
        catch {
            print("[\(#function)] - Ошибка добавления трекера: \(error.localizedDescription)")
        }
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func updateCompletedTrackers(for id: UUID) {
        let newRecord = TrackerRecord(id: id, date: currentDate)
        
        do {
            try TrackerRecordStore.shared.changeState(for: newRecord)
        }
        catch {
            print("[\(#function)] - Ошибка записи: \(error.localizedDescription)")
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
        trackerDataProvider.filterByDate(currentDate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        trackerDataProvider.filterByTitle(searchText)
    }
    private func animateCancelButton(visible: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.searchBar.showsCancelButton = visible
            self.searchBar.layoutIfNeeded()
        })
    }
}

// MARK: - DataProviderDelegate
extension TrackersViewController: DataProviderDelegate {
    func collectionFullReload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateUI()
        }
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates{
            collectionView.insertSections(update.insertedSections)
            collectionView.deleteSections(update.deletedSections)
            collectionView.insertItems(at: Array(update.insertedIndexes))
            collectionView.deleteItems(at: Array(update.deletedIndexes))
        }
        updateUI()
    }
}
