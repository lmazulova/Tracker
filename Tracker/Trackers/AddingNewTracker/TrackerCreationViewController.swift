
import UIKit

enum ControllersIdentifier: String {
    case habit = "Привычка"
    case irregularEvent = "Нерегулярное событие"
}

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Public Properties
    //т.к. тому кто реализует TrackerPresenterProtocol не нужно знать ничего о классе который управляет созданием ячейки, делегат можно сделать односторонним, и тогда приставка weak не нужна, т.к. нет условий для retain cycle
    var delegate: TrackerPresenterProtocol?
    var identifier: ControllersIdentifier
    
    // MARK: - Editing Bindings
    var trackerEdited: Binding<Tracker>?
    var trackerEditingCanceled: (() -> Void)?
    
    // MARK: - Private Properties
    private lazy var categoryViewController: CategoryViewController = {
        let controller = CategoryViewController()
        return controller
    }()
    
    private lazy var scheduleViewController = ScheduleViewController()
    
    private var scheduleSelected: Bool { return schedule != nil }
    //force unwrap здесь уместен, так как второе условие автоматически не будет проверяться если первое будет false
    private var trackerTitleFilled: Bool { return trackerTitle != nil && !trackerTitle!.isEmpty }
    private var categoryTitleFilled: Bool { return selectedCategory != nil && !selectedCategory!.categoryTitle.isEmpty }
    private var schedule: Set<WeekDay>?
    private var trackerTitle: String?
    private var selectedCategory: TrackerCategory?
    private let characterLimit = 38
    private var selectedEmojiPath: IndexPath?
    private var selectedColorPath: IndexPath?
    private let params = GeometricParamsForCollectionView(
        cellCount: 6,
        leftInset: 18,
        rightInset: 10,
        cellSpacing: 5
    )
    private var editableTracker: Tracker?
    private var numberOfDays: String?
    private var isEditableMode: Bool { editableTracker != nil}
    private var navigationBarTitle: String {
        if isEditableMode {
            return "Редактирование привычки"
        }
        else if identifier == .habit {
            return "Новая привычка"
        } else {
            return "Новое нерегулярное событие"
        }
    }
    init(identifier: ControllersIdentifier, editableTracker: Tracker? = nil, numberOfDays: String? = nil) {
        self.identifier = identifier
        self.editableTracker = editableTracker
        self.numberOfDays = numberOfDays
        
        super.init(nibName: nil, bundle: nil)
    }

    func setupCategory(_ category: TrackerCategory) {
        selectedCategory = category
        checkingButtonActivation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("[\(#function)] - init(coder:) has not been implemented")
    }
    
    // UI Elements
    private lazy var numberOfDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.text = numberOfDays
        label.isHidden = !isEditableMode
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "deleteButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(clearTextView), for: .touchUpInside)
        return button
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = "Введите название трекера"
        label.textColor = UIColor.customGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 2
        textView.textContainer.heightTracksTextView = true
        textView.textContainer.lineBreakMode = .byTruncatingHead
        textView.textColor = .customBlack
        let paragrafStyle = NSMutableParagraphStyle()
        paragrafStyle.lineSpacing = 0
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .paragraphStyle: paragrafStyle,
            .foregroundColor: UIColor.customBlack
        ]
        textView.typingAttributes = attributes
        
        return textView
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .customBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        view.addSubview(deleteButton)
        textView.addSubview(placeHolderLabel)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -41),
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 2 * (UIFont.systemFont(ofSize: 17).lineHeight + 8)),
            deleteButton.heightAnchor.constraint(equalToConstant: 17),
            deleteButton.widthAnchor.constraint(equalToConstant: 17),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            placeHolderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeHolderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let textFieldStack = UIStackView(arrangedSubviews: [textFieldView, warningLabel])
        textFieldStack.translatesAutoresizingMaskIntoConstraints = false
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 8
        
        return textFieldStack
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(characterLimit) символов"
        label.textColor = UIColor.customRed
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let navigationBar = UINavigationBar()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.separatorColor = .customGray
        tableView.register(ItemsCell.self, forCellReuseIdentifier: ItemsCell.identifier)
        return tableView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(HeaderForSection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customRed.cgColor
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor.customRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .clear
        
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.customGray
        button.setTitleColor(UIColor.customWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        //  скрытие клавиатуры
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        textView.delegate = self
        setupNavigationBar(with: navigationBarTitle)
        setupConstraints()
        setupActions()
        if isEditableMode,
           let editableTracker = editableTracker,
           let numberOfDays = numberOfDays {
            setupEditableProperties(tracker: editableTracker, numberOfDays: numberOfDays)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        collectionView.layoutIfNeeded()
        
        let height = collectionView.contentSize.height
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        contentView.layoutIfNeeded()
    }
    
    
    // MARK: - UI Configuration
    private func setupConstraints() {
        warningLabel.isHidden = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textFieldStack)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        contentView.addSubview(tableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(numberOfDaysLabel)
        
        if isEditableMode {
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                numberOfDaysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                numberOfDaysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                textFieldStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                textFieldStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                textFieldStack.topAnchor.constraint(equalTo: numberOfDaysLabel.bottomAnchor, constant: 40),
                
                textFieldView.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
                textFieldView.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
                textFieldView.heightAnchor.constraint(equalToConstant: 75),
                
                warningLabel.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
                warningLabel.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
                warningLabel.centerXAnchor.constraint(equalTo: textFieldStack.centerXAnchor),
                
                tableView.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 24),
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
                cancelButton.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 20),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                
                createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
                createButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -20),
                createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
                createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                createButton.heightAnchor.constraint(equalToConstant: 60),
                createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                textFieldStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                textFieldStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                textFieldStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                
                textFieldView.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
                textFieldView.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
                textFieldView.heightAnchor.constraint(equalToConstant: 75),
                
                warningLabel.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor),
                warningLabel.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor),
                warningLabel.centerXAnchor.constraint(equalTo: textFieldStack.centerXAnchor),
                
                tableView.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 24),
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
                cancelButton.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 20),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                
                createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
                createButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -20),
                createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
                createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                createButton.heightAnchor.constraint(equalToConstant: 60),
                createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
            ])
        }
        if identifier == ControllersIdentifier.habit {
            tableView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        }
        else {
            tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        }
    }
    
    private func setupEditableProperties(tracker: Tracker, numberOfDays: String) {
        setTitle(title: tracker.title)
        textView.text = tracker.title
        deleteButton.isHidden = false
        placeHolderLabel.isHidden = true
        let category = TrackerCategory(
            categoryTitle: TrackerStore.shared.findCategoryTitle(by: tracker.originalCategoryID ?? tracker.id),
            id: tracker.originalCategoryID ?? tracker.id
        )
        
        setupCategory(category)
        if let schedule = tracker.schedule {
            setSchedule(for: schedule)
        }
        selectedEmojiPath = IndexPath(row: TrackerAttributes.emojis.firstIndex(where: { $0 == tracker.emoji}) ?? 0, section: 0)
        selectedColorPath = IndexPath(row: TrackerAttributes.colors.firstIndex(where: { $0 == tracker.color}) ?? 0, section: 1)
        
        checkingButtonActivation()

    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar(with title: String) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        let title = UINavigationItem(title: title)
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.customBlack
        ]
        
        navigationBar.barTintColor = .customWhite
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Private Methods
    private func checkingButtonActivation() {
        if identifier == ControllersIdentifier.irregularEvent && trackerTitleFilled && categoryTitleFilled && selectedColorPath != nil && selectedEmojiPath != nil {
            createButton.backgroundColor = UIColor.customBlack
            createButton.isEnabled = true
        }
        else if trackerTitleFilled && categoryTitleFilled && scheduleSelected && selectedColorPath != nil && selectedEmojiPath != nil {
            createButton.backgroundColor = UIColor.customBlack
            createButton.isEnabled = true
        }
        else {
            createButton.backgroundColor = UIColor.customGray
            createButton.isEnabled = false
        }
    }
    
    private func setSchedule(for weekDays: Set<WeekDay>) {
        schedule = weekDays
        checkingButtonActivation()
    }
    
    private func setTitle(title: String) {
        trackerTitle = title
        checkingButtonActivation()
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        if isEditableMode {
            self.trackerEditingCanceled?()
        }
        else {
            delegate?.cancelingTrackerCreation()
        }
    }
    
    @objc private func createButtonTapped() {
        if isEditableMode {
            guard let editableTracker = editableTracker,
                  let selectedCategory = selectedCategory
            else {
                print("[\(#function)] - Не найден трекер для редактирования.")
                return
            }
            var category = selectedCategory
            if editableTracker.category.categoryTitle == PinnedCategory.title {
                category = editableTracker.category
            }
            let editedTracker = Tracker(
                id: editableTracker.id,
                title: trackerTitle ?? "",
                color: TrackerAttributes.colors[selectedColorPath?.row ?? 0],
                emoji: TrackerAttributes.emojis[selectedEmojiPath?.row ?? 0],
                schedule: schedule,
                category: category,
                isPinned: editableTracker.isPinned,
                originalCategory: selectedCategory.id
            )
            self.trackerEdited?(editedTracker)
        }
        else {
            let tracker = Tracker(
                title: trackerTitle ?? "",
                color: TrackerAttributes.colors[selectedColorPath?.row ?? 0],
                emoji: TrackerAttributes.emojis[selectedEmojiPath?.row ?? 0],
                schedule: schedule,
                category: selectedCategory ?? TrackerCategory(categoryTitle: "", id: UUID()),
                isPinned: false
            )
            delegate?.addTracker(tracker)
            delegate?.cancelingTrackerCreation()
        }
    }
    
    @objc private func clearTextView() {
        textView.text = ""
        warningLabel.isHidden = true
        deleteButton.isHidden = true
        placeHolderLabel.isHidden = false
        checkingButtonActivation()
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}


// MARK: - UITableViewDelegate
extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            categoryViewController.setupCategory = { [weak self] category in
                guard let self = self else { return }
                setupCategory(category)
                self.tableView.reloadData()
            }
            present(categoryViewController, animated: true)
        case 1:
            scheduleViewController.addSchedule = { [weak self] selectedWeekDays in
                guard let self = self else { return }
                setSchedule(for: selectedWeekDays)
                self.tableView.reloadData()
            }
            present(scheduleViewController, animated: true)
        default:
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension TrackerCreationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if identifier == ControllersIdentifier.habit { return 2}
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCell.identifier) as? ItemsCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.setupCellTitle(title: "Категория")
            cell.setupSelectedCategory(title: selectedCategory?.categoryTitle ?? "")
            if identifier == ControllersIdentifier.irregularEvent {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            }
            
            return cell
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        cell.setupCellTitle(title: "Расписание")
        cell.setupSelectedSchedule(schedule: schedule)
        return cell
    }
}

// MARK: - UITextViewDelegate
extension TrackerCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        deleteButton.isHidden = textView.text.isEmpty
        placeHolderLabel.isHidden = !textView.text.isEmpty
        if textView.text.isEmpty {
            warningLabel.isHidden = true
            checkingButtonActivation()
            return
        }
        
        if textView.text.count > characterLimit {
            warningLabel.isHidden = false
            checkingButtonActivation()
        }
        
        else {
            warningLabel.isHidden = true
            setTitle(title: textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let maxHeight = 2 * (UIFont.systemFont(ofSize: 17).lineHeight + 8)
            if textView.contentSize.height >= maxHeight {
                return false
            }
        }
        return true
    }
}

extension TrackerCreationViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? TrackerAttributes.emojis.count : TrackerAttributes.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(with: TrackerAttributes.emojis[indexPath.row])
            if indexPath == selectedEmojiPath {
                cell.cellDidSelect()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(with: TrackerAttributes.colors[indexPath.row])
            if indexPath == selectedColorPath {
                cell.cellDidSelect()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderForSection else { return UICollectionReusableView()}
        view.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return view
    }
}

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
            if let selectedEmojiPath = selectedEmojiPath {
                guard let previousSelectedCell = collectionView.cellForItem(at: selectedEmojiPath) as? EmojiCell else { return }
                previousSelectedCell.resetSelectedCell()
            }
            cell.cellDidSelect()
            selectedEmojiPath = indexPath
        case 1:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
            if let selectedColorPath = selectedColorPath {
                guard let previousSelectedCell = collectionView.cellForItem(at: selectedColorPath) as? ColorCell else { return }
                previousSelectedCell.resetSelectedCell()
            }
            cell.cellDidSelect()
            selectedColorPath = indexPath
        default:
            return
        }
        checkingButtonActivation()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width - params.paddingWidth)/CGFloat(params.cellCount)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
}
