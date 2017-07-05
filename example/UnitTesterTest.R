unitTester <- UnitTester()

unitTester$addTest('Test 1', function() {
  unitTester$assertEqual(1, 1)
  stop('Error from Test 1')
})

unitTester$addTest('Test 2', function() {
  unitTester$assertEqual(1, 1)
})

unitTester$addTest('Test 3', function() {
  unitTester$assertEqual(1, 2)
})

unitTester$addTest('Test 4', function() {
  unitTester$assertEqual(c(1, 2, 3), c(1, 2, 3))
})

unitTester$addTest('Test 5', function() {
  unitTester$assertEqual(c(1, 2, 3), c(1, 3, 3))
})

unitTester$addTest('Test 6', function() {
  unitTester$assertThrow(function() {
    stop('Error from Test 6')
  })
})

unitTester$addTest('Test 7', function() {
  unitTester$assertThrow(function() {
    # This function does not throw any error.
  })
})

unitTester$runAllTests()
