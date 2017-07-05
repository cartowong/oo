source('example/Person.R')

#' Constructor of the class Student.
#'
#' The Student class extends the Person class.
#'
#' @return an instance of Student
Student <- function(name, age, studentID) {

  Precondition$checkIsString(name, 'name should be a string')
  Precondition$checkIsNumeric(age, 'age should be numeric')
  Precondition$checkIsString(studentID, 'studentID should be a string')

  # object to return
  student <- Person(name, age)$extend()

  # private field
  student$setPrivate('studentID', studentID)

  # add private method
  student$addPrivateMethod('getStudentID', function(this) {
    this$get('studentID')
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
