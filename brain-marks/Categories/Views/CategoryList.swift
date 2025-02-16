//
//  CategoryList.swift
//  brain-marks
//
//  Created by Shloak Aggarwal on 11/04/21.
//

import SwiftUI

enum CategoryState {
    case edit
    case new
}

struct CategoryList: View {
    
    @State private var categorySheetState: CategoryState = .new
    @State private var editCategory: AWSCategory?
    @State private var indexSetToDelete: IndexSet?
    @State private var showAddURLView = false
    @State private var showingCategorySheet = false
    @State private var showingDeleteActionSheet = false
    
    @StateObject var viewModel = CategoryListViewModel()
    
    var body: some View {
        NavigationView {
            categoryList
                .navigationTitle("Categories")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            categorySheetState = .new
                            showingCategorySheet.toggle()
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                        .sheet(isPresented: $showingCategorySheet) {
                            CategorySheetView(
                                editCategory: $editCategory,
                                categorySheetState: $categorySheetState)
                                .onDisappear {
                                    viewModel.getCategories()
                                }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.showAddURLView = true
                        } label: {
                            Image(systemName:"plus.circle")
                        }
                        .sheet(isPresented: $showAddURLView) {
                            AddURLView(categories: viewModel.categories)
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.getCategories()
        }
        .accentColor(Color(UIColor.label))
    }
    
    @ViewBuilder
    var categoryList: some View {
        if viewModel.categories.isEmpty {
            ZStack {
                Image("logo.png")
                    .opacity(0.05)
            VStack {
                Text("The categories are empty, ")
                Text("please add new categories by clicking on \(Image(systemName: "folder.badge.plus"))")
            }
            }
        } else {
            categories
        }
        // removing for now, this makes the UI "flash" when updating a category
        //        if viewModel.categories.isEmpty {
        //            emptyListView
        //        } else {
        //            categories
        //        }
    }
    
    var emptyListView: some View {
        Text("You haven't created any categories!")
            .font(.title3)
            .fontWeight(.medium)
    }
    
    var categories: some View {
        List {
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: TweetList(category: category)) {
                    CategoryRow(category: category)
                }
                .contextMenu {
                    Button {
                        editCategory = category
                        categorySheetState = .edit
                        showingCategorySheet.toggle()
                    } label: {
                        Text("Edit")
                    }
                }
            }
            .onDelete { indexSet in
                showingDeleteActionSheet = true
                indexSetToDelete = indexSet
            }
        }.listStyle(InsetGroupedListStyle())
            .actionSheet(isPresented: $showingDeleteActionSheet) {
                ActionSheet(title: Text("Category and all tweets will be deleted"), buttons: [
                    .destructive(Text("Delete"), action: {
                        guard indexSetToDelete != nil else {
                            return
                        }
                        viewModel.deleteCategory(at: indexSetToDelete!)
                    }),
                    .cancel()
                ])
            }
    }
}

struct CategoryList_Previews: PreviewProvider {
    static var previews: some View {
        CategoryList()
    }
}
