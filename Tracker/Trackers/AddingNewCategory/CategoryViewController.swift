import UIKit

final class CategoryViewController: UIViewController {
    
    func addNewCategory(with title: String) {
        try? categoryDataProvider.addRecord(with: title)
    }
    
    var setupCategoryTitle: ((String) -> Void)?

    private var categoryTitle: String = ""
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var categoryDataProvider: CategoryDataProviderProtocol = {
        let store = TrackerCategoryStore()
        store.delegate = self
        return store
    }()
    
    func lastSelectedTitle(_ title: String) {
        categoryTitle = title
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .customBackground
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
        
        return tableView
    }()
    
    private let navigationBar = UINavigationBar()
    
    private lazy var stubContainer: UIView = {
        let stubContainer = UIView()
        stubContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stubContainer.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: stubContainer.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: stubContainer.centerYAnchor)
        ])
        
        return stubContainer
    }()
    
    private lazy var stubStackView: UIStackView = {
        let stubImageView = UIImageView(image: UIImage(named: "trackerStub"))
        let stubLabel = UILabel()
        let text = "Привычки и события можно\nобъединить по смыслу"
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let lineHeight: CGFloat = 18
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.customBlack,
            .baselineOffset: (lineHeight - font.lineHeight)
        ]
        
        stubLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        stubLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .customWhite
        button.backgroundColor = .customBlack
        
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        setupNavigationBar()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    private func setupConstraints() {
        view.addSubview(addCategoryButton)
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(stubContainer)
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            stubContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubContainer.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            stubContainer.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor)
        ])
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let title = UINavigationItem(title: "Категория")
        navigationBar.setItems([title], animated: false)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.customBlack
        ]
        navigationBar.barTintColor = .customWhite
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
    
    private func updateUI() {
        let numberOfRows = categoryDataProvider.numberOfRows
        let state = numberOfRows > 0
        
        stubContainer.isHidden = state
        tableView.isHidden = !state
        
        if state {
            let tableHeight = min(tableView.rowHeight*CGFloat(numberOfRows), floor( stubContainer.frame.height/tableView.rowHeight)*tableView.rowHeight)
            tableViewHeightConstraint?.constant = tableHeight
        }
        
    }
    
    @objc private func addCategory() {
        // newCategoryController высвобождается из памяте при каждом вызове dismiss внутри себя, поэтому уместно каждый раз создавать его заново
        let newCategoryController = NewCategoryViewController()
        newCategoryController.delegate = self
        present(newCategoryController, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = try? categoryDataProvider.title(at: indexPath) else {
            return
        }
        categoryTitle = title
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        self.setupCategoryTitle?(categoryTitle)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryDataProvider.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell
        else {
            return UITableViewCell()
        }
        
        do {
            let title = try categoryDataProvider.title(at: indexPath)
            if categoryTitle == title {
                cell.setupCheckmark()
            }
            cell.setupCellTitle(title)
            
            return cell
        }
        catch CoreDataErrors.categoryConversionError {
            print("[\(#function)] - Ошибка записи: CoreDataErrors.categoryConversionError.")
        }
        catch {
            print("[\(#function)] - Непредвиденная ошибка: \(error.localizedDescription).")
        }
        
        return UITableViewCell()
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        tableView.performBatchUpdates{
            tableView.insertRows(at: Array(update.insertedIndexes), with: .automatic)
            tableView.deleteRows(at: Array(update.deletedIndexes), with: .automatic)
        }
        updateUI()
    }
}
