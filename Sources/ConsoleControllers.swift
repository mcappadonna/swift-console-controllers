import Foundation

/*
 * ConsoleViewControllerProtocol
 *
 * Just a way to uniform different structs
 */
public protocol ConsoleViewControllerProtocol {
    /*
     * execute()
     *
     * Start the execution of the implemented ConsoleViewController
     */
    func execute()
}

/*
 * ConsoleViewController
 *
 * This emulate an UIViewController in a terminal, and it was generic over type A.
 * It will require a text to display, a function to convert the input to an optional A
 * and a function that will be executed if the convertion succeeded.
 *
 * Parameters:
 *
 * - text: String         The text displayed when the ConsoleViewController will be executed
 * 
 * - parse: String -> A?  A function to parse the String input to the desidered type.
 *                        This function can return a nil if the conversion fail.
 *
 * - onComplete: A -> ()  A function that get the converted value and do something
 *
 * Methods:
 *
 * - execute()            Perform the following operations: display the text variable and
 *                        read the input. Then use the parse function to convert the input
 *                        into the desidered type. If conversion succeeded, execute the
 *                        onComplete function passing the converted value
 *
 * Examples:
 *
 * This is a ConsoleViewController which ask for the age then display the result
 *
 *     let cvc = ConsoleViewController("How old are you?", parse: { return Int($0) }) { age in
 *         print("You're \(age) years old")
 *     }
 *
 * To execute that ConsoleViewController, you must call the execute function:
 *
 *     cvc.execute()
 *
 * You can also concatenate more ConsoleViewController to obtain a flow:
 *
 * let nameVC = ConsoleViewController("What's your name?", parse: { return $0 }) { name in
 *     let ageVC = ConsoleViewController("How old are you?", parse: { return Int($0) }) { age in
 *         print("Hi \(name), you're \(age) years old'")
 *     }
 *     ageVC.execute()
 * }
 * nameVC.execute()
 *
 */
public struct ConsoleViewController <A>: ConsoleViewControllerProtocol {
    var text: String = ""
    var parse: (String) -> A? = { _ in return nil }
    var onComplete: (A) -> () = { _ in }
}
public extension ConsoleViewController {
    // This function execute the viewControllers
    func execute () {
        print(text)
        let string = readLine() ?? ""
        guard let value = parse(string) else { return }
        onComplete(value)
    }
}

/*
 * ConsoleNavigationViewController
 *
 * The best way (I found) to do something like UINavigationController on terminal it's this implementation.
 * This simply contain a ConsoleViewController and a method to execute that. In addition, if you declare it
 * as a variable, you have the pushViewController method which permit to execute some other ConsoleViewController
 * after the execution was done.
 *
 * Parameters:
 *
 * - viewController: ConsoleViewControllerProtocol
 *                        The ConsoleViewController that will be executed
 *
 * Methods:
 *
 * - execute()            Call the execute method of the current ConsoleViewControlled
 *
 * - pushViewController(_:ConsoleViewControllerProtocol, animated:Bool)
 *                        This will replace the current ConsoleViewController and execute it. Setting
 *                        animated to true will introduce a 2 seconds delay (just to be aligned to the
 *                        UINavigationController.pushViewController method Parameters)
 *
 * Examples:
 *
 * This will display a new ConsoleViewController after 2 seconds of waiting
 *
 *     let nameVC = ConsoleViewController(text: "Enter your name:", parse: { return $0 }) {
 *         print("Welcome \(name)")   
 *     }
 *     var navigationVC = ConsoleNavigationController()
 *     navigationVC.pushViewController(nameVC, animated: true)
 *
 */
public struct ConsoleNavigationViewController: ConsoleViewControllerProtocol {
    var viewController: ConsoleViewControllerProtocol
}
public extension ConsoleNavigationViewController {
    mutating func pushViewController (_ vc: ConsoleViewControllerProtocol, animated: Bool) {
        if animated { sleep(2) }
        viewController = vc
        execute()
    }

    func execute () {
        viewController.execute()
    }
}

/*
 * AppDelegate
 *
 * A simple way to orchestrate multiple viewControllers execution. This will work either with
 * ConsoleViewController and ConsoleNavigationController
 *
 * Parameters:
 *
 * - initialViewController: ConsoleViewControllerProtocol?
 *                        The controller that will be executed when the app will start.
 *
 * Methods:
 *
 * - run()                 Call the execute method of the initialViewController
 *
 * Examples:
 *
 * Executing a single ConsoleViewController it's really simple
 *
 *     let nameVC = ConsoleViewController(text: "Enter your name:", parse: { return $0 }) {
 *         print("Welcome \(name)")   
 *     }
 *     let app = AppDelegate(initialViewController: nameVC)
 *     app.run()
 *
 * You can also pass a ConsoleNavigationController. With this, you can execute other view controllers after
 * the run() method call:
 *
 * let ageVC = ConsoleViewController(text: "Enter your age:", parse: { return Int($0) }) { age in
 *     print("You're \(age) years old")
 * }
 * var navVC = ConsoleNavigationViewController(viewController: ageVC)
 *
 * let app = AppDelegate()
 *
 */
public struct AppDelegate {
    var initialViewController: ConsoleViewControllerProtocol?
}
public extension AppDelegate {
    func run() {
        if let vc = initialViewController {
            vc.execute()
        }
    }
}