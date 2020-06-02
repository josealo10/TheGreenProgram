//
//  CategoriesTree.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 2/10/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import UIKit

class Node{
    let category: Category
    var children: [Node] = []
    var parent: Node? = nil
    
    init(category: Category) {
        self.category = category
    }
    
    func addChild(node: Node){
        self.children.append(node)
        node.parent = self
    }
    
}

class CategorieTree{
    let root: Node
    var iterator: Node
    
    init(root:Node) {
        self.root = root
        self.iterator = root
    }
}

class CategorieModel{
    var data: [Category] = []
    var tree: CategorieTree = CategorieTree(root: Node(category: Category(has_subCategories: true, id: 0, image: "", name: "root",products: [])))
    
    var searchData:[Product] = []
    var urlSearch:String = "https://thegreenmarket.tk/api/products"
    var searchParams: [String:String] = ["fromItem":"0","itemsQuantity":"50","filterName":""]
    
    var searHistory:[String] = []
    var searchOriginalHistory:[String] = []
    
    var urlCategories: String = "https://thegreenmarket.tk/api/categories"
    var urlHeaderPathCategories:[String] = []
    
    func setSearchParams(fromItem:String, itemsQuantity:String, filterName:String){
        searchParams["fromItem"] = fromItem
        searchParams["itemsQuantity"] = itemsQuantity
        searchParams["filterName"] = filterName
    }
    
    func getTreeIterator() -> Node{
        return tree.iterator
    }
    
    func getChild(child: Int) -> Node {
        
        for node in tree.iterator.children{
            if node.category.id == child{
                return node
            }
        }
        return tree.iterator.children[child]
    }
    
    func getDataIndexPath() -> [IndexPath]{
        var indexPath = [IndexPath]()
        for i in data.indices{
            let index = IndexPath(row: i, section: 0)
            indexPath.append(index)
        }
        return indexPath
    }
    
    
    func getDataCount() -> Int{
        return data.count
    }
    
    func setURLHeaderPath(urlHeaderPath:[String]){
           self.urlHeaderPathCategories = urlHeaderPath
    }
    
    func refreshData(){
        data = []
        for node in tree.iterator.children {
            self.data.append(node.category)
        }
    }
    
    func cleanData(){
        tree.iterator.children = []
    }
    
    func addNodeChild(node: Node){
        tree.iterator.addChild(node: node)
    }
    
    func moveToParent(){
        self.tree.iterator = (tree.iterator.parent)!
    }
    
    func moveToChild(child: Int){
        for node in self.tree.iterator.children{
            if node.category.id == child{
                self.tree.iterator = node
            }
        }
    }
}
