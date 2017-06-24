source('example/Person.R')
source('example/Student.R')

assertEqual <- function(expect, actual) {
  passed <- (expect == actual)
  print(sprintf('%s: expect = <%s>, actual = <%s>', ifelse(passed, 'PASSED', 'FAILED'), expect, actual))
}

peter <- Person('Peter', 12)
assertEqual('Peter', peter$getName())
assertEqual('Peter', peter$get('name'))
assertEqual(FALSE, peter$isOver18())

peter$setName('Peter Pan')
assertEqual('Peter Pan', peter$getName())
assertEqual('Peter Pan', peter$get('name'))
assertEqual('Hi, my name is Peter Pan.', peter$sayHi())

amy <- Student('Amy', 22, 987)
assertEqual('AMY', amy$getName())
assertEqual('Amy', amy$get('name'))
assertEqual(TRUE, amy$isOver18())

amy$setName('Amy Chan')
assertEqual('AMY CHAN', amy$getName())
assertEqual('Amy Chan', amy$get('name'))
assertEqual('Hi, my name is AMY CHAN.', amy$sayHi())
