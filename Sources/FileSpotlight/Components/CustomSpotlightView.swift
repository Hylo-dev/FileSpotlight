//
//  CustomSpotlightView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

// MARK: - Custom Row View Spotlight
public struct CustomSpotlightView<Item: SpotlightItem, RowView: SpotlightRowViewProtocol>: View where RowView.Item == Item {
	
	@ObservedObject private var viewModel: SpotlightViewModel<Item>
	
	private let width: CGFloat
	private let rowViewType: RowView.Type
	private var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 36))
	
	public init(
		viewModel: SpotlightViewModel<Item>,
		width: CGFloat = 600,
		rowView: RowView.Type
	) {
		self.viewModel = viewModel
		self.width = width
		self.rowViewType = rowView
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			searchBar
				.padding()
			
			if viewModel.state == .showingResults {
				if viewModel.configuration.showDividers {
					Divider()
				}
				
				resultsView
			}
		}
		.frame(width: width)
		.glassEffect(.regular, in: shape)
		.onKeyPress { keyPress in
			viewModel.handleKeyPress(keyPress)
		}
	}
	
	// MARK: - Modifiers
	public func clipShape<S: Shape>(_ shape: S) -> Self {
		var view = self
		view.shape = AnyShape(shape)
		return view
	}
	
	private var searchBar: some View {
		let item  = viewModel.sections[viewModel.selectedSection]
		let icon  = item.icon ?? "gearshape"
		let title = item.title ?? "nil"
		
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
				viewModel.selectCurrent()
			}
			
			if viewModel.isLoading {
				ProgressView()
					.scaleEffect(0.7)
			} else if !viewModel.searchText.isEmpty {
				Button(action: { viewModel.reset() }) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
				}
				.buttonStyle(.plain)
			}
		}
	}
	
	private var resultsView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				LazyVStack(spacing: 8) {
					ForEach(viewModel.searchResults.indices, id: \.self) { index in
						let item = viewModel.searchResults[index]
						let isSelected = index == viewModel.selectedIndex
						
						rowViewType.init(
							item: item,
							isSelected: isSelected,
							style: viewModel.rowStyle,
							onTap: {
								viewModel.selectedIndex = index
								viewModel.selectCurrent()
							}
						)
						.id(index)
					}
				}
				.padding()
				.background(
					GeometryReader { geo in
						Color.clear.preference(
							key: ContentHeightKey.self,
							value: geo.size.height
						)
					}
				)
			}
			.frame(maxHeight: viewModel.configuration.maxHeight)
			.onChange(of: viewModel.selectedIndex) { _, newIndex in
				withAnimation(.easeInOut(duration: 0.3)) {
					proxy.scrollTo(newIndex, anchor: .center)
				}
			}
		}
		.transition(
			.asymmetric(
				insertion: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity),
				removal: .scale(scale: 0.95, anchor: .top)
					.combined(with: .opacity)
			)
		)
	}
}
