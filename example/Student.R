source('example/Person.R')

#' Constructor of the class Student.
#'
#' The Student class extends the Person class.
#'
#' @return an instance of Student
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
