//
//  FileSearchView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI

/// A SwiftUI view that mimics the behavior of a Spotlight search bar.
/// It displays a search field and a list of results based on user input.
/// The view is generic over an `Item` type, which must conform to the `SpotlightItem` protocol.
///
/// The state and logic are managed by a `SpotlightViewModel`, which must be provided upon initialization.
/// Use `initSimpleSpotlight`, this init set `SpotlightViewModel`to default file search bar.
public struct FileSearchSpotlightView<Item: SpotlightItem>: View {
	
	// MARK: - Properties
	
	/// The view model that holds the state and business logic for the search functionality.
	/// It's an `@ObservedObject` to ensure the view updates when its properties change.
	@ObservedObject private var viewModel: FileSearchSpotlightViewModel<Item>
	
	/// The fixed width of the Spotlight view.
	private let width: CGFloat
	
	/// The shape used for clipping the view and applying the background effect.
	/// Defaults to a `RoundedRectangle`. Can be customized using the `.clipShape()` modifier.
	private var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 36))
	
	// MARK: - Initializer
	
	/// Creates a Spotlight view with the given view model and an optional width.
	/// - Parameters:
	///   - viewModel: The view model that manages the search state.
	///   - width: The width of the view. Defaults to `600`.
	public init(
		viewModel: FileSearchSpotlightViewModel<Item>,
		width: CGFloat = 600
	) {
		self.viewModel = viewModel
		self.width = width
	}
	
	// MARK: - Body
	
	public var body: some View {
		VStack(spacing: 0) {
			// The main search bar input area.
			searchBar
				.padding()
			
			// Conditionally display the results view only when there are results to show.
			if viewModel.state == .showingResults {
				// Optional divider between the search bar and the results list.
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				// The scrollable list of search results.
				resultsView
			}
		}
		.frame(width: width) // Apply the specified width.
		.glassEffect(.regular, in: shape) // Apply a translucent "glass" background effect.
		.onKeyPress { keyPress in
			// Handle keyboard events (like arrow keys) by forwarding them to the view model.
			viewModel.handleKeyPress(keyPress)
		}
	}
	
	// MARK: - Modifiers
	
	/// A custom modifier to change the clipping shape of the view.
	/// - Parameter shape: The new `Shape` to apply.
	/// - Returns: A new version of the view with the updated shape.
	public func clipShape<S: Shape>(_ shape: S) -> Self {
		var view = self
		view.shape = AnyShape(shape)
		return view
	}
	
	// MARK: - Private Subviews
	
	/// A computed property that defines the search bar's layout and components.
	private var searchBar: some View {
		// Get the currently active section to display its icon and title.
		let item  = viewModel.getPrincipalSection()
		let icon  = item.icon ?? "gearshape" // Use a default icon if none is provided.
		let title = item.title ?? "nil" // Use a default title if none is provided.
		
		return HStack(spacing: 12) {
			// Icon for the current search section.
			Image(systemName: icon)
				.foregroundColor(.secondary)
				.font(.title2)
			
			// The text field for user input.
			TextField(
				title,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			.onSubmit {
				// When the user presses Enter/Return, select the currently highlighted item.
				viewModel.selectCurrent()
			}
			
			// A button to clear the search text and reset the state.
			if viewModel.searchText != "" {
				Button(action: { viewModel.reset() }) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	/// A computed property that defines the scrollable list of search results.
	private var resultsView: some View {
		// `ScrollViewReader` allows for programmatic scrolling to a specific item.
		ScrollViewReader { proxy in
			ScrollView {
				// `LazyVStack` only creates items as they are needed for display, improving performance.
				LazyVStack(spacing: 8) {
					// Iterate over the search results to create a row for each.
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						// The view for a single result row.
						DefaultSpotlightRowView(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								// On tap, update the selected index and trigger the selection action.
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index) // Assign a unique ID for the ScrollViewReader to target.
					}
				}
				.padding()
			}
			.frame(maxHeight: viewModel.configuration.maxHeight) // Constrain the height of the results list.
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				// Whenever the selected index changes (e.g., via arrow keys),
				// animate the scroll view to keep the selected item visible.
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			// Define a custom animation for when the results view appears and disappears.
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
			)
		)
	}
}
