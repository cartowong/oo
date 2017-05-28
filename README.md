# oo
An R package to provide an object-oriented framework for R programming.

## Package description
This package allows one to implement object-oriented design in R. One may define classes, add getters and setters, extend a class, and override methods. This framework is compatible with code completion if the IDE supports it.

## How to install and load this package?
Run the following R script.

```
install.packages('devtools') # may skip this line if you already have devtools installed
library(devtools)
install_github('cartowong/oo')
library(oo)
```

## Example
This package provides two functions `Object()` and `finalizeObject(object, publicMethodNames)`.

The function `Object()` should be called at the begining of a constructor function to create an object. Any object has the methods "get", "getPrivate". "set", "setPrivate", "ls", "addMethod", and "overrideMethod". These methods can be accessed through the dollar sign notation.

The function `finalizeObject(object, publicMethodNames)` should be called at the end of a constructor function to finalize an object. This will register all public methods for the object so that they can be accessed through the dollar sign notation. Moreover, the `getPrivate` and `setPrivate` methods will be removed so that private fields can only be accessed within the body of the constructor function.

After installing and loading the package, you may access the help info by running, for example, `?Object`. Below we provide an example for how you may use these two functions to create and to extend a class.

```
# Constructor.
Person <- function(name, age) {

  # object to return
  person <- Object()

  # public field
  person$set('name', name)

  # private field
  person$setPrivate('age', age)

  # getter
  person$addMethod('getName', function() {
    person$get('name')
  })

  # setter
  person$addMethod('setName', function(value) {
    person$set('name', value)
  })

  # This method refers to the private field age. The 'getPrivate' function will be removed
  # at the end of this constructor by the 'finalizeObject' function. So, the private field
  # age is not accessible outside this constructor.
  person$addMethod('isOver18', function() {
    person$getPrivate('age') > 18
  })

  # Note that this method calls getName(). If a subclass overrides getName(),
  # calling this method from an instance of the subclass will call the overriden
  # version of getName().
  person$addMethod('sayHi', function() {
    print(sprintf('Hi, my name is %s.', person$get('getName')()))
  })

  finalizeObject(person, c('getName', 'setName', 'isOver18', 'sayHi'))
}

# Constructor. (This class extends Person.)
Student <- function(name, age, studentID) {

  # object to return
  student <- Person(name, age)

  # public field
  student$set('studentID', studentID)

  # override
  student$overrideMethod('getName', function(parentMethod) {
    toupper(parentMethod())
  })

  finalizeObject(student, c())
}

peter <- Person('Peter', 12)
print(peter$getName())    # Peter
print(peter$get('name'))  # Peter
print(peter$isOver18())   # FALSE

peter$setName('Peter Pan')
print(peter$getName())    # Peter Pan
print(peter$get('name'))  # Peter Pan

peter$sayHi()             # Hi, my name is Peter Pan.

amy <- Student('Amy', 22, 987)
print(amy$getName())      # AMY
print(amy$get('name'))    # Amy
print(amy$isOver18())     # TRUE

amy$setName('Amy Chan')
print(amy$getName())      # AMY CHAN
print(amy$get('name'))    # Amy Chan

amy$sayHi()               # Hi, my name is AMY CHAN.
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
