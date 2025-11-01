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
	
	/// Use for set focused text field when this appear
	private var focusBinding: FocusState<Bool>.Binding?
	
	// MARK: - Initializer
	
	/// Creates a Spotlight view with the given view model and an optional width.
	/// - Parameters:
	///   - viewModel: The view model that manages the search state.
	///   - width: The width of the view. Defaults to `600`.
	public init(
		viewModel: FileSearchSpotlightViewModel<Item>,
		width	 : CGFloat = 600
	) {
		self.viewModel = viewModel
		self.width = width
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
					icon	  : section.icon ?? "gearshape",
					focusState: focusBinding,
					searchText: self.$viewModel.searchText
				)
			}
			.padding()
			
			// Conditionally display the results view only when there are results to show.
			if viewModel.state == .showingResults {
				// Optional divider between the search bar and the results list.
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
}
