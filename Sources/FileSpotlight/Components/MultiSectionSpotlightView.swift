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
	public init(viewModel: MultiSectionSpotlightViewModel<Item>, width: CGFloat = 600) {
		self.viewModel = viewModel
		self.width     = width
	}

	// MARK: - Body

	public var body: some View {
		VStack(spacing: 0) {
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
						searchBar
							.padding()

						// Conditionally show the results view and an optional divider.
						// Results are shown when the user is searching or has focused on a section.
						if viewModel.state == .showingResults || viewModel.state == .focusSection {
							if viewModel.configuration.showDividers {
								Divider()
							}
							resultsView
						}
					}
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
						sectionsView
					}
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

	// MARK: - Subviews

	/// The search bar view, including an icon and a text field.
	private var searchBar: some View {
		HStack(spacing: 12) {
			// Get the icon and title from the currently selected section.
			let item = viewModel.sections[viewModel.selectedSection]
			let icon = item.icon ?? "gearshape" // Default to a gear icon if none is provided.
			Image(systemName: icon)
				.foregroundColor(.secondary)
				.font(.title2)

			// The placeholder text is the title of the current section.
			let placeholder = item.title ?? "nil"
			if let focus = focusBinding {
				TextField(
					placeholder,
					text: $viewModel.searchText
				)
				.textFieldStyle(.plain)
				.font(.title2)
				.focused(focus)
				
			} else {
				TextField(
					placeholder,
					text: $viewModel.searchText
				)
				.textFieldStyle(.plain)
				.font(.title2)
				
			}
		}
	}

	/// The view that displays the icons for switching between sections.
	private var sectionsView: some View {
		// Iterate over all visible sections to create an icon for each.
		// The `enumerated()` call provides the index, which is used to identify the section.
		// The first section (index 0) is skipped as it's the main search view.
		ForEach(viewModel.visibleSections().enumerated(), id: \.element.id) { index, section in
			if index != 0 {
				sectionView(section, index)
					.transition(
						.asymmetric(
							insertion: .move(edge: .leading)
								.combined(with: .opacity)
								.combined(with: .scale(scale: 0.8)),
							removal: .move(edge: .leading)
								.combined(with: .opacity)
						)
					)
					.animation(
						.spring(response: 0.5, dampingFraction: 0.8)
							.delay(Double(index) * 0.15),
						value: viewModel.visibleSections().count
					)
			}
		}
	}

	/// Builds a single circular button for a given section.
	/// - Parameters:
	///   - section: The `SpotlightSection` data for which to create the view.
	///   - index: The index of the section.
	/// - Returns: A button view for the section.
	private func sectionView(_ section: SpotlightSection<Item>, _ index: Int) -> some View {
		let isSelected = viewModel.selectedSection == index
		
		return Button {			
			// When tapped, animate the selection of the new section.
			withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
				self.viewModel.selectedSection = index
			}
			
		} label: {
			Image(systemName: section.icon ?? "gearshape")
				.font(self.sizeIconSection)
			
		}
		.frame(width: sizeButtonSection, height: sizeButtonSection)
		.buttonStyle(.plain)
		.glassEffect(
			// Apply a tint to the glass effect if this section is currently selected.
			.regular.tint(isSelected ? Color.accentColor : Color.clear),
			in: .circle
		)
		.clipShape(Circle())
		.keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: [.command])
		
	}

	/// The view that displays the content for the currently selected section.
	/// This could be a list of search results or a custom view.
	private var resultsView: some View {
		let index = self.viewModel.selectedSection

		// `ScrollViewReader` allows programmatically scrolling to a specific view inside the `ScrollView`.
		return ScrollViewReader { proxy in
			ScrollView {
				// Switch on the selected section index to determine what content to show.
				switch index {
				case 0:
					// For the primary section (index 0), display the search results.
					LazyVStack(spacing: 8) {
						ForEach(viewModel.searchResults.indices, id: \.self) { index in
							let item = viewModel.searchResults[index]
							let isSelected = index == viewModel.selectedIndex

							// Use a standard row view to display the item.
							DefaultSpotlightRowView(
								item: item,
								isSelected: isSelected,
								style: viewModel.rowStyle,
								onTap: {
									// On tap, update the selection and execute the item's action.
									viewModel.selectedIndex = index
									viewModel.selectCurrent()
								}
							)
							.id(index) // Assign an ID for the `ScrollViewReader` to target.
						}
					}
					.padding()

				default:
					// For all other sections, delegate view construction to the section itself.
					// This allows for custom, non-list views in different sections.
					self.viewModel.sections[index].buildView()
				}
			}
			.frame(maxHeight: viewModel.configuration.maxHeight) // Constrain the scrollable area's height.
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				// When the selected index changes (e.g., via arrow keys), scroll the list
				// to make the newly selected item visible.
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
