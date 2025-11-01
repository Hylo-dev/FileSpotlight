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
	
	/// Use for set focused text field when this appear
	private var focusBinding: FocusState<Bool>.Binding?
	
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
		let section = self.viewModel.getPrincipalSection()
		
		VStack(spacing: 0) {
			HStack(
				alignment: .firstTextBaseline,
				spacing: 12
			) {
				// The main search bar input area.
				SearchBarView(
					title	  : section.title ?? "nil",
					icon	  : section.icon  ?? "gearshape",
					focusState: self.focusBinding,
					searchText: self.$viewModel.searchText
				)
			}
			.padding()
			
			// Only show the results section if the view model's state indicates that results should be visible.
			if viewModel.state == .showingResults {
				// Optionally add a divider between the search bar and results.
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				// The scrollable list of search results.
				ResultsView<Item>(
					listSelectedIndex: self.$viewModel.selectedIndex,
					spotlightSection : self.viewModel.getPrincipalSection(),
					searchResults	 : self.viewModel.searchResults,
					rowStyle		 : self.viewModel.rowStyle,
					maxHeight		 : self.viewModel.configuration.maxHeight,
					selectCurrentRow : self.viewModel.selectCurrent
				)
			}
		}
		.frame(width: width)
		.glassEffect(.regular, in: shape) // Applies a custom glass-like visual effect.
		.onKeyPress { keyPress in
			// Forwards key press events to the view model for handling navigation (e.g., up/down arrows).
			viewModel.handleKeyPress(keyPress)
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
	
	/// Get focusable state.
	/// - Parameter binding: Focusable state
	public func focused(_ binding: FocusState<Bool>.Binding) -> Self {
		var view = self
		view.focusBinding = binding
		return view
	}
}
