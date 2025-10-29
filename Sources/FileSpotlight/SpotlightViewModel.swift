//
//  FileSearchViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI
import Combine
/// A generic `ViewModel` for managing Spotlight search behavior.
///
/// `SpotlightViewModel` handles text search, keyboard navigation,
/// section management, and async search operations. It works with any type
/// conforming to `SpotlightItem`.
///
/// - Example:
/// ```swift
/// let viewModel = SpotlightViewModel<SpotlightFileItem>(
///     dataSource   : FileSystemDataSource(directory: url, fileExtensions: ["txt"]),
///     configuration: .init(title: "Files")
/// )
/// ```
@MainActor
public class SpotlightViewModel<Item: SpotlightItem>: ObservableObject {
	
	// MARK: - Published Properties
	
	/// Current user input in the search bar.
	@Published public var searchText: String = ""
	
	/// Index of the currently selected item in search results.
	@Published public var selectedIndex: Int = 0
	
	/// Index of the currently selected section.
	@Published public var selectedSection: Int = 0
	
	/// Current view state of the Spotlight (idle, searching, results, etc.).
	@Published public var state: SpotlightState = .idle
	
	/// The current search results.
	@Published public var searchResults: [Item] = []
	
	/// Indicates whether a search operation is in progress.
	@Published public var isLoading: Bool = false
	
	// MARK: - Configuration
	
	/// Spotlight configuration parameters (appearance, timing, callbacks).
	public let configuration: SpotlightConfiguration
	
	/// Visual style for rows in the results view.
	public let rowStyle: SpotlightRowStyle
	
	/// The list of available sections in the Spotlight.
	public private(set) var sections: [SpotlightSection<Item>]
	
	// MARK: - Private Properties
	
	private var dataSource: (any SpotlightDataSource)?
	private var allItems: [Item] = []
	private var cancellables: Set<AnyCancellable> = []
	private var searchTask: Task<Void, Never>?
	
	// MARK: - Initialization
	
	/// Creates a new `SpotlightViewModel` instance.
	///
	/// - Parameters:
	///   - dataSource: Optional custom data source for async search.
	///   - sections: Sections shown in the Spotlight.
	///   - configuration: General configuration.
	///   - rowStyle: Style for each search result row.
	///
	/// - Example:
	/// ```swift
	/// let vm = SpotlightViewModel<SpotlightFileItem>(
	///     		dataSource   : FileSystemDataSource(directory: url, fileExtensions: ["txt"]),
	///     		configuration: .init(
	///     			debounceInterval: 100,
	///     			maxHeight       : 250
	///     	 	)
	/// 		  )
	/// ```
	public init(
		dataSource: (any SpotlightDataSource)? = nil,
		sections: [SpotlightSection<Item>] = [],
		configuration: SpotlightConfiguration = .default,
		rowStyle: SpotlightRowStyle = .default
	) {
		self.dataSource    = dataSource
		self.sections      = sections
		self.configuration = configuration
		self.rowStyle      = rowStyle
		
		let home = SpotlightSection<SpotlightFileItem>(
			id: configuration.title.lowercased(),
			title: configuration.title,
			icon: configuration.icon,
			view: { EmptyView() },
			onSelect: configuration.onSelect
		)
		
		self.sections.append(home as! SpotlightSection<Item>)
		
		setupSearchBinding()
		loadInitialData()
	}
	
	// MARK: - Public Methods
	
	/// Adds a new section to the Spotlight.
	///
	/// - Parameter section: The `SpotlightSection` to append.
	/// - Note: The section will appear in `sections` and be considered for navigation.
	/// - Example:
	/// ```swift
	/// viewModel.addSection(mySection)
	/// ```
	public func addSection(_ section: SpotlightSection<Item>) {
		sections.append(section)
	}
	
	/// Removes a section by its unique identifier.
	///
	/// - Parameter id: The section `id` to remove.
	/// - Note: If multiple sections share the same id, all will be removed.
	/// - Example:
	/// ```swift
	/// viewModel.removeSection(withId: "extensions")
	/// ```
	public func removeSection(withId id: String) {
		sections.removeAll { $0.id == id }
	}
	
	/// Returns all currently visible sections.
	///
	/// - Returns: Array of `SpotlightSection` filtered by `.isVisible()`.
	/// - Example:
	/// ```swift
	/// let visible = viewModel.visibleSections()
	/// ```
	public func visibleSections() -> [SpotlightSection<Item>] {
		sections.filter { $0.isVisible() }
	}
	
	/// Resets the Spotlight to its initial state.
	///
	/// - Note: Clears search text, results and selection state.
	/// - Example:
	/// ```swift
	/// viewModel.reset()
	/// ```
	public func reset() {
		searchText	    = ""
		selectedIndex   = 0
		selectedSection = 0
		searchResults   = []
		state		    = .idle
	}
	
	/// Reloads data from the data source.
	///
	/// - Note: This triggers `loadInitialData()` which re-fetches all items from the data source.
	/// - Example:
	/// ```swift
	/// viewModel.reload()
	/// ```
	public func reload() {
		loadInitialData()
	}
	
	/// Selects the currently highlighted item.
	///
	/// - Note: Calls the `onSelect` handler of the currently selected section and then resets the state.
	/// - Example:
	/// ```swift
	/// viewModel.selectCurrent()
	/// ```
	public func selectCurrent() {
		guard !searchResults.isEmpty, selectedIndex < searchResults.count else { return }
		let item = searchResults[selectedIndex]
		handleSelection(item)
	}
	
	/// Moves the current selection up by one item.
	///
	/// - Note: Does nothing if the selection is already at the top.
	/// - Example:
	/// ```swift
	/// viewModel.navigateUp()
	/// ```
	public func navigateUp() {
		if selectedIndex > 0 {
			selectedIndex -= 1
		}
	}
	
	/// Moves the current selection down by one item.
	///
	/// - Note: Does nothing if the selection is at the last result.
	/// - Example:
	/// ```swift
	/// viewModel.navigateDown()
	/// ```
	public func navigateDown() {
		if selectedIndex < searchResults.count - 1 {
			selectedIndex += 1
		}
	}
	
	/// Moves to the previous section (if idle).
	///
	/// - Note: Only allowed when `state == .idle`.
	/// - Example:
	/// ```swift
	/// viewModel.navigateLeft()
	/// ```
	public func navigateLeft() {
		if selectedSection > 0 && state == .idle {
			selectedSection -= 1
		}
	}
	
	/// Moves to the next section (if idle).
	///
	/// - Note: Only allowed when `state == .idle`.
	/// - Example:
	/// ```swift
	/// viewModel.navigateRight()
	/// ```
	public func navigateRight() {
		if selectedSection < sections.count - 1 && state == .idle {
			selectedSection += 1
		}
	}
	
	/// Handles a key press event for navigation or selection.
	///
	/// - Parameter keyPress: The key event to handle.
	/// - Returns: The handling result (`.handled` or `.ignored`).
	/// - Example:
	/// ```swift
	/// let result = viewModel.handleKeyPress(.init(key: .downArrow))
	/// ```
	@discardableResult
	public func handleKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
		switch keyPress.key {
			case .downArrow:
				navigateDown()
				return .handled
				
			case .upArrow:
				navigateUp()
				return .handled
					
			case .leftArrow:
				withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
					navigateLeft()
				}
				return .handled
				
			case .rightArrow:
				withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
					navigateRight()
				}
				return .handled
				
			case .return:
				if selectedSection == 0 || state == .focusSection {
					selectCurrent()
				} else {
					withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
						state = .focusSection
					}
				}
				return .handled
				
			case .escape:
				withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { reset() }
				return .handled
				
			default:
				return .ignored
		}
	}
	
	/// Performs an asynchronous search for the given query.
	///
	/// - Parameter query: The search query.
	/// - Returns: An array of matching items.
	/// - Note: Uses `dataSource` if provided, otherwise returns an empty array for async path.
	/// - Example:
	/// ```swift
	/// let results = await viewModel.searchAsync(query: "readme")
	/// ```
	public func searchAsync(query: String) async -> [Item] {
		guard let dataSource = dataSource else { return [] }
		
		if let fileDataSource = dataSource as? FileSystemDataSource {
			let items = await fileDataSource.search(query: query)
			return items as! [Item]
		}
		
		return []
	}
	
	// MARK: - Private Methods
	
	/// Configures the Combine pipeline that observes `searchText`.
	///
	/// - Note: Debounces input, removes duplicates and calls `performSearch(query:)`.
	private func setupSearchBinding() {
		$searchText
			.debounce(for: .milliseconds(configuration.debounceInterval), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] query in
				self?.performSearch(query: query)
			}
			.store(in: &cancellables)
	}
	
	/// Loads initial data from `dataSource` into `allItems`.
	///
	/// - Note: Called at init and by `reload()`. Executes asynchronously on Main actor.
	private func loadInitialData() {
		guard let dataSource = dataSource else { return }
		Task { @MainActor in
			if let fileDataSource = dataSource as? FileSystemDataSource {
				let items = await fileDataSource.allItems()
				self.allItems = items as! [Item]
			}
		}
	}
	
	/// Triggers the async search flow from non-isolated contexts.
	///
	/// - Parameter query: The search text to perform.
	/// - Note: Calls into `performSearchOnMainActor(query:)`.
	private nonisolated func performSearch(query: String) {
		Task { @MainActor in
			await self.performSearchOnMainActor(query: query)
		}
	}
	
	/// Performs the actual search on the Main actor, updating UI state.
	///
	/// - Parameter query: The query string to search for.
	/// - Note: Cancels previous search task if running. Updates `searchResults`, `state`, `selectedIndex` and `isLoading`.
	private func performSearchOnMainActor(query: String) async {
		searchTask?.cancel()
		
		guard !query.isEmpty else {
			searchResults = []
			state = .idle
			selectedIndex = 0
			return
		}
		
		searchTask = Task { @MainActor in
			isLoading = true
			
			var results: [Item] = []
			
			if let dataSource = dataSource {
				if let fileDataSource = dataSource as? FileSystemDataSource {
					let items = await fileDataSource.search(query: query)
					results = items as! [Item]
				}
			} else {
				results = allItems.filter { item in
					item.displayName.localizedCaseInsensitiveContains(query)
				}
			}
			
			guard !Task.isCancelled else { return }
			
			withAnimation(.easeInOut(duration: configuration.animationDuration)) {
				searchResults = results
				state = results.isEmpty ? .searching : .showingResults
				selectedIndex = 0
				isLoading = false
			}
		}
		
		await searchTask?.value
	}
	
	/// Executes the selection logic for a given item.
	///
	/// - Parameter item: The item that was selected.
	/// - Note: Calls the current section's `onSelect` callback on the Main actor and then resets the view model.
	private func handleSelection(_ item: Item) {
		let section = sections[selectedSection]
		Task { @MainActor in
			section.onSelect(item)
			reset()
		}
	}
}

// MARK: - File Spotlight Convenience

extension SpotlightViewModel where Item == SpotlightFileItem {
	
	/// Initializes a `SpotlightViewModel` configured for file search.
	///
	/// - Parameters:
	///   - directory: The directory to search.
	///   - fileExtensions: File extensions to include.
	///   - configuration: Optional UI and behavior configuration.
	///
	/// - Returns: A `SpotlightViewModel` instance wired to a `FileSystemDataSource`.
	/// - Example:
	/// ```swift
	/// let fileSpotlight = SpotlightViewModel.initFileSearch(
	///     directory     : URL(fileURLWithPath: "/Users/elio/Documents"),
	///     fileExtensions: ["swift", "txt"]
	/// )
	/// ```
	public static func initFileSearch(
		directory: URL,
		fileExtensions: [String],
		configuration: SpotlightConfiguration = .default
	) -> SpotlightViewModel<SpotlightFileItem> {
		let dataSource = FileSystemDataSource(
			directory: directory,
			fileExtensions: fileExtensions
		)
		
		let home = SpotlightSection<SpotlightFileItem>(
			id: configuration.title.lowercased(),
			title: configuration.title,
			icon: configuration.icon,
			view: { EmptyView() },
			onSelect: configuration.onSelect
		)
		
		return SpotlightViewModel(
			dataSource: dataSource,
			sections: [home],
			configuration: configuration
		)
	}
	
	/// Initializes a file search Spotlight with multiple custom sections.
	///
	/// - Parameters:
	///   - directory: Directory to scan for files.
	///   - fileExtensions: Extensions to include.
	///   - configuration: Optional configuration for UI/behavior.
	///   - sections: Additional sections to prepend after the home section.
	///
	/// - Returns: A configured `SpotlightViewModel<SpotlightFileItem>`.
	/// - Example:
	/// ```swift
	/// let vm = SpotlightViewModel.initMultipleSection(
	///     directory     : dir,
	///     fileExtensions: ["md"],
	///     sections      : [sectionA, sectionB]
	/// )
	/// ```
	public static func initMultipleSection(
		directory: URL,
		fileExtensions: [String],
		configuration: SpotlightConfiguration = .default,
		sections: [SpotlightSection<Item>]
	) -> SpotlightViewModel<SpotlightFileItem> {
		
		let dataSource = FileSystemDataSource(
			directory: directory,
			fileExtensions: fileExtensions
		)
		
		let home = SpotlightSection<SpotlightFileItem>(
			id: configuration.title.lowercased(),
			title: configuration.title,
			icon: configuration.icon,
			view: { EmptyView() },
			onSelect: configuration.onSelect
		)
		
		return SpotlightViewModel(
			dataSource: dataSource,
			sections: [home] + sections,
			configuration: configuration
		)
	}
}
