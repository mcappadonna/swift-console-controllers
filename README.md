# swift-console-controllers
A simple way to work on Console executables like on UIViewController, UINavigationController, etc.

## Inclusion
You can include this Package as a dependency to your Swift package, you must edit the Package.swift file into something like this:

    let package = Package(
        name: "MyCoolSwiftProject",
        targets: [],
        dependencies: [
            .Package(url: "https://github.com/mcappadonna/swift-console-controllers.git",
                     majorVersion: 1),
        ]
    )

The next swift build command will downloads the ConsoleViewControllers module so you can use it in your application.
If you've already built with this version, and you need an update, simply run:

    $ swift package update

To checkout the latest version available on the repository.

## Bug (v1.0.4)
Currently, a strange behaviour with Swift3 on Linux can happen. When you try to use the controllers, for example:

    import Foundation
    import ConsoleViewControllers
    
    let cvc = ConsoleViewController(text: "How old are you?", parse: { return Int($0) }) { age in
        print ("You're \(age) years old")
    }
    cvc.execute()

The compile process will fail with this error:

    error: cannot convert value of type 'Int?' to closure result type '_?'
    let cvc = ConsoleViewController(text: "How old are you?", parse: { return Int($0) }) { age in
                                                                              ^~~~~~~

This doesn't happen if you remove the ConsoleViewControllers import and copy the content of the
Packages/ConsoleViewControllers-1.0.2/Sources/ConsoleViewControllers.swift into your swift file.

I'm working on this, any suggestion will be welcomed.