import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    private var correctAnswers = 0
    lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    private lazy var statisticService: StatisticServiceProtocol = StatisticServiseImplementation()
    private var currentQuestion: QuizQuestion?
    private let alertPresenter = AlertPresenter()
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        self.view.backgroundColor = UIColor.ypBlack
        questionFactory.delegate = self
        showLoadingIndicator()
        questionFactory.loadData()
        presenter.viewController = self
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory.requestNextQuestion()
        }
        
        alertPresenter.show(quiz: model)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true //
        questionFactory.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            if isCorrect {
                correctAnswers += 1
            }
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionAmount)
            let bestGame = statisticService.bestGame
            let text =
            "Ваш результат: \(correctAnswers)/\(presenter.questionAmount)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let viewModel = QuizResultViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
        }
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alert = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: {
                [weak self]  in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        )
        
        alertPresenter.viewController = self
        alertPresenter.show(quiz: alert)
    }
}

