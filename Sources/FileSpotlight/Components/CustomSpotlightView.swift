//
//  CustomSpotlightView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

/// A highly customizable spotlight search view that allows for a user-defined row view.
///
/// This view provides a standard spotlight search interface, including a search bar and a scrollable list of results.
/// It is generic over an `Item` type (the data model for search results) and a `RowView` type.
/// The `RowView` must conform to `SpotlightRowViewProtocol` and is used to render each item in the results list,
/// giving the developer full control over the appearance of the search results.
public struct CustomSpotlightView<Item: SpotlightItem, RowView: SpotlightRowViewProtocol>: View where RowView.Item == Item {
	
	// MARK: - Properties
	
	/// The view model that manages the state, data, and business logic for the spotlight search.
	@ObservedObject private var viewModel: CustomSpotlightViewModel<Item>
	
	/// The fixed width of the spotlight view.
	private let width: CGFloat
	
	/// The type of the custom view used to render each row in the results list.
	private let rowViewType: RowView.Type
	
	/// The shape used for clipping and applying visual effects to the main container.
	/// Defaults to a rounded rectangle but can be customized.
	private var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 36))
	
	// MARK: - Initializer
	
	/// Creates a custom spotlight view.
	/// - Parameters:
	///   - viewModel: The view model to drive the view's state and logic.
	///   - width: The desired width of the view. Defaults to 600 points.
	///   - rowView: The custom `View` type to use for displaying each search result item.
	public init(
		viewModel: CustomSpotlightViewModel<Item>,
		width: CGFloat = 600,
		rowView: RowView.Type
	) {
		self.viewModel = viewModel
		self.width = width
		self.rowViewType = rowView
	}
	
	// MARK: - Body
	
	public var body: some View {
		VStack(spacing: 0) {
			searchBar
				.padding()
			
			// Only show the results section if the view model's state indicates that results should be visible.
			if viewModel.state == .showingResults {
				// Optionally add a divider between the search bar and results.
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				resultsView
			}
		}
		.frame(width: width)
		.glassEffect(.regular, in: shape) // Applies a custom glass-like visual effect.
		.onKeyPress { keyPress in
			// Forwards key press events to the view model for handling navigation (e.g., up/down arrows).
			Task { @MainActor in viewModel.handleKeyPress(keyPress) }
			
			return .handled
		}
	}
	
	// MARK: - Modifiers
	
	/// Customizes the clipping shape of the spotlight view.
	/// - Parameter shape: A shape conforming to SwiftUI's `Shape` protocol.
	/// - Returns: A new version of the view with the specified shape.
	public func clipShape<S: Shape>(_ shape: S) -> Self {
		var view = self
		view.shape = AnyShape(shape)
		return view
	}
	
	// MARK: - Subviews
	
	/// A view component for the search bar, including an icon, text field, and status indicators.
	private var searchBar: some View {
		// Fetches details for the search bar from the view model's principal section.
		let item  = viewModel.getPrincipalSection()
		let icon  = item.icon ?? "gearshape" // Default icon.
		let title = item.title ?? "nil"     // Default placeholder text.
		
		return HStack(spacing: 12) {
			Image(systemName: icon)
				.foregroundColor(.secondary)
				.font(.title2)
			
			TextField(
				title,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			.onSubmit {
				// Executes the action for the currently selected item when the user presses Enter.
				viewModel.selectCurrent()
			}
			
			// Show a progress indicator while a search is in progress.
			if viewModel.isLoading {
				ProgressView()
					.scaleEffect(0.7)
			// Show a clear button if the search field is not empty and not loading.
			} else if !viewModel.searchText.isEmpty {
				Button(action: { viewModel.reset() }) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	/// A view component that displays the list of search results.
	private var resultsView: some View {
		// `ScrollViewReader` allows programmatically scrolling to a specific result.
		ScrollViewReader { proxy in
			ScrollView {
				// `LazyVStack` improves performance by only creating views for items as they become visible.
				LazyVStack(spacing: 8) {
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						// Initialize the user-provided custom row view for each item.
						rowViewType.init(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								// Handle tap gestures on the row.
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index) // Assign a unique ID for the `ScrollViewReader` to target.
					}
				}
				.padding()
				// The background with GeometryReader is a technique to measure the content's height.
				.background(
					GeometryReader { geo in
						Color.clear.preference(
							key: ContentHeightKey.self,
							value: geo.size.height
						)
					}
				)
			}
			.frame(maxHeight: viewModel.configuration.maxHeight) // Constrain the scrollable area height.
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				// Automatically scroll to the newly selected item with an animation.
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			// Define a custom animation for when the results view appears and disappears.
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}
