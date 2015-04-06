+++
date = "2015-04-04T00:00:00-07:00"
draft = true
title = "Diving Into Gradle Internals"

+++


# THIS IS STILL A DRAFT. I CAN'T GET MY HEAD AROUND HOW GRADLE COMPILES AND EVALUATES THE FILES YET. NEED TO UNDERESTAND ASM AND AST TRANSFORMATIONS BETTER #

I've always been a big fan of Gradle, but I've only recently realized that some of the [DSL][Groovy DSL] magic doesn't quite map to my understanding of Groovy delegates. This weekend I decided to put an end to this mystery and really see how Gradle works from the inside out.

Here's an innocent looking `build.gradle` file that I've used:

```groovy
apply plugin: 'java'

version = '1.0'

repositories {
    jcenter()
}

dependencies {
    testCompile 'junit:junit:4.11'
}

task hello(type: GreeterTask) {
    greeting = 'hola'
}

class GreeterTask extends DefaultTask {

    String greeting = 'hello'

    @TaskAction
    def greet() {
        println "$greeting to you!"
    }

}
```

## Debugging Gradle builds using Gradle source code ##

First, I needed to figure out how to step into Gradle code. After some digging, it turned out to be pretty simple:

1. Git clone Gradle code from [GitHub][Gradle GitHub]
2. Run `$ ./gradlew idea` to generate the IDEA project files
3. Open the `.ipr` file in IDEA (you do have IntelliJ IDEA, right?)
4. Create a new application run configuration and point to the `org.gradle.debug.GradleBuildRunner` class. It's a helper class that allows you to run Gradle as if you run it from the commandline.
5. Alter the params in `GradleBuildRunner` to point to your `build.gradle` file

As a side note, the Gradle source code is a *great* example of how to use the build file to generate a consistent environment for the development team. Check out [idea.gradle][idea.gradle] for more details.

## Stepping through the build phases ##

As you might imagine, the call chain on even a simple Gradle build can become quite complex. I've found that Gradle developers are very fond of the [Decorator pattern], which kind of reminds me of Morpheus when he dared Neo to find out "how deep the rabbit hole goes". Here's the breakdown by logical steps:

1. Initialization of the decorator chain for exception handling, logging, validation, and build actions
2. Gradle parameters are parsed and Gradle decides whether to display help, pop up the [GUI][Gradle GUI] or launch a build (in-process or via the daemon). When a build is ran, a `RunBuildAction` is triggered.
3. We reach `DefaultGradleLauncher#doBuildStages()`, which is where the various build files are loaded, configured, and executed. This is *by far* the most complicated part of the code. This is where
  1. Init scripts are evaluated
  2. Settings script is evaluated against a `DefaultSettings` instance
  3. Build scripts (projects) are loaded as `DefaultProject` and configured
  4. Task graph is built and executed

## Build Stages ##


## Open questions ##

* Stepping through the build phases
* How does `apply plugin` and `version` work? - I'm assuming DefaultProject is simply the delegate when the build.gradle script is ran.
* How do build blocks such as `repositories` and `dependencies` work? - these work through decoration. Need to understand ASM better to see how this works. Somehow delegates to DependencyHandler.
* How does `task name(type: Type)` work? - This goes through a TaskDefinitionScriptTransformer that hooks up to the CompilationUnit. Very deep in AST transformations in Groovy.
* How do plugins get added to Gradle build? - They're addressed in the first compilation/evaluation phase of `DefaultScriptPluginFactory()``

[Groovy DSL]: http://docs.groovy-lang.org/docs/latest/html/documentation/core-domain-specific-languages.html
[Gradle GitHub]: https://github.com/gradle/gradle
[idea.gradle]: https://github.com/gradle/gradle/blob/master/gradle/idea.gradle
[Decorator Pattern]: http://en.wikipedia.org/wiki/Decorator_pattern
[Gradle GUI]: https://gradle.org/docs/current/userguide/tutorial_gradle_gui.html
