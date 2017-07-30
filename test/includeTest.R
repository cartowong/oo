tester <- UnitTester()

tester$addTest('Test require', function() {
  sourcedFiles <- include('test/resource')
  tester$assertEqual(c(file.path('test', 'resource', '1.R'), file.path('test', 'resource', 'sub', 'sub1.R')), sourcedFiles)
})

tester$runAllTests()
