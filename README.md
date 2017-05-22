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

## Mutate an object

An R function cannot mutate an object in the outside environment through simple assignment (<-). To illustrate this point, the function `setValue` below fails to change the value of `obj`. By creating an object using this package, the function `setName` below successfully changes the name of the person object.

```
obj <- list(value = 1)
setValue <- function(newValue) {
  obj$value <-newValue
}
setValue(2)
print(obj$value) # prints 1 (setter does not work)

peter <- Person('Peter')
setName <- function(newName) {
  peter$setName(newName)
}
setName('Peter Pan')
print(peter$getName()) # prints 'Peter Pan' (setter works)
```

Note that we obtain the same result if `obj` and `peter` are passed to `setValue` and `setName` as arguments.

```
obj <- list(value = 1)
setValue <- function(o, newValue) {
  o$value <-newValue
}
setValue(obj, 2)
print(obj$value) # prints 1 (setter does not work)

peter <- Person('Peter')
setName <- function(person, newName) {
  person$setName(newName)
}
setName(peter, 'Peter Pan')
print(peter$getName()) # prints 'Peter Pan' (setter works)
```
