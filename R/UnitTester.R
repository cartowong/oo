#' Constructor of the class UnitTester.
#'
#' @return an instance of UnitTester
#' @examples
#' unitTester <- UnitTester()
#'
#' unitTester$addTest('Test 1', function() {
#'   unitTester$assertEqual(1, 1)
#' })
#'
#' unitTester$addTest('Test 2', function() {
#'   unitTester$assertThrow(function() {
#'     stop('Error from Test 2')
#'   })
#' })
#'
#' unitTester$runAllTests()
#'
#' @export
UnitTester <- function(turnWarningsToErrors = TRUE) {

    unitTester <- Object()

    turnWarningsToErrors <- turnWarningsToErrors

    unitTester$definePrivate('testMethods', list())
    unitTester$definePrivate('currentTestName', '')
    unitTester$definePrivate('numAssertionsPassed', 0)
    unitTester$definePrivate('numAssertionsFailed', 0)
    unitTester$definePrivate('numErrorsCaught', 0)
    unitTester$definePrivate('assertThrowPassed', FALSE)
    unitTester$definePrivate('assertThrowErrorMessage', '')
    unitTester$definePrivate('assertNotThrowPassed', FALSE)
    unitTester$definePrivate('assertNotThrowErrorMessage', '')
    unitTester$definePrivate('hidePassed', FALSE)

    # Add a test to this unit tester.
    unitTester$addMethod('addTest', function(this, testName, testMethod) {
      checkIsString(testName, 'testName should be a string')
      checkIsFunction(testMethod, 'testMethod should be a function')

      testMethods <- this$get('testMethods')
      oldNames <- names(testMethods)
      testMethods <- append(testMethods, testMethod)
      names(testMethods) <- append(oldNames, testName)
      this$set('testMethods', testMethods)
    })

    # Private method to report the result of an assertion.
    unitTester$addPrivateMethod('report', function(this, passed, message) {
      if (passed) {
        this$set('numAssertionsPassed', this$get('numAssertionsPassed') + 1)
      } else {
        this$set('numAssertionsFailed', this$get('numAssertionsFailed') + 1)
      }

      if (!passed || !this$get('hidePassed')) {
        cat(message)
      }
    })

    # Run all tests that have been added using addTest.
    unitTester$addMethod('runAllTests', function(this, hidePassed = FALSE) {
      checkIsBoolean(hidePassed, 'hidePassed should be a boolean')
      this$set('hidePassed', hidePassed)

      if (turnWarningsToErrors) {
        options(warn = 2)
      }

      testMethods <- this$get('testMethods')
      for (testName in names(testMethods)) {
        this$set('currentTestName', testName)
        testMethod <- testMethods[[testName]]
        tryCatch({
          testMethod()
        }, error = function(err) {
          this$set('numErrorsCaught', this$get('numErrorsCaught') + 1)

          message <- sprintf('%s\nError: %s\n\n', testName, trimws(err))
          cat(message)
        })
      }

      cat(sprintf('Number of passed assertions: %s\nNumber of failed assertions: %s\nNumber of unexpected errors: %s\n\n',
                  this$get('numAssertionsPassed'),
                  this$get('numAssertionsFailed'),
                  this$get('numErrorsCaught')))

      options(warn = 0) # restore to default setting
    })

    # Assert that two objects are (almost) equal, based on all.equal in the base package.
    unitTester$addMethod('assertEqual', function(this, expect, actual, message = NA) {
      if (!isNA(message)) {
        checkIsString(message, 'message should be a string')
      }

      testName <- this$get('currentTestName')

      # Test result.
      result <- all.equal(expect, actual)
      passed <- isBoolean(result) && result
      if (passed) {
        message <- sprintf('%s\nPassed: expect = <%s> and actual = <%s>.\n\n', testName, toString(expect), toString(actual))
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: expect = <%s> and actual = <%s>.\n\n', testName, toString(expect), toString(actual))
      } else {
        message <- sprintf('%s\nFailed: %s\n\n', testName, trimws(message))
      }

      this$report(passed, message)
    })

    # Assert that a value is NA.
    unitTester$addMethod('assertNA', function(this, value, message = NA) {
      this$assertEqual(NA, value, message)
    })

    # Assert that a value is null.
    unitTester$addMethod('assertNull', function(this, value, message = NA) {
      this$assertEqual(NULL, value, message)
    })

    # Assert that a value is true.
    unitTester$addMethod('assertTrue', function(this, value, message = NA) {
      this$assertEqual(TRUE, value, message)
    })

    # Assert that a value is false.
    unitTester$addMethod('assertFalse', function(this, value, message = NA) {
      this$assertEqual(FALSE, value, message)
    })

    # Assert that an error is thrown.
    unitTester$addMethod('assertThrow', function(this, f, message = NA) {
      if (!isNA(message)) {
        checkIsString(message, 'message should be a string')
      }

      testName <- this$get('currentTestName')
      this$set('assertThrowPassed', FALSE)
      tryCatch({
        f()
      }, error = function(err) {
        this$set('assertThrowPassed', TRUE)
        this$set('assertThrowErrorMessage', trimws(err))
      })

      # Test result.
      passed <- this$get('assertThrowPassed')
      if (passed) {
        message <- sprintf('%s\nPassed: assertThrow successfully caught an error <%s>.\n\n', testName, this$get('assertThrowErrorMessage'))
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: assertThrow did not catch any error.\n\n', testName)
      } else {
        message <- sprintf('%s\nFailed: %s', testName, message)
      }

      this$report(passed, message)
    })

    # Assert that no error is thrown.
    unitTester$addMethod('assertNotThrow', function(this, f, message = NA) {
      if (!isNA(message)) {
        checkIsString(message, 'message should be a string')
      }

      testName <- this$get('currentTestName')
      this$set('assertNotThrowPassed', TRUE)
      tryCatch({
        f()
      }, error = function(err) {
        this$set('assertNotThrowPassed', FALSE)
        this$set('assertNotThrowErrorMessage', trimws(err))
      })

      # Test result.
      passed <- this$get('assertNotThrowPassed')
      if (passed) {
        message <- sprintf('%s\nPassed: assertNotThrow did not catch any error.\n\n', testName)
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: assertNotThrow caught an error <%s>.\n\n', testName, this$get('assertNotThrowErrorMessage'))
      } else {
        message <- sprintf('%s\nFailed: %s', testName, message)
      }

      this$report(passed, message)
    })

    unitTester$finalize()
}
