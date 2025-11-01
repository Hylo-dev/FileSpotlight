//
//  MultiSectionSpotlightView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

/// A SwiftUI view that implements a multi-section spotlight-style search interface.
///
/// This view displays a search bar and can show results in different sections. Users can switch between
/// sections, each potentially having a unique icon and custom content view. It's generic over `Item`, which
/// must conform to the `SpotlightItem` protocol.
public struct MultiSectionSpotlightView<Item: SpotlightItem>: View {
	// MARK: - Properties

	/// The view model that drives the state and logic of the spotlight view.
	/// It's an `ObservedObject` to ensure the view updates when the view model's published properties change.
	@ObservedObject private var viewModel: MultiSectionSpotlightViewModel<Item>

	/// The total width of the spotlight view.
	private let width: CGFloat

	/// The shape used for clipping and applying the glass effect to the main container.
	/// It can be customized using the `clipShape` modifier.
	private var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 36))
	
	/// The size use for icon button section.
	/// It can be customized using the `sectionButtonIconSize` modifier.
	private var sizeIconSection: Font = .title
	
	/// The size use for button section.
	/// It can be customized using the `sectionButtonIconSize` modifier.
	private var sizeButtonSection: CGFloat = 55
	
	/// Use for set focused text field when this appear
	private var focusBinding: FocusState<Bool>.Binding?

	// MARK: - Initializer

	/// Creates a new multi-section spotlight view.
	/// - Parameters:
	///   - viewModel: The view model that manages the state and data for the spotlight.
	///   - width: The desired width of the view. Defaults to 600 points.
	public init(
		viewModel: MultiSectionSpotlightViewModel<Item>,
		width	 : CGFloat = 600
	) {
		self.viewModel = viewModel
		self.width     = width
	}

	// MARK: - Body

	public var body: some View {
		// A custom container that applies a glass-like visual effect.
		GlassEffectContainer(spacing: 18) {
			HStack(spacing: 15) {
				// Dynamically calculate the width of the main text/results area.
				// It shrinks to make space for the section icons when the view is idle and a section is selected.
				let textAreaWidth = viewModel.selectedSection > 0 &&
									viewModel.state == .idle ?
									width - sizeButtonSection * CGFloat(viewModel.sections.count) :
									width

				// Main content area containing the search bar and results.
				VStack {
					let index   = self.viewModel.selectedSection
					let section = self.viewModel.sections[index]
					
					HStack(spacing: 12) {
						SearchBarView(
							title	  : section.title ?? "nil",
							icon	  : section.icon ?? "gearshape",
							focusState: focusBinding,
							searchText: self.$viewModel.searchText
						)
						
						Spacer()
						
						if self.viewModel.selectedSection != 0 && self.viewModel.state != .focusSection {
							ShortcutIconView(
								sectionIndex: index,
								shortcut	: section.keyboardShortcut
							)
								
						}
					}
					.padding()
					.background {
						ForEach(1 ..< self.viewModel.sections.count, id:\.self) { index in
							let shortcut = self.viewModel.sections[index].keyboardShortcut
							
							if shortcut != nil {
								Button("") {
									withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
										self.viewModel.state 		   = .focusSection
										self.viewModel.selectedSection = index
									}
								}
								.buttonStyle(.plain)
								.keyboardShortcut(shortcut!.keyCommand, modifiers: shortcut!.modifiers)
								
							} else {
								Button("") {
									withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
										self.viewModel.state 		   = .focusSection
										self.viewModel.selectedSection = index
									}
								}
								.buttonStyle(.plain)
								.keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [.command])
								
							}
						}
					}

					// Conditionally show the results view and an optional divider.
					// Results are shown when the user is searching or has focused on a section.
					if viewModel.state == .showingResults || viewModel.state == .focusSection {
						if viewModel.configuration.showDividers { Divider() }
						let indexSection = self.viewModel.selectedSection
						
						ResultsView<Item>(
							listSelectedIndex: self.$viewModel.selectedIndex,
							indexSection	 : index,
							spotlightSection : self.viewModel.sections[indexSection],
							searchResults	 : self.viewModel.searchResults,
							rowStyle		 : self.viewModel.rowStyle,
							maxHeight		 : self.viewModel.configuration.maxHeight,
							selectCurrentRow : self.viewModel.selectCurrent
						)
					}
					
				}
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: textAreaWidth)
				.glassEffect(.regular, in: shape) // Apply glass effect to the main content area.
				.animation(.spring(response: 0.5, dampingFraction: 0.7), value: textAreaWidth)
				.onKeyPress { keyPress in
					// Forward key press events to the view model for handling navigation (e.g., arrow keys).
					viewModel.handleKeyPress(keyPress)
				}

				// Conditionally show the section selection icons on the side.
				// These appear when the view is idle, there are sections to show,
				// and the user is not in the primary (index 0) search section.
				if viewModel.state == .idle &&
					!viewModel.visibleSections().isEmpty &&
					viewModel.selectedSection > 0
				{
					SectionView(
						state		   : self.$viewModel.state,
						selectedSection: self.$viewModel.selectedSection,
						sections	   : self.viewModel.sections,
						sizeIcon	   : self.sizeIconSection,
						sizeButton	   : self.sizeButtonSection
					)
				}
			}
		}
	}

	// MARK: - Modifiers

	/// Customizes the clipping shape of the spotlight view.
	/// - Parameter shape: A shape conforming to SwiftUI's `Shape` protocol.
	/// - Returns: A new version of the view with the updated shape.
	public func clipShape<S: Shape>(_ shape: S) -> Self {
		var view = self
		view.shape = AnyShape(shape)
		
		return view
	}
	
	/// Customizes the size icon section of the spotlight section view
	/// - Parameter font: A font conforming to SwiftUI's `Font`.
	/// - Returns: A new version of the view with the updated shape.
	public func sectionButtonIconSize(_ font: Font) -> Self {
		var view = self
		view.sizeIconSection = font
		
		return view
	}
	
	/// Customizes the size button section of the spotlight section view
	/// - Parameter size: A size CGFloat value.
	/// - Returns: A new version of the view with the updated shape.
	public func sectionButtonSize(_ size: CGFloat) -> Self {
		var view = self
		view.sizeButtonSection = size
		
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
