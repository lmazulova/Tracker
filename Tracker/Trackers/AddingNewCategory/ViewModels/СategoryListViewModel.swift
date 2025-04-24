import Foundation

typealias Index = Int
typealias Binding<T> = (T) -> Void

protocol CategoryViewModelProtocol: AnyObject {
    func numberOfCategories() -> Int
    func addRecord(category: TrackerCategory)
    func category(at index: Index) -> CategoryViewModel
    func selectCategory(at index: Index)
    
    var selectedCategory: TrackerCategory? { get }
    var visibleDataChanged: Binding<TrackerStoreUpdate>? { get set }
}

final class CategoryListViewModel: CategoryViewModelProtocol {
    
    var visibleDataChanged: Binding<TrackerStoreUpdate>?
    
    var selectedCategory: TrackerCategory? {
        guard let selectedIndexPath = selectedIndex else { return nil }
        return trackerCategory(at: selectedIndexPath)
    }
    
    private lazy var categoryDataProvider: CategoryDataProviderProtocol = {
        let store = TrackerCategoryStore.shared
        store.delegate = self
        return store
    }()
    
    private var selectedIndex: Index?
    
    func selectCategory(at index: Index) {
        selectedIndex = index
    }
    
    func addRecord(category: TrackerCategory) {
        do {
            try categoryDataProvider.addRecord(category: category)
        }
        catch {
            print("[\(#function)] - Ошибка добавления новой записи.")
        }
    }
    
    func trackerCategory(at index: Index) -> TrackerCategory {
        do {
            let trackerCategory = try categoryDataProvider.object(at: index)
            return trackerCategory
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
        return TrackerCategory(categoryTitle: "", id: UUID())
    }
    
    func isSelected(at index: Index) -> Bool {
        return selectedIndex == index
    }
    
    func category(at index: Index) -> CategoryViewModel {
        let category = trackerCategory(at: index)
        let isSelected = isSelected(at: index)
        let categoryCellViewModel = CategoryViewModel(id: category.id, title: category.categoryTitle, isSelected: isSelected)
        
        return categoryCellViewModel
    }
    
    func numberOfCategories() -> Int {
        categoryDataProvider.numberOfRows
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    
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
