tester <- UnitTester(turnWarningsToErrors = TRUE, hidePassed = TRUE)

tester$addTest('Test without file separator at the end', function() {
  path <- file.path('test', 'resource')
  sourcedFiles <- include(path)
  tester$assertEqual(c(file.path('test', 'resource', '1.R'), file.path('test', 'resource', 'sub', 'sub1.R')), sourcedFiles)
})

tester$addTest('Test with file separator at the end', function() {
  path <- file.path('test', 'resource', '')
  sourcedFiles <- include(path)
  tester$assertEqual(c(file.path('test', 'resource', '1.R'), file.path('test', 'resource', 'sub', 'sub1.R')), sourcedFiles)
})

tester$addTest('Test empty path', function() {
  tester$assertThrow(function() {
    include('')
  })
})

tester$addTest('Test ignore file', function() {
  path <- file.path('test', 'resource')
  sourcedFiles <- include(path, ignore = 'sub1')
  tester$assertEqual(c(file.path('test', 'resource', '1.R')), sourcedFiles)
})

tester$addTest('Test ignore dir', function() {
  path <- file.path('test', 'resource')
  sourcedFiles <- include(path, ignore = 'sub')
  tester$assertEqual(c(file.path('test', 'resource', '1.R')), sourcedFiles)
})

tester$runAllTests()
