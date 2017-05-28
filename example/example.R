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
