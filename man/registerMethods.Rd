\name{registerMethods}
\alias{registerMethods}
\title{Register methods for an object.}
\description{This allows one to use the dollar sign notation to call methods and allows code completion if the IDE supports it.}
\usage{
registerMethods(object, methodNames)
}
\arguments{
\item{object}{the object for which methods are registered.}
\item{methodNames}{a character vector of the method names.}
}
\value{the object with registered methods.}
\examples{
# Constructor.
Person <- function(name) \{

  # object to return
  person <- Object()

  # name of the person
  person$set('name', name)

  # getter (will be overridden by the subclass Student)
  person$addMethod('getName', function() \{
    person$get('name')
  \})

  # setter
  person$addMethod('setName', function(value) \{
    person$set('name', value)
  \})

  # Note that this method calls getName(). If a subclass overrides getName(),
  # calling this method from an instance of the subclass will call the overriden
  # version of getName().
  person$addMethod('sayHi', function() \{
    print(sprintf('Hi, my name is \%s.', person$get('getName')()))
  \})

  # Register the methods so that they can be accessed using the dollar sign notation.
  # Note that this allows code completion if the IDE supports it.
  registerMethods(person, c('getName', 'setName', 'sayHi'))
\}

# Constructor. (This class extends Person.)
Student <- function(name, studentID) \{

  # object to return
  student <- Person(name)

  # Student ID. (Note that the name is inherited from the super class Person.)
  student$set('studentID', studentID)

  # override
  student$overrideMethod('getName', function(parentMethod) \{
    toupper(parentMethod())
  \})

  # no new methods to register
  student
\}

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

Output:
[1] "Peter"
[1] "Peter Pan"
[1] "Hi, my name is Peter Pan."
[1] "AMY"
[1] "AMY CHAN"
[1] "Hi, my name is AMY CHAN."
}
