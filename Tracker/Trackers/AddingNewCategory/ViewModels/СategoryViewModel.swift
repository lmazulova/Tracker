import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoryViewModelProtocol: AnyObject {
    func numberOfRows() -> Int
    func addRecord(with title: String)
    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel
    func selectCategory(at indexPath: IndexPath)
    
    var selectedCategoryTitle: String? { get }
    var visibleDataChanged: Binding<TrackerStoreUpdate>? { get set }
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    var visibleDataChanged: Binding<TrackerStoreUpdate>?
    
    var selectedCategoryTitle: String? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        return title(at: selectedIndexPath)
    }
    
    private lazy var categoryDataProvider: CategoryDataProviderProtocol = {
        let store = TrackerCategoryStore.shared
        store.delegate = self
        return store
    }()
    
    private var selectedIndexPath: IndexPath?
    
    func selectCategory(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func addRecord(with title: String) {
        do {
            try categoryDataProvider.addRecord(with: title)
        }
        catch {
            print("[\(#function)] - Ошибка добавления новой записи.")
        }
    }
    
    func title(at indexPath: IndexPath) -> String {
        do {
            let trackerCategory = try categoryDataProvider.object(at: indexPath)
            return trackerCategory.categoryTitle
        }
        catch CoreDataErrors.sectionOutOfRange(let index) {
            print("[\(#function)] - Объект с индексом - \(index) не найден.")
        }
        catch CoreDataErrors.categoryConversionError {
            print("[\(#function)] - Ошибка преобразования данных: CoreDataErrors.categoryConversionError")
        }
        catch {
            print("[\(#function)] - Непредвиденная ошибка: \(error.localizedDescription)")
        }
        
        return ""
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        return selectedIndexPath == indexPath
    }
    
    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel {
        let title = title(at: indexPath)
        let isSelected = isSelected(at: indexPath)
        let categoryCellViewModel = CategoryCellViewModel(title: title, isSelected: isSelected)
        
        return categoryCellViewModel
    }
    
    func numberOfRows() -> Int {
        categoryDataProvider.numberOfRows
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        guard let visibleDataChanged = visibleDataChanged else {
            print("[\(#function)] - Ошибка: binding is nil")
            return
        }
        DispatchQueue.main.async {
            visibleDataChanged(update)
        }
    }
}
