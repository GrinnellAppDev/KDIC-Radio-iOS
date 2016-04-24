//
//  Article.swift
//  KDIC
//
//  Created by Shaun Mataire on 4/24/16.
//  Copyright © 2016 Colin Tremblay. All rights reserved.
//

import Foundation


class Article{
    var articleTitle: String
    var author: String
    var datePosted: String
    var articleText: String
    var articleUrl: String
    
    
    init(_ articlesArray: Dictionary<String, String>){
        
        self.articleTitle = articlesArray["articleTitle"]!
        self.author = articlesArray["author"]!
        self.datePosted = articlesArray["datePosted"]!
        self.articleText = articlesArray["articleText"]!
        self.articleUrl = articlesArray["articleUrl"]!
    }
}