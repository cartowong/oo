#' Constructor of the class Person.
#'
#' @param name the name of the person
#' @param age  the age of the person
#' @return an instance of Person
Person <- function(name, age) {

  # object to return
  person <- Object()

  # public field
  person$set('name', name)

  # private field
  person$setPrivate('age', age)

  # getter
  person$addMethod('getName', function(this) {
    this$get('name')
  })

  # private getter
  person$addPrivateMethod('getAge', function(this) {
    this$get('age')
  })

  # setter
  person$addMethod('setName', function(this, value) {
    this$set('name', value)
  })

  # This method refers to the private field age.
  person$addMethod('isOver18', function(this) {
    this$get('age') > 18
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
