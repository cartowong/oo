# oo
An R package to provide an object-oriented framework for R programming.

## Updates

* version 5.4 (July 15, 2017): Move the boolean argument `hidePassed` of `UnitTester$runAllTests` to the constructor of `UnitTester`.
* version 5.31 (July 15, 2017): Minor code change.
* version 5.3 (July 15, 2017): Add a boolean argument `hidePassed` to `UnitTester$runAllTests()`.
* version 5.2 (July 14, 2017): Fix a subtle bug to make sure a private field/method cannot be overriden by defining/adding a public field/method with the same name in a subclass.
* version 5.1 (July 14, 2017): Add unit tests and make minor code change.
* version 5.0 (July 14, 2017): Add object methods `define`, `definePrivate` and remove object method `setPrivate`. As of version 5.0, the method `set` determines whether the field is accessible.
* version 4.21 (July 14, 2017): Minor code change.
* version 4.2 (July 13, 2017): Throw an error when `object$set(key, value)` is called and a private field with the same key already exists. Similarly, throw an error when `object$setPrivate(key, value)` is called and a public field with the same key already exists.
* version 4.1 (July 11, 2017): `Object$addMethod` and `Object$overrideMethod` are not accessible after `Object$finalize` is called (and until `Object$extend` is called). `Object$overrideMethod` is only accessible after `Object$extend` is called (and until `Object$finalize` is called).
* version 4.0 (July 11, 2017): Precondition and TypeChecker are now objects.
* version 3.2 (July 10, 2017): `Object$set(key, value)` and `Object$setPrivate(key, value)` return the key.
* version 3.11 (July 10, 2017): Minor code change.
* version 3.1 (July 9, 2017): Fix bugs in UnitTester and add examples to its R documentation.
* version 3.0 (July 4, 2017): Add TypeChecker, Precondition, and UnitTester.
* version 2.0 (June 30, 2017): Add 'this' keyword. When adding or overriding a method, the 'this' object now has all the public and private methods registered. Fix a bug where a subclass cannot have its own private fields/methods. 
* version 1.0 (May 20, 2017): Initial version.

## Package description
This package allows one to implement object-oriented designs in R. With this package, you may do the following.

* Create a constructor function for a class with public or private fields and methods. Private fields and private methods are only accessible within the body of the constructor.
* Extend a class and override its public methods. The overriden method may call its parent method.
* When an object is passed to a function as an argument, it behaves as if the object is passed by reference (instead of by value).
* Utility functions to check and validate the type of function arguments.
* Add unit tests to your project.

The public methods of an object can be referenced using the dollar sign notation. If your IDE supports code completion, method names will be auto-completed.

## How to install and load this package?
Run the following R script.

```
install.packages('devtools') # may skip this line if you already have devtools installed
library(devtools)
install_github('cartowong/oo')
library(oo)
```
## Basic pattern
This package provides a function `Object()` as the starting point of object-oriented programming. Any instance of `Object` has the following properties attached.

* define<br/>Define a public field.
* definePrivate<br/>Define a private field.
* get<br/>This can be used to retrieve the value of a field. If it is called within the body of a method (probably through the `this` keyword, e.g. `this$get('name')`), both public and private fields are accessible. Otherwise, only public fields are accessible.
* set<br/>This can be used to set the value of a field. If it is called within the body of a method (probably through the `this` keyword, e.g. `this$get('name')`), both public and private fields are accessible. Otherwise, only public fields are accessible.
* fieldNames<br/>List out the names of all public fields.
* methodNames<br/>List out the names of all public methods.
* addMethod<br/>Add a **public** method to the current object.
* addPrivateMethod<br/>Add a **private** method to the current object.
* extend<br/>Create a copy of the current object which shares the same public fields/methods but has a separate set of private fields/methods.
* overrideMethod<br/>Override a public method of the super class.
* finalize<br/>This should be called at the end of a constructor.

Here is the recommended pattern.

```
#' Constructor of the class Person.
#'
#' @param name the name of the person
#' @param age  the age of the person
#' @return an instance of Person
Person <- function(name, age) {

  Precondition()$checkIsString(name, 'name should be a string')
  Precondition()$checkIsNumeric(age, 'age should be numeric')

  # object to return
  person <- Object()

  # public field
  nameKey <- person$define('name', name) # nameKey = 'name'

  # private field
  ageKey <- person$definePrivate('age', age) # ageKey = 'age'

  # getter
  person$addMethod('getName', function(this) {
    this$get(nameKey) # same as this$get('name')
  })

  # private getter
  person$addPrivateMethod('getAge', function(this) {
    this$get(ageKey) # same as this$get('age')
  })

  # setter
  person$addMethod('setName', function(this, value) {
    this$set(nameKey, value) # same as this$set('name', value)
  })

  # This method refers to the private field age.
  person$addMethod('isOver18', function(this) {
    this$get(ageKey) > 18
  })

  # Note that this method calls getName(). If a subclass overrides getName(),
  # calling this method from an instance of the subclass will call the overriden
  # version of getName().
  person$addMethod('sayHi', function(this) {
    sprintf('Hi, my name is %s.', this$getName())
  })

  # Register public methods and remove private setters.
  person$finalize()
}
```

One may then use the above constructor function to create instances of the Person class. Public methods can be called using the dollar sign notation. Note that the `setPrivate` method is not accessible outside the constructor, and the `get` method does not return any private field at this point.

```
peter <- Person('Peter', 12)
print(peter$get('name'))  # Peter
print(peter$getName())    # Peter
print(peter$isOver18())   # FALSE

peter$setName('Peter Pan')
print(peter$get('name'))  # Peter Pan
print(peter$getName())    # Peter Pan

peter$sayHi()             # Hi, my name is Peter Pan.
```

The method `methodNames` returns the names of all public methods.

```
> peter$methodNames()
[1] "getName"  "isOver18" "sayHi"    "setName" 
```

## TypeChecker and Precondition

These are two sets of utility functions added since version 3.0. They could be used to check and validate the type of function arguments. As of version 3.0, TypeChecker consists of 6 functions.

* isNA(x)
* isNull(x)
* isBoolean(x)
* isFunction(x)
* isNumeric(x)
* isString(x)

Each of these functions returns a boolean (logical) indicating whether or not the given argument is of the expected type. Unlike, for example, is.numeric in the base package, the function isNumeric in TypeChecker checks whether the given object is a single numeric value. A vector of two numeric values is not considered as numeric type. Conceptually, its type is vector whose element type happens to be numeric.

Precondition is a set of utility functions based on TypeChecker. If the argument is not of the expected type, an error will be thrown. Usually, these utility functions are called at the begining of a function body to validate the arguments.

```
precondition <- Precondition() # By default, allowNA = FALSE and allowNull = FALSE.
myFunction <- function(x) {
  precondition$isNumeric(x, 'x should be numeric')
  ...
}
```

## Inheritance
Extending a class is similar to defining a class except for two differences.

1. At the begining of a constructor, we call the super class constructor instead of calling `Object()`, and we call `extend()`.
2. Use the function `overrideMethod` to override a super class method. The special arguments `this` and `parentMethod` are optional and could be omitted it you do not need them.

```
#' Constructor of the class Student.
#'
#' The Student class extends the Person class.
#'
#' @return an instance of Student
Student <- function(name, age, studentID) {

  Precondition()$checkIsString(name, 'name should be a string')
  Precondition()$checkIsNumeric(age, 'age should be numeric')
  Precondition()$checkIsString(studentID, 'studentID should be a string')

  # object to return
  student <- Person(name, age)$extend()

  # private field
  studentIDKey <- student$definePrivate('studentID', studentID) # studentIDKey = 'studentID'

  # add private method
  student$addPrivateMethod('getStudentID', function(this) {
    this$get(studentIDKey) # same as this$get('studentID')
  })

  # add public method
  student$addMethod('hiddenStudentID', function(this) {
    id <- this$getStudentID()
    gsub(pattern = ".", replacement = "x", x = as.character(id))
  })

  # override
  student$overrideMethod('getName', function(this, parentMethod) {
    toupper(parentMethod())
  })

  student$finalize()
}
```

The class Student inherits all public methods from Person. Note that Student overrides the method `getName()` to use uppercase letters and the method `sayHi()` inherited from Person calls `getName()`. Therefore, calling `sayHi()` from an instance of Student would have the name in uppercase. This is the expected behavior in object-oriented programming.

```
amy <- Student('Amy', 22, '987')
print(amy$getName())      # AMY
print(amy$get('name'))    # Amy
print(amy$isOver18())     # TRUE

amy$setName('Amy Chan')
print(amy$getName())      # AMY CHAN
print(amy$get('name'))    # Amy Chan

amy$sayHi()               # Hi, my name is AMY CHAN.
```

## Using `this` and `parentMethod`

When you call `addMethod` or `overrideMethod`, the second argument is a function object f. In the argument list of f, you could choose to add the special arguments `this` or `parentMethod` (if you are overriding a method). This allows you to reference to the current object and the parent method within the body of f. Note that these two named function arguments are optional. You do not need to add them into the argument list if you do not use them in the function body.

## Private read-only fields
An object may have private read-only fields. In the example below, the field `count` of the `Counter` object is private read-only. It is private since it cannot be accessed after the `Counter` object is created. It is read-only in the sense that methods of `Counter` are not able to change its value.

```
# Constructor of the class Counter
#
# @return an instance of Counter
Counter <- function() {

  # object to return
  counter <- Object()

  # private read-only field
  count <- 0

  # getter
  counter$addMethod('getCount', function() {
    count
  })

  # This method tries to add 1 to the private read-only field. It won't work.
  counter$addMethod('addCount', function() {
    count <- count + 1
  })

  counter$finalize()
}

counter <- Counter()
print(counter$getCount()) # 0

counter$addCount()
print(counter$getCount()) # 0
```

## Passing objects by references
In R function arguments are passed by values instead of by references. To illustrate this, the function `setValue` below fails to change the value of `obj`. This is because the value of `obj` is copied and is assigned to the symbol `o` at the beginning of the function execution.

```
obj <- list(value = 1)
setValue <- function(o, newValue) {
  o$value <-newValue
}
setValue(obj, 2)
print(obj$value) # prints 1 (setValue does not work)
```

What if we remove the function argument? The function `setValue1` also fails to change the value of `obj`. When `setValue1` is executed, it needs to resolve the symbol `obj`. Since `obj` is not defined in the function body, R looks it up in the defining environment of `setValue1` and finds it. However, the value is also copied and the symbol `obj` within the function body of `setValue1` refers to the copied object.

```
obj <- list(value = 1)
setValue1 <- function(newValue) {
  obj$value <-newValue
}
setValue1(2)
print(obj$value) # prints 1 (setValue1 does not work either)
```

Using this package, we could mimic it as if objects are passing by references. For those who are curious about what happens behind the scenes, the symbol `person` within the function body of `setName` refers to a copy of the person object which shares the same local environment with the original person object.

```
peter <- Person(name = 'Peter', age = 12)
setName <- function(person, newName) {
  person$setName(newName)
}
setName(peter, 'Peter Pan')
print(peter$getName()) # prints 'Peter Pan' (setName works)
```

## Adding unit tests

The object `UnitTester` provides 2 methods for adding and running unit tests, and 7 assertion methods.

* addTest
* runAllTests
* assertEqual
* assertFalse
* assertNA
* assertNotThrow
* assertNull
* assertThrow
* assertTrue

The constructor of `UnitTester` has two arguments.

* turnWarningsToErrors (default = TRUE)<br/>If set to TRUE, all warnings issued within any test method are turned into errors.
* hidePassed (default = FALSE)<br/>If set to TURE, all passed test results will be hidden in the output. This is useful when you are only interested in the failed assertions and the unexpected errors.

To illustrate the usage of UnitTester, the following are some example unit tests and the output of `runAllTests()`.

```
unitTester <- UnitTester(turnWarningsToErrors = TRUE, hidePassed = FALSE)

unitTester$addTest('Test 1', function() {
  unitTester$assertEqual(1, 1)
  stop('Error from Test 1')
})

unitTester$addTest('Test 2', function() {
  unitTester$assertEqual(1, 1)
})

unitTester$addTest('Test 3', function() {
  unitTester$assertEqual(1, 2)
})

unitTester$addTest('Test 4', function() {
  unitTester$assertEqual(c(1, 2, 3), c(1, 2, 3))
})

unitTester$addTest('Test 5', function() {
  unitTester$assertEqual(c(1, 2, 3), c(1, 3, 3))
})

unitTester$addTest('Test 6', function() {
  unitTester$assertThrow(function() {
    stop('Error from Test 6')
  })
})

unitTester$addTest('Test 7', function() {
  unitTester$assertThrow(function() {
    # This function does not throw any error.
  })
})

unitTester$runAllTests()
```

```
Test 1
Passed: expect = <1> and actual = <1>.

Test 1
Error: Error in testMethod(): Error from Test 1

Test 2
Passed: expect = <1> and actual = <1>.

Test 3
Failed: expect = <1> and actual = <2>.

Test 4
Passed: expect = <1,2,3> and actual = <1,2,3>.

Test 5
Failed: expect = <1,2,3> and actual = <1,3,3>.

Test 6
Passed: assertThrow successfully caught an error <Error in f(): Error from Test 6>.

Test 7
Failed: assertThrow did not catch any error.

Number of passed assertions: 4
Number of failed assertions: 3
Number of unexpected errors: 1
```
