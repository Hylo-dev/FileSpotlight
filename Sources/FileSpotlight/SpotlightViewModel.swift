//
//  FileSearchViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI
import Combine

/// Stati dello spotlight
public enum SpotlightState: Sendable {
	case idle
	case searching
	case showingResults
	case showingSections
}

/// ViewModel generico per lo spotlight
@MainActor
public class SpotlightViewModel<Item: SpotlightItem>: ObservableObject {
	
	// MARK: - Published Properties
	
	@Published public var searchText: String = ""
	@Published public var selectedIndex: Int = 0
	@Published public var selectedSection: Int = 0
	@Published public var state: SpotlightState = .idle
	@Published public var searchResults: [Item] = []
	@Published public var isLoading: Bool = false
	
	// MARK: - Configuration
	
	public let configuration: SpotlightConfiguration
	public let rowStyle: SpotlightRowStyle
	public private(set) var sections: [SpotlightSection<Item>]
	
	// MARK: - Private Properties
	
	private var dataSource: (any SpotlightDataSource)?
	private var allItems: [Item] = []
	private var cancellables = Set<AnyCancellable>()
	private var searchTask: Task<Void, Never>?
	
	// MARK: - Initialization
	
	public init(
		dataSource		: (any SpotlightDataSource)? = nil,
		sections		: [SpotlightSection<Item>]   = [],
		configuration	: SpotlightConfiguration     = .default,
		rowStyle		: SpotlightRowStyle 		 = .default,
	) {
		self.dataSource    = dataSource
		self.sections      = sections
		self.configuration = configuration
		self.rowStyle      = rowStyle
		
		let home = SpotlightSection<SpotlightFileItem>(
			id	    : self.configuration.title.lowercased(),
			title   : self.configuration.title,
			icon    : self.configuration.icon,
			items	: { [] },
			onSelect: self.configuration.onSelect
		)
		
		self.sections.append(home as! SpotlightSection<Item>)
		
		setupSearchBinding()
		loadInitialData()
	}
	
	// MARK: - Public Methods
	
	/// Aggiunge una sezione allo spotlight
	public func addSection(_ section: SpotlightSection<Item>) {
		sections.append(section)
	}
	
	/// Rimuove una sezione per ID
	public func removeSection(withId id: String) {
		sections.removeAll { $0.id == id }
	}
	
	/// Ottiene tutte le sezioni visibili
	public func visibleSections() -> [SpotlightSection<Item>] {
		sections.filter { $0.isVisible() }
	}
	
	/// Resetta lo spotlight
	public func reset() {
		searchText = ""
		selectedIndex = 0
		searchResults = []
		state = .idle
	}
	
	/// Ricarica i dati
	public func reload() {
		loadInitialData()
	}
	
	/// Gestisce la selezione corrente
	public func selectCurrent() {
		guard !searchResults.isEmpty, selectedIndex < searchResults.count else { return }
		let item = searchResults[selectedIndex]
		
		handleSelection(item)
	}
	
	/// Naviga verso l'alto
	public func navigateUp() {
		if selectedIndex > 0 {
			selectedIndex -= 1
		}
	}
	
	/// Naviga verso il basso
	public func navigateDown() {
		if selectedIndex < searchResults.count - 1 {
			selectedIndex += 1
		}
	}
	
	/// Navigate to left sections
	public func navigateLeft() {
		if selectedSection > 0 && state == .idle {
			selectedSection -= 1
		}
	}
	
	/// Navigate to right sections
	public func navigateRight() {
		if selectedSection < sections.count - 1 && state == .idle {
			selectedSection += 1
		}
	}
	
	/// Gestisce eventi della tastiera
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
				selectCurrent()
				return .handled
				
			case .escape:
				reset()
				return .handled
				
			default:
				return .ignored
		}
	}
	
	// MARK: - Private Methods
	
	private func setupSearchBinding() {
		$searchText
			.debounce(
				for: .milliseconds(configuration.debounceInterval),
				scheduler: RunLoop.main
			)
			.removeDuplicates()
			.sink { [weak self] query in
				self?.performSearch(query: query)
			}
			.store(in: &cancellables)
	}
	
	private func loadInitialData() {
		guard let dataSource = dataSource else { return }
		
		Task { @MainActor in
			if let fileDataSource = dataSource as? FileSystemDataSource {
				let items = await fileDataSource.allItems()
				self.allItems = items as! [Item]
			}
		}
	}
	
	private nonisolated func performSearch(query: String) {
		Task { @MainActor in
			await self.performSearchOnMainActor(query: query)
		}
	}
	
	private func performSearchOnMainActor(query: String) async {
		searchTask?.cancel()
		
		guard !query.isEmpty else {
			searchResults = []
			state = .idle
			selectedIndex = 0
			return
		}
		
		searchTask = Task { @MainActor in
			self.isLoading = true
			
			var results: [Item] = []
			
			if let dataSource = self.dataSource {
				if let fileDataSource = dataSource as? FileSystemDataSource {
					let items = await fileDataSource.search(query: query)
					results = items as! [Item]
				}
			} else {
				results = self.allItems.filter { item in
					item.displayName.localizedCaseInsensitiveContains(query)
				}
			}
			
			guard !Task.isCancelled else { return }
			
			withAnimation(.easeInOut(duration: self.configuration.animationDuration)) {
				self.searchResults = results
				self.state = results.isEmpty ? .searching : .showingResults
				self.selectedIndex = 0
				self.isLoading = false
			}
		}
		
		await searchTask?.value
	}
	
	private func handleSelection(_ item: Item) {
		
		let section = sections[selectedSection]
		Task { @MainActor in
			section.onSelect(item)
			self.reset()
		}
	}
}

// MARK: - Convenience Extensions

extension SpotlightViewModel where Item == SpotlightFileItem {
	
	/// Crea un ViewModel per la ricerca di file
	public static func fileSearch(
		directory: URL,
		fileExtensions: [String]? = nil,
		configuration: SpotlightConfiguration = .default
		
	) -> SpotlightViewModel<SpotlightFileItem> {
		let dataSource = FileSystemDataSource(
			directory: directory,
			fileExtensions: fileExtensions
		)
		
		let home = SpotlightSection<SpotlightFileItem>(
			id	    : configuration.title.lowercased(),
			title   : configuration.title,
			icon    : configuration.icon,
			items	: { [] },
			onSelect: configuration.onSelect
		)
		
		return SpotlightViewModel(
			dataSource	 : dataSource,
			sections	 : [home],
			configuration: configuration
		)
	}
}

// MARK: - Async/Await Helpers

extension SpotlightViewModel {
	/// Cerca in modo asincrono
	public func searchAsync(query: String) async -> [Item] {
		guard let dataSource = dataSource else { return [] }
		
		if let fileDataSource = dataSource as? FileSystemDataSource {
			let items = await fileDataSource.search(query: query)
			return items as! [Item]
		}
		
		return []
	}
}
