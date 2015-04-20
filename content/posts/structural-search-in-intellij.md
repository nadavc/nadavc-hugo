+++
date = "2015-04-19T00:44:37-07:00"
draft = false
title = "IntelliJ Gem: Structural Search"

+++

As an engineer, I've always been obsessed with productivity and efficiency. I frequently experiment with new tools and methodologies and try to find what works best for me. The IDE is no exception... and out of everything that's out there, IntelliJ is hard to beat.

One of the hidden (and [hardly](https://www.jetbrains.com/idea/help/structural-search-and-replace.html) documented) gems in IntelliJ is the structured search. In a sentence, it allows you to leverage IntelliJ's understanding of code to perform complex search and replace scenarios. There are lots of cool usages for this - although the real power hides under the `Script constraints` section.  

## Finding usages in annotated classes ##

Some might say that the controller layer should not access the data layer directly. How would you search for these instances? Structured search makes it easy. In this example, we're searching for all classes that are annotated with `@Controller` and have a private member that is (*or inherits from*) a type that contains "Repo":

![ss1 code](/imgs/ss1_code.png)

![ss1 annotation](/imgs/ss1_annotation.png)

![ss1 type](/imgs/ss1_type.png)

## Finding candidates for God objects ##

Every legacy code ends up suffering from the `God object` code smell. Classes with a large number of methods are very likely to fall into this category. Here's how it's done with structural search.

![ss2 code](/imgs/ss2_code.png)

![ss2 code](/imgs/ss2_methodname.png)


## Finding inefficient log statements ##

SLF4J recommends we use [parameterized](http://www.slf4j.org/faq.html#logging_performance) log entries to improve efficiency. How do we find log entries that use concatenation? Enter `Script constraints`:

![ss3 code](/imgs/ss3_code.png)

![ss3 logger](/imgs/ss3_logger.png)

![ss3 call](/imgs/ss3_call.png)

![ss3 params1](/imgs/ss3_firstparam_top.png)

![ss3 params2](/imgs/ss3_firstparam_bottom.png)

## Wait... what? ##

IntelliJ's help states the following:

> Script constraints are used when items to search for are more than a plain match. If you are looking for certain language constructs (for example, constructors with the specified number of parameters, or members with the specified visibility modifiers), apply constraints described as Groovy scripts.

Granted, this leaves something to be desired. In essence, when `Script constraints` is enabled, IntelliJ executes the Groovy script against the variable that was found (in this case, `$FirstParam$`). If the script evaluates to [true](http://www.groovy-lang.org/semantics.html#Groovy-Truth), the condition is met. As you might have guessed, the expression is passed to the Groovy code as `__context__`.

The type of `__context__` depends on the variable in question, although it will always be one of IntelliJ's internal `Program Structure Interface (PSI)` types. For me, the easiest way to find this out was to output the class name to a file while evaluating the Groovy script:

```groovy
new File("/Users/user/filetype.txt").append(__context__.class.canonicalName)

```

Finally, going back to our example, in order to find non-parameterized log statements, we are looking for statements that include a non-literal expression. Anything other than a literal expression (effectively a regular string) would be considered inefficient, as it would force string concatenation for all log statements.


Here are some links for more information about the different types of PsiExpressions:

* [PSI Cookbook](https://confluence.jetbrains.com/display/IDEADEV/PSI+Cookbook)
* [Viewing PSI Structure](https://www.jetbrains.com/idea/help/viewing-psi-structure.html)
* [IntelliJ source code](https://github.com/JetBrains/intellij-community)
