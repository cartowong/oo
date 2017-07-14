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

tester$runAllTests()
