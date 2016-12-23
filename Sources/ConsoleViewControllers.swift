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
 * Here some usefull types:
 *
 *   Parser:     A function from String to a generic optional
 *   Completer:  A function from an optional to nothing
 */
public typealias Parser <A> = (String) -> A?
public typealias Completer <A> = (A) -> ()

/*
 * ConsoleViewController
 *
 * This emulate an UIViewController in a terminal, and it was generic over type A.
 * It will require a text to display, a function to convert the input to an optional A
 * and a function that will be executed if the convertion succeeded.
 *
 * Properties:
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
    let text: String
    let parse: Parser<A>
    let onComplete: Completer<A>
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
 * Properties:
 *
 * - title: String                 The title of the ConsoleNavigationViewController (default: "")
 *
 * - animationDuration: UInt32     The push/pop animation duration (default: 2 seconds)
 *
 * - viewControllers: [ConsoleViewControllerProtocol]
 *                                 An array containing the stack of ConsoleViewController present into
 *                                 the navigation
 *
 * - topViewController: ConsoleViewControllerProtocol?
 *                                 Return (if present) the first element of the ConsoleViewController stack
 *
 * - visibleViewController: ConsoleViewControllerProtocol?
 *                                 Return (if present) the last element of the ConsoleNavigationController stack.
 *                                 This is the View Controller that will be executed during the
 *                                 ConsoleNavigationViewController execution
 *
 * Methods:
 *
 * - execute()            Display, if available, the ConsoleNavigationViewController title and a separator, then
 *                        call the execute method of the visible ConsoleViewControlled.
 *
 * - pushViewController(_:ConsoleViewControllerProtocol, animated:Bool)
 *                        This will add a new <ConsoleViewControllerProtocol> to the stack, then execute it.
 *                        If animated was true, then wait before pushing it (see animationDuration property).
 *
 * - popViewController(animated: Bool)
 *                        This will remove the last <ConsoleViewControllerProtocol> from the stack, then execute
 *                        the previous one (if available).
 *                        If animated was true, then wait before pushing it (see animationDuration property).
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
    var title: String = ""
    var animationDuration: UInt32 = 2
    var viewControllers: [ConsoleViewControllerProtocol] = []
    var topViewController: ConsoleViewControllerProtocol? {
        get {
            return viewControllers.first
        }
    }
    var visibleViewController: ConsoleViewControllerProtocol? {
        get {
            return viewControllers.last
        }
    }
}
public extension ConsoleNavigationViewController {
    mutating func pushViewController (_ vc: ConsoleViewControllerProtocol, animated: Bool) {
        if animated { sleep(animationDuration) }
        viewControllers.append(vc)
        execute()
    }

    mutating func popViewController (animated: Bool) {
        if viewControllers.count == 0 { return }
        if animated { sleep(animationDuration) }
        viewControllers.removeLast()
        execute()
    }

    func execute () {
        guard let visible = visibleViewController else { return }
        if title != "" {
            print(" \(title)\n---------------")
        }
        visible.execute()
    }
}

/*
 * AppDelegate
 *
 * A simple way to orchestrate multiple viewControllers execution. This will works with
 * any struct which conforms to ConsoleViewControllerProtocol
 *
 * Properties:
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
 * var navVC = ConsoleNavigationViewController(viewControllers: [ageVC])
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