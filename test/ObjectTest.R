tester <- UnitTester()

tester$addTest('Test setPrivate with a public field', function() {
  tester$assertThrow(function() {
    o <- Object()
    o$set('publicField', 26)
    o$setPrivate('publicField', 27)
  })
})

tester$addTest('Test set with a private field', function() {
  tester$assertThrow(function() {
    o <- Object()
    o$setPrivate('privateField', 26)
    o$set('privateField', 27)
  })
})

tester$addTest('Test duplicate method', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$addMethod('foo', function() {})
    obj$addMethod('foo', function() {}) # add a duplicate method
  })
})

tester$addTest('Test duplicate key', function() {
  tester$assertNotThrow(function() {
    ClassA <- function() {
      classA <- Object()
      classA$setPrivate('x', NA)
      classA$finalize()
    }
    obj1 <- ClassA()
    obj2 <- ClassA() # This should not throw an error.
  })
})

tester$runAllTests()
