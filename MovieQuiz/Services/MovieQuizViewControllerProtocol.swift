//
//  MovieQuizControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nikolay Krivtsov on 04.01.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func areButtonsEnabled(statement: Bool)
    
    func show(quiz step: QuizStepViewModel)
    
    func show(quiz result: QuizResultViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func showNetworkError(message: String) 
}
