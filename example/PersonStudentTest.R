source('example/Person.R')
source('example/Student.R')

tester <- UnitTester()

tester$addTest('Test Person creation', function() {
  peter <- Person('Peter', 12)
  tester$assertEqual(c('name'), peter$fieldNames())
  tester$assertEqual(c('getName', 'isOver18', 'sayHi', 'setName'), peter$methodNames())
})

tester$addTest('Test Person$get("name")', function() {
  peter <- Person('Peter', 12)
  tester$assertEqual('Peter', peter$get('name'))
})

tester$addTest('Test Person$getName()', function() {
  peter <- Person('Peter', 12)
  tester$assertEqual('Peter', peter$getName())
})

tester$addTest('Test Person$isOver18()', function() {
  peter <- Person('Peter', 12)
  tester$assertFalse(peter$isOver18())
})

tester$addTest('Test Person$setName()', function() {
  peter <- Person('Peter', 12)
  peter$setName('Peter Pan')
  tester$assertEqual('Peter Pan', peter$getName())
  tester$assertEqual('Peter Pan', peter$get('name'))
  tester$assertEqual('Hi, my name is Peter Pan.', peter$sayHi())
})

tester$addTest('Test Student Creation', function() {
  amy <- Student('Amy', 22, '987')
  tester$assertEqual(c('name'), amy$fieldNames())
  tester$assertEqual(c('getName', 'hiddenStudentID', 'isOver18', 'sayHi', 'setName'), amy$methodNames())
})

tester$addTest('Test Student$get("name")', function() {
  amy <- Student('Amy', 22, '987')
  tester$assertEqual('Amy', amy$get('name'))
})

tester$addTest('Test Student$getName()', function() {
  amy <- Student('Amy', 22, '987')
  tester$assertEqual('AMY', amy$getName())
})

tester$addTest('Test Student$isOver18()', function() {
  amy <- Student('Amy', 22, '987')
  tester$assertTrue(amy$isOver18())
})

tester$addTest('Test Student$setName()', function() {
  amy <- Student('Amy', 22, '987')
  amy$setName('Amy Chan')
  tester$assertEqual('AMY CHAN', amy$getName())
  tester$assertEqual('Amy Chan', amy$get('name'))
  tester$assertEqual('Hi, my name is AMY CHAN.', amy$sayHi())
})

tester$runAllTests()
