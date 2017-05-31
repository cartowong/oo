# oo
An R package to provide an object-oriented framework for R programming.

## Package description
This package allows one to implement object-oriented designs in R. With this package, you may do the following.

* Create a constructor function for a class with public or private fields and methods. Private fields and private methods are only accessible within the body of the constructor.
* Extend a class and override its public methods. The overriden method may call its parent method.
* When an object is passed to a function as an argument, it behaves as if the object is passed by reference (instead of by value).

The public methods of an object can be called using the dollar sign notation. If your IDE supports code completion, method names will be auto-completed.

## How to install and load this package?
Run the following R script.

```
install.packages('devtools') # may skip this line if you already have devtools installed
library(devtools)
install_github('cartowong/oo')
library(oo)
```
## Basic pattern
This package provides two functions `Object()` and `finalizeObject(object, publicMethodNames)`. These two functions should be called at the begining and at the end of a constructor function. Here is the recommended pattern.

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
```

One may then use the above constructor function to create instances of the Person class. Public methods can be called using the dollar sign notation. Note that the `getPrivate` and `setPrivate` methods are not accessible outside the constructor. There is no way to access the private field `age` after the person object is created.

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

Any object comes with a `ls()` method which returns the vector of the names of all public fields and public methods.

```
> peter$ls()
[1] "getName"  "isOver18" "name"     "sayHi"    "setName" 
```

## Inheritance
Extending a class is similar to defining a class except for two differences.

1. At the begining of a constructor, we call the super class constructor instead of calling `Object()`.
2. Use the function `overrideMethod` to override a super class method. The first argument of the overriden function is a special argument called `parentMethod`. This allows the overriden method to call its parent method.

```
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
```

The class Student inherits all public methods from Person. Note that Student overrides the method `getName()` to use uppercase letters and the method `sayHi()` inherited from Person calls `getName()`. Therefore, calling `sayHi()` from an instance of Student would have the name in uppercase. This is the expected behavior in object-oriented programming.

```
amy <- Student('Amy', 22, 987)
print(amy$getName())      # AMY
print(amy$get('name'))    # Amy
print(amy$isOver18())     # TRUE

amy$setName('Amy Chan')
print(amy$getName())      # AMY CHAN
print(amy$get('name'))    # Amy Chan

amy$sayHi()               # Hi, my name is AMY CHAN.
```

## Private read-only fields
An object may have private read-only fields. In the example below, the field `count` of the `Counter` object is private read-only. It is private since it cannot be accessed after the `Counter` object is created. It is read-only in the sense that methods of `Counter` are not able to change its value.

```
# Constructor
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

  finalizeObject(counter, c('getCount', 'addCount'))
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
