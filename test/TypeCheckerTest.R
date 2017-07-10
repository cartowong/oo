tester <- UnitTester()

tester$addTest('Test isNA', function() {
  tester$assertTrue(TypeChecker$isNA(NA))

  # These values are not NAs.
  values <- list(
    NULL,
    c(NA, NA),
    list(NA, NA),
    matrix(c(NA, NA), 2, 1)
  )

  for (value in values) {
    tester$assertFalse(TypeChecker$isNA(value), message = toString(sprintf('%s should not be NA', value)))
  }
})

tester$addTest('Test isNull', function() {
  tester$assertTrue(TypeChecker$isNull(NULL))

  # These values are not Nulls.
  values <- list(
    NA,
    list(NULL, NULL),
    matrix(list(NULL, NULL), 2, 1)
  )

  for (value in values) {
    tester$assertFalse(TypeChecker$isNull(value), message = toString(sprintf('%s should not be null', value)))
  }
})

tester$runAllTests()
