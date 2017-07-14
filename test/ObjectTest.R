tester <- UnitTester()

tester$addTest('Test object properties', function() {
  ClassA <- function() {
    classA <- Object()
    classA$define('publicField')
    classA$definePrivate('privateField')
    classA$finalize()
  }
  obj <- ClassA()
  tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'extend'), names(obj))
  tester$assertEqual(c('publicField'), obj$fieldNames())
  tester$assertEqual(0, length(obj$methodNames()))
})

tester$addTest('Test define public field and get it internally', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  tester$assertEqual(26, obj$get(dataKey))
})

tester$addTest('Test define public field and get it using this', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  obj$addMethod('getData', function(this) {
    this$get(dataKey)
  })
  obj <- obj$finalize()
  tester$assertEqual(26, obj$getData())
})

tester$addTest('Test define public field and get it externally', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  obj <- obj$finalize()
  tester$assertEqual(26, obj$get(dataKey))
})

tester$addTest('Test define private field and get it internally', function() {
  obj <- Object()
  dataKey <- obj$definePrivate('data', 26)
  tester$assertEqual(26, obj$get(dataKey))
})

tester$addTest('Test define private field and get it using this', function() {
  obj <- Object()
  dataKey <- obj$definePrivate('data', 26)
  obj$addMethod('getData', function(this) {
    this$get(dataKey)
  })
  obj <- obj$finalize()
  tester$assertEqual(26, obj$getData())
})

tester$addTest('Test define private field and get it externally', function() {
  tester$assertThrow(function() {
    obj <- Object()
    dataKey <- obj$definePrivate('data', 26)
    obj <- obj$finalize()
    obj$get(dataKey)
  })
})

tester$addTest('Test define public field and set it internally', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  obj$set(dataKey, 27)
  tester$assertEqual(27, obj$get(dataKey))
})

tester$addTest('Test define public field and set it using this', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  obj$addMethod('setData', function(this, value) {
    this$set(dataKey, value)
  })
  obj <- obj$finalize()
  obj$setData(27)
  tester$assertEqual(27, obj$get(dataKey))
})

tester$addTest('Test define public field and set it externally', function() {
  obj <- Object()
  dataKey <- obj$define('data', 26)
  obj <- obj$finalize()
  obj$set(dataKey, 27)
  tester$assertEqual(27, obj$get(dataKey))
})

tester$addTest('Test define private field and set it internally', function() {
  obj <- Object()
  dataKey <- obj$definePrivate('data', 26)
  obj$set(dataKey, 27)
  tester$assertEqual(27, obj$get(dataKey))
})

tester$addTest('Test define private field and set it externally', function() {
  tester$assertThrow(function() {
    obj <- Object()
    dataKey <- obj$definePrivate('data', 26)
    obj <- obj$finalize()
    obj$set(dataKey, 27)
  })
})

tester$addTest('Test define private field and set it using this', function() {
  tester$assertNotThrow(function() {
    obj <- Object()
    dataKey <- obj$definePrivate('data', 26)
    obj$addMethod('setData', function(this, value) {
      this$set(dataKey, value)
    })
    obj <- obj$finalize()
    obj$setData(27)
  })
})

tester$addTest('Test set a non-existing field internally', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$set('nonExisting', 26)
  })
})

tester$addTest('Test set a non-existing field internally using this', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$addMethod('setNonExisting', function(this) {
      this$set('nonExisting', 26)
    })
    obj <- obj$finalize()
    obj$setNonExisting()
  })
})

tester$addTest('Test set a non-existing field externally', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj <- obj$finalize()
    obj$set('nonExisting', 26)
  })
})

tester$addTest('Test define duplicate fields (public and public)', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$define('data')
    obj$define('data')
  })
})

tester$addTest('Test define duplicate fields (public and private)', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$define('data')
    obj$definePrivate('data')
  })
})

tester$addTest('Test define duplicate fields (private and private)', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$definePrivate('data')
    obj$definePrivate('data')
  })
})

tester$addTest('Test duplicate method', function() {
  tester$assertThrow(function() {
    obj <- Object()
    obj$addMethod('foo', function() {})
    obj$addMethod('foo', function() {}) # add a duplicate method
  })
})

tester$addTest('Test multiple objects', function() {
  tester$assertNotThrow(function() {
    ClassA <- function() {
      classA <- Object()
      classA$define('x')
      classA$finalize()
    }
    obj1 <- ClassA()
    obj2 <- ClassA() # This should not throw an error.
  })
})

tester$runAllTests()
