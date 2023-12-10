//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolay Krivtsov on 04.01.2024.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    
    let questionAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    lazy var statisticService: StatisticServiceProtocol = StatisticServiseImplementation()
    var questionFactory: QuestionFactoryProtocol?
    
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.yesButton.isEnabled = true
        viewController?.noButton.isEnabled = true
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionAmount)
            let bestGame = statisticService.bestGame
            let text =
            "Ваш результат: \(correctAnswers)/\(self.questionAmount)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let viewModel = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
}
