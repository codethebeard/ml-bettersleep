//
//  ViewController.swift
//  BetterTest
//
//  Created by Michael VanDyke on 9/28/19.
//  Copyright © 2019 Michael VanDyke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var wakeUpTime: UIDatePicker!
    var sleepAmountTime: UIStepper!
    var sleepAmountLabel: UILabel!
    
    var coffeeAmountStepper: UIStepper!
    var coffeeAmountLabel: UILabel!
    
    override func loadView() {
        // New up the view.
        view = UIView()
        view.backgroundColor = .white
        
        // Create the stack view
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        let wakeUpTitle = UILabel()
        wakeUpTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpTitle.text = NSLocalizedString("When do you want to wake up?", comment: "Wake Up Title")
        mainStackView.addArrangedSubview(wakeUpTitle)
        
        // Setup wake up picker
        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 15
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()
        mainStackView.addArrangedSubview(wakeUpTime)
        
        // Sleep Title
        let sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = NSLocalizedString("What's the minimum amount of sleep you need?", comment: "Sleep title")
        mainStackView.addArrangedSubview(sleepTitle)
  
        sleepAmountTime = UIStepper()
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChanged), for: .valueChanged)
        sleepAmountTime.stepValue = 0.25
        sleepAmountTime.value = 8
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 12
        
        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        sleepAmountLabel.text = "\(sleepAmountTime.value) hours"
        
        let sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)
        
        let coffeeTitle = UILabel()
        coffeeTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitle.numberOfLines = 0
        coffeeTitle.text = NSLocalizedString("How much coffee do you drink each day?", comment: "Coffee Title")
        mainStackView.addArrangedSubview(coffeeTitle)
        
        coffeeAmountStepper = UIStepper()
        coffeeAmountStepper.addTarget(self, action: #selector(coffeeAmountChanged), for: .valueChanged)
        coffeeAmountStepper.minimumValue = 1
        coffeeAmountStepper.maximumValue = 20
        coffeeAmountStepper.stepValue = 1
        coffeeAmountStepper.value = 1
        
        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        coffeeAmountLabel.text = "\(coffeeAmountStepper.value) cup"
        
        let coffeeStackView = UIStackView()
        coffeeStackView.spacing = 20
        coffeeStackView.addArrangedSubview(coffeeAmountStepper)
        coffeeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeeStackView)
        
        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Better Rest"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate", style: .plain, target: self, action: #selector(calculateBedtime))
    }
    
    
    @objc func sleepAmountChanged() {
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }

    @objc func coffeeAmountChanged() {
        if coffeeAmountStepper.value == 1 {
            coffeeAmountLabel.text = "1 cup"
        } else {
            coffeeAmountLabel.text = "\(Int(coffeeAmountStepper.value)) cups"
        }
    }
    
    @objc func calculateBedtime() {
        let model = SleepCalculator()
        
        let title: String
        let message: String
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            let hour = (components.hour ?? 0) * 60 * 60 // Wakeup hour in seconds.
            let minute = (components.minute ?? 0) * 60 // Wakeup minutes in seconds.
            
            let prediction = try model.prediction(coffee: coffeeAmountStepper.value, estimatedSleep: sleepAmountTime.value, wake: Double(hour + minute))
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)
            title = "Your ideal bedtime is..."
        } catch {
            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}

