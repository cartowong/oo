# oo
An R package to provide an object-oriented framework for R programming.

## Package description
This package allows one to implement object-oriented design in R. One may define classes, add getters and setters, extend a class, and override methods. This framework is compatible with code completion if the IDE supports it.

## How to install and load this package?
Run the following R script.

```
install.packages('devtools') # may skip if you already have devtools installed
library(devtools)
install_github('cartowong/oo')
library(oo)
```

## Example
This package provides two functions `Object()` and `registerMethods(object, methodNames)`. After installing and loading the package, you may access the help info by running, for example, `?Object`. Below we provide an example for how you may use these two functions.

```
# Constructor.
Person <- function(name) {

  # object to return
  person <- Object()

  # name of the person
  person$set('name', name)

  # getter (will be overridden by the subclass Student)
  person$addMethod('getName', function() {
    person$get('name')
  })

  # setter
  person$addMethod('setName', function(value) {
    person$set('name', value)
  })

  # Note that this method calls getName(). If a subclass overrides getName(),
  # calling this method from an instance of the subclass will call the overriden
  # version of getName().
  person$addMethod('sayHi', function() {
    print(sprintf('Hi, my name is %s.', person$get('getName')()))
  })

  # Register the methods so that they can be accessed using the dollar sign notation.
  # Note that this allows code completion if the IDE supports it.
  registerMethods(person, c('getName', 'setName', 'sayHi'))
}

# Constructor. (This class extends Person.)
Student <- function(name, studentID) {

  # object to return
  student <- Person(name)

  # Student ID. (Note that the name is inherited from the super class Person.)
  student$set('studentID', studentID)

  # override
  student$overrideMethod('getName', function(parentMethod) {
    toupper(parentMethod())
  })

  # no new methods to register
  student
}

peter <- Person('Peter')
print(peter$getName())

peter$setName('Peter Pan')
print(peter$getName())

peter$sayHi()

amy <- Student('Amy', 12)
print(amy$getName())

amy$setName('Amy Chan')
print(amy$getName())

amy$sayHi()
```

Output:

```
[1] "Peter"
[1] "Peter Pan"
[1] "Hi, my name is Peter Pan."
[1] "AMY"
[1] "AMY CHAN"
[1] "Hi, my name is AMY CHAN."
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
peter <- Person('Peter')
setName <- function(person, newName) {
  person$setName(newName)
}
setName(peter, 'Peter Pan')
print(peter$getName()) # prints 'Peter Pan' (setName works)
```
