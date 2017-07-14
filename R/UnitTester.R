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

    unitTester$addMethod('addTest', function(this, testName, testMethod) {
      checkIsString(testName, 'testName should be a string')
      checkIsFunction(testMethod, 'testMethod should be a function')

      testMethods <- this$get('testMethods')
      oldNames <- names(testMethods)
      testMethods <- append(testMethods, testMethod)
      names(testMethods) <- append(oldNames, testName)
      this$set('testMethods', testMethods)
    })

    unitTester$addMethod('runAllTests', function(this) {
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

      cat(sprintf('Number of passed assertions: %s\nNumber of failed assertions: %s\nNumber of unexpected errors: %s\n\n', this$get('numAssertionsPassed'), this$get('numAssertionsFailed'), this$get('numErrorsCaught')))

      options(warn = 0) # restore to default setting
    })

    unitTester$addMethod('assertEqual', function(this, expect, actual, message = NA) {
      if (!isNA(message)) {
        checkIsString(message, 'message should be a string')
      }

      testName <- this$get('currentTestName')

      # Decide whether or not the test passes.
      result <- all.equal(expect, actual)
      passed <- isBoolean(result) && result

      # Update passed/failed assertion count.
      if (passed) {
        this$set('numAssertionsPassed', this$get('numAssertionsPassed') + 1)
      } else {
        this$set('numAssertionsFailed', this$get('numAssertionsFailed') + 1)
      }

      # Output message
      if (passed) {
        message <- sprintf('%s\nPassed: expect = <%s> and actual = <%s>.\n\n', testName, toString(expect), toString(actual))
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: expect = <%s> and actual = <%s>.\n\n', testName, toString(expect), toString(actual))
      } else {
        message <- sprintf('%s\nFailed: %s\n\n', testName, trimws(message))
      }

      cat(message)
    })

    unitTester$addMethod('assertNA', function(this, value, message = NA) {
      this$assertEqual(NA, value, message)
    })

    unitTester$addMethod('assertNull', function(this, value, message = NA) {
      this$assertEqual(NULL, value, message)
    })

    unitTester$addMethod('assertTrue', function(this, value, message = NA) {
      this$assertEqual(TRUE, value, message)
    })

    unitTester$addMethod('assertFalse', function(this, value, message = NA) {
      this$assertEqual(FALSE, value, message)
    })

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

      # Update passed/failed assertion count.
      passed <- this$get('assertThrowPassed')
      if (passed) {
        this$set('numAssertionsPassed', this$get('numAssertionsPassed') + 1)
      } else {
        this$set('numAssertionsFailed', this$get('numAssertionsFailed') + 1)
      }

      # Output message
      if (passed) {
        message <- sprintf('%s\nPassed: assertThrow successfully caught an error <%s>.\n\n', testName, this$get('assertThrowErrorMessage'))
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: assertThrow did not catch any error.\n\n', testName)
      } else {
        message <- sprintf('%s\nFailed: %s', testName, message)
      }

      cat(message)
    })

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

      # Update passed/failed assertion count.
      passed <- this$get('assertNotThrowPassed')
      if (passed) {
        this$set('numAssertionsPassed', this$get('numAssertionsPassed') + 1)
      } else {
        this$set('numAssertionsFailed', this$get('numAssertionsFailed') + 1)
      }

      # Output message
      if (passed) {
        message <- sprintf('%s\nPassed: assertNotThrow did not catch any error.\n\n', testName)
      } else if (is.na(message)) {
        message <- sprintf('%s\nFailed: assertNotThrow caught an error <%s>.\n\n', testName, this$get('assertNotThrowErrorMessage'))
      } else {
        message <- sprintf('%s\nFailed: %s', testName, message)
      }

      cat(message)
    })

    unitTester$finalize()
}
