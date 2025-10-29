//
//  MultiSectionSpotlightViewModel.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI
import Combine

/// A generic `ViewModel` for managing multi-section Spotlight search behavior.
///
/// `MultiSectionSpotlightViewModel` handles text search, keyboard navigation,
/// section management, and async search operations. It works with any type
/// conforming to `SpotlightItem`.
///
/// - Example for a generic setup:
/// ```swift
/// let vm = MultiSectionSpotlightViewModel<SpotlightFileItem>(
///     directory: dir,
///     fileExtensions: ["md"],
///     sections: [sectionA, sectionB]
/// )
/// ```
@MainActor
public class MultiSectionSpotlightViewModel<Item: SpotlightItem>: ObservableObject {

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

	private var dataSource	: (any SpotlightDataSource)?
	
	private var allItems	: [Item] 			  = []
	private var cancellables: Set<AnyCancellable> = []
	
	private var searchTask	: Task<Void, Never>?

	// MARK: - Initialization

	/// Creates a new `MultiSectionSpotlightViewModel` instance.
	///
	/// This is the designated initializer. For file-based searches, consider using
	/// the convenience initializer provided in the extension for `SpotlightFileItem`.
	///
	/// - Parameters:
	///   - dataSource: Optional custom data source for async search.
	///   - sections: Sections shown in the Spotlight.
	///   - configuration: General configuration.
	///   - rowStyle: Style for each search result row.
	public init(
		dataSource	 : (any SpotlightDataSource),
		sections	 : [SpotlightSection<Item>] = [],
		configuration: SpotlightConfiguration   = .default,
		rowStyle	 : SpotlightRowStyle 	    = .default
	) {
		self.dataSource    = dataSource
		self.sections      = sections
		self.configuration = configuration
		self.rowStyle      = rowStyle

		// If a "home" section isn't already provided, create one from the configuration.
		if !self.sections.contains(where: { $0.id == configuration.title.lowercased() }) {
			let home = SpotlightSection<SpotlightFileItem>(
				id	 	: configuration.title.lowercased(),
				title	: configuration.title,
				icon 	: configuration.icon,
				view 	: { EmptyView() },
				onSelect: configuration.onSelect
			)
			
			// Insert the home section at the beginning.
			self.sections.insert(home as! SpotlightSection<Item>, at: 0)
		}

		setupSearchBinding()
		loadInitialData()
	}

	// MARK: - Public Methods

	/// Adds a new section to the Spotlight.
	///
	/// - Parameter section: The `SpotlightSection` to append.
	public func addSection(_ section: SpotlightSection<Item>) {
		sections.append(section)
	}

	/// Removes a section by its unique identifier.
	///
	/// - Parameter id: The section `id` to remove.
	public func removeSection(withId id: String) {
		sections.removeAll { $0.id == id }
	}

	/// Returns all currently visible sections.
	///
	/// - Returns: Array of `SpotlightSection` filtered by `.isVisible()`.
	public func visibleSections() -> [SpotlightSection<Item>] {
		sections.filter { $0.isVisible() }
	}

	/// Resets the Spotlight to its initial state.
	public func reset() {
		searchText      = ""
		selectedIndex   = 0
		selectedSection = 0
		searchResults   = []
		state           = .idle
	}

	/// Reloads data from the data source.
	public func reload() {
		loadInitialData()
	}

	/// Selects the currently highlighted item.
	public func selectCurrent() {
		guard !searchResults.isEmpty, selectedIndex < searchResults.count else { return }
		let item = searchResults[selectedIndex]
		
		handleSelection(item)
	}

	/// Moves the current selection up by one item.
	public func navigateUp() {
		if selectedIndex > 0 {
			selectedIndex -= 1
		}
	}

	/// Moves the current selection down by one item.
	public func navigateDown() {
		if selectedIndex < searchResults.count - 1 {
			selectedIndex += 1
		}
	}

	/// Moves to the previous section (if idle).
	public func navigateLeft() {
		if selectedSection > 0 && state == .idle {
			selectedSection -= 1
		}
	}

	/// Moves to the next section (if idle).
	public func navigateRight() {
		if selectedSection < sections.count - 1 && state == .idle {
			selectedSection += 1
		}
	}

	/// Handles a key press event for navigation or selection.
	///
	/// - Parameter keyPress: The key event to handle.
	/// - Returns: The handling result (`.handled` or `.ignored`).
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
				Task { @MainActor in
					withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
						state = .focusSection
					}
				}
			}
			return .handled

		case .escape:
				Task { @MainActor in
					withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
						reset()
					}
				}
				
			return .handled

		default:
			return .ignored
		}
	}

	/// Performs an asynchronous search for the given query.
	///
	/// - Parameter query: The search query.
	/// - Returns: An array of matching items.
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
	private func setupSearchBinding() {
		$searchText
			.debounce(for: .milliseconds(configuration.debounceInterval), scheduler: RunLoop.main)
			.removeDuplicates()
			.sink { [weak self] query in self?.performSearch(query: query) }
			.store(in: &cancellables)
	}

	/// Loads initial data from `dataSource` into `allItems`.
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
	private nonisolated func performSearch(query: String) {
		Task { @MainActor in
			await self.performSearchOnMainActor(query: query)
		}
	}

	/// Performs the actual search on the Main actor, updating UI state.
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
				state 		  = results.isEmpty ? .searching : .showingResults
				selectedIndex = 0
				isLoading	  = false
			}
		}

		await searchTask?.value
	}

	/// Executes the selection logic for a given item.
	private func handleSelection(_ item: Item) {
		let section = sections[selectedSection]
		Task { @MainActor in
			section.onSelect(item)
			reset()
		}
	}
}
