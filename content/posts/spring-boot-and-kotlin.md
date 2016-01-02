+++
date = "2016-01-01T00:00:00-08:00"
title = "Spring Boot and Kotlin"
+++

I've recently had the pleasure of trying out [Kotlin](http://kotlinlang.org) for a few projects at work. It's a promising JVM language from [JetBrains](http://jetbrains.com) that includes a lot of functional elements and a strong type system. I'm told it's a combination of the best features of [Scala](http://www.scala-lang.org/) and [Groovy](http://www.groovy-lang.org/).

### Does it work with Spring?

JetBrains promises 100% interoperability with Java, but it's not immediately obvious how to get all the pieces working together. In this post I will outline some gotchas when building a Spring Boot "Hello World". For the impatient, there's a fully working example at the end.

### Running bootRun from Gradle

The `bootRun` task requires a `public static void main(String[] args)` method on the `@SpringBootApplication` annotated class. Kotlin does not have static class methods, but [companion objects](https://kotlinlang.org/docs/reference/object-declarations.html#companion-objects) work just as well:

```java
@SpringBootApplication
open class App {

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }

}
```

Note that the class must also be marked `open` and include the `@JvmStatic` annotation on the companion object.

### Dependency Injection (autowiring)

Generally speaking, dependency injection can be done via fields, constructor, and setters.

Field injection is relatively straightforward. The one caveat is to use the `lateinit` keyword, as Kotlin does not allow late initialization by default.

```java
class SampleController {
   @Autowired
   lateinit var sampleService: SampleService
 }
```

Constructor-based injection is done via Kotlin's primary constructors. Note the addition of `constructor` in the class header:

```java
class SampleController @Autowired constructor(val sampleService: SampleService) {
}
```
Setter-based injection can be done, but I wasn't able to make it work with custom setters, which makes it a little useless anyway. Here's the Kotlin syntax:

```java
class SampleController {
    lateinit var sampleService: SampleService
       @Autowired set
}
```

### Logger initialization

Logger initialization (such as SLF4J) is usually done with `LoggerFactory#getLogger(Class<?> clazz)`. To get the Java class for your Kotlin class, you'd need to use `::class.java`:

```java
val logger = LoggerFactory.getLogger(SampleController::class.java)
```

### Jackson deserialization

Spring Boot uses Jackson to serialize and deserialize Java objects into Json and back. Serialization works as expected, but in order to get deserialization to work, you'd need to include the [Jackson Kotlin Module](https://github.com/FasterXML/jackson-module-kotlin). In addition to adding its dependencies in `build.gradle`, you would also need to add the `KotlinModule` as a `@Bean`:

```java
@SpringBootApplication
open class App {

  @Bean
  open fun kotlinModule() = KotlinModule()

}
```

### All together now

To see everything working together, please check out the example on GitHub at https://github.com/nadavc/nadavc-blog-code/tree/master/kotlin-boot

### Great Kotlin resources

* [Kotlin Koans](http://try.kotlinlang.org/#/Kotlin%20Koans)
* [Functional Kotlin](https://www.youtube.com/watch?v=AhA-Q7MOre0)
* [Kotlin Reference](https://kotlinlang.org/docs/reference/)
