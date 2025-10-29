//
//  MultiSectionSpotlightView.swift
//  FileSpotlight
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import SwiftUI

public struct MultiSectionSpotlightView<Item: SpotlightItem>: View {
	@ObservedObject private var viewModel: SpotlightViewModel<Item>
	
	private let width: CGFloat
	private var shape: AnyShape = AnyShape(RoundedRectangle(cornerRadius: 36))
	
	public init(viewModel: SpotlightViewModel<Item>, width: CGFloat = 600) {
		self.viewModel = viewModel
		self.width	   = width
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			
			GlassEffectContainer {
				
				HStack {
					let textAreaWidth  = viewModel.selectedSection > 0 &&
										 viewModel.state == .idle ?
										 width - 65 : width
					
					VStack {
						searchBar
							.padding()
						
						if viewModel.state == .showingResults || viewModel.state == .focusSection {
							if viewModel.configuration.showDividers {
								Divider()
							}
							
							resultsView
						}
					}
					.frame(width: textAreaWidth)
					.glassEffect(.regular, in: shape)
					.onKeyPress { keyPress in
						viewModel.handleKeyPress(keyPress)
					}
					
					if viewModel.state == .idle &&
						!viewModel.visibleSections().isEmpty &&
						viewModel.selectedSection != 0
					{
						sectionsView
					}
				}
			}
			
		}
	}
	
	// MARK: - Modifiers
	public func clipShape<S: Shape>(_ shape: S) -> Self {
		var view = self
		view.shape = AnyShape(shape)
		return view
	}
	
	private var searchBar: some View {
		HStack(spacing: 12) {
			let item = viewModel.sections[viewModel.selectedSection]
			let icon = item.icon ?? "gearshape"
			Image(systemName: icon) // viewModel.configuration.searchIcon
				.foregroundColor(.secondary)
				.font(.title2)
			
			let placeholder = item.title ?? "nil"
			TextField(
				placeholder,
				text: $viewModel.searchText
			)
			.textFieldStyle(.plain)
			.font(.title2)
			
			if viewModel.isLoading {
				ProgressView()
					.scaleEffect(0.7)
			}
		}
	}
	
	private var sectionsView: some View {
		ForEach(viewModel.visibleSections().enumerated(), id: \.element.id) { index, section in
			if index != 0 { sectionView(section, index) }
		}
	}
	
	private func sectionView(_ section: SpotlightSection<Item>, _ index: Int) -> some View {
		return Button {
			withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
				self.viewModel.selectedSection = index
			}
			
		} label: {
			Image(systemName: section.icon ?? "gearshape")
				.font(.system(size: 19))
				.frame(width: 55, height: 55)
				.contentShape(Circle())
			
		}
		.buttonStyle(.plain)
		.glassEffect(
			.regular.tint(
					viewModel.selectedSection == index ?
					Color.accentColor :
					Color.clear
				),
			in: .circle
		)
		.clipShape(Circle())
		.transition(.move(edge: .leading).combined(with: .opacity))
	}
	
	private var resultsView: some View {
		let index = self.viewModel.selectedSection
		
		return ScrollViewReader { proxy in
			ScrollView {
				switch index {
					case 0:
						LazyVStack(spacing: 8) {
							ForEach(viewModel.searchResults.indices, id: \.self) { index in
								let item = viewModel.searchResults[index]
								let isSelected = index == viewModel.selectedIndex
								
								DefaultSpotlightRowView(
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
				
					default:
						self.viewModel.sections[index].buildView()
				}
				
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
