tester <- UnitTester(turnWarningsToErrors = TRUE, hidePassed = TRUE)

tester$addTest('Test unfinalized object properties', function() {
  a <- Object()
  a$define('publicField')
  a$definePrivate('privateField')
  a$addMethod('publicMethod', function() {})
  a$addPrivateMethod('privateMethod', function() {})

  tester$assertEqual(c('define', 'definePrivate', 'get', 'set', 'fieldNames', 'methodNames', 'addMethod', 'addPrivateMethod', 'extend', 'overrideMethod', 'finalize'), names(a))
  tester$assertEqual(c('publicField'), a$fieldNames())
  tester$assertEqual(c('publicMethod'), a$methodNames())
})

tester$addTest('Test object properties', function() {
  A <- function() {
    a <- Object()
    a$define('publicField')
    a$definePrivate('privateField')
    a$addMethod('publicMethod', function() {})
    a$addPrivateMethod('privateMethod', function() {})
    a$finalize()
  }
  a <- A()
  tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'extend', 'publicMethod'), names(a))
  tester$assertEqual(c('publicField'), a$fieldNames())
  tester$assertEqual(c('publicMethod'), a$methodNames())
})

tester$addTest('Test this properties', function() {
  A <- function() {
    a <- Object()
    a$define('publicField')
    a$definePrivate('privateField')
    a$addMethod('publicMethod', function() {})
    a$addPrivateMethod('privateMethod', function() {})
    a$addMethod('foo', function(this) {
      tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'privateMethod', 'foo', 'publicMethod'), names(this))
    })
    a$finalize()
  }
  A()$foo()
})

tester$addTest('Test extended object properties', function() {
  A <- function() {
    a <- Object()
    a$define('publicField')
    a$definePrivate('privateField')
    a$addMethod('publicMethod', function() {})
    a$addPrivateMethod('privateMethod', function() {})
    a$finalize()
  }
  a <- A()
  b <- A()$extend()
  tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'extend', 'publicMethod'), names(a))
  tester$assertEqual(c('define', 'definePrivate', 'get', 'set', 'fieldNames', 'methodNames', 'addMethod', 'addPrivateMethod', 'extend', 'overrideMethod', 'finalize'), names(b))
})

tester$addTest('Test extended this properties', function() {
  A <- function() {
    a <- Object()
    a$define('publicField')
    a$definePrivate('privateField')
    a$addMethod('publicMethod', function() {})
    a$addPrivateMethod('privateMethod', function() {})
    a$finalize()
  }
  B <- function() {
    b <- A()$extend()
    b$addMethod('foo', function(this) {
      tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'foo', 'publicMethod'), names(this))
    })
    b$finalize()
  }
  B()$foo()
})

tester$addTest('Test that methods can be added in any order', function() {
  tester$assertNotThrow(function() {
    A <- function() {
      a <- Object()
      a$addMethod('bar', function(this) {
        this$foo() # calling a method defined below
      })
      a$addMethod('foo', function() {})
      a$finalize()
    }
    a <- A()
    a$bar()
  })
})

tester$addTest('Test define(key, value) returns the key', function() {
  obj <- Object()
  aKey <- obj$define('a')
  tester$assertEqual('a', aKey)
})

tester$addTest('Test definePrivate(key, value) returns the key', function() {
  obj <- Object()
  aKey <- obj$definePrivate('a')
  tester$assertEqual('a', aKey)
})

tester$addTest('Test set(key, value) returns the value', function() {
  obj <- Object()
  obj$define('a')
  tester$assertEqual(26, obj$set('a', 26))
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

tester$addTest('Test define public field and get it using this in overriden method body', function() {
  a <- Object()
  a$addMethod('foo', function() {})
  a$finalize()

  b <- a$extend()
  dataKey <- b$define('data', 26)
  b$overrideMethod('foo', function(this) {
    this$get(dataKey)
  })
  b <- b$finalize()

  tester$assertEqual(26, b$foo())
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

tester$addTest('Test define private field and get it using this in overriden method body', function() {
  a <- Object()
  a$definePrivate('privateData', 43)
  a$addMethod('getData', function(this) {
    this$get('privateData')
  })
  a$finalize()

  b <- a$extend()
  dataKey <- b$definePrivate('data', 26)
  b$addMethod('getDataFromParent', function(this) {
    this$get('privateData')
  })
  b$overrideMethod('getData', function(this) {
    this$get(dataKey)
  })
  b <- b$finalize()

  tester$assertThrow(function() {
    b$getDataFromParent()
  })
  tester$assertEqual(26, b$getData())
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
    A <- function() {
      a <- Object()
      a$define('x')
      a$finalize()
    }
    obj1 <- A()
    obj2 <- A() # This should not throw an error.
  })
})

tester$addTest('Test different instances do not share public fields', function() {
  Person <- function(name) {
    person <- Object()
    person$define('name', name)
    person$finalize()
  }

  person1 <- Person('person1')
  person2 <- Person('person2')
  tester$assertEqual(c('person1', 'person2'), c(person1$get('name'), person2$get('name')))
})

tester$addTest('Test override a public field', function() {
  A <- function() {
    a <- Object()
    a$define('data', 26)
    a$addMethod('getData', function(this) {
      this$get('data')
    })
    a$finalize()
  }
  B <- function() {
    b<- A()$extend()
    b$set('data', 27)
    b$finalize()
  }
  a <- A()
  b <- B()
  tester$assertEqual(c(26, 26, 27, 27), c(a$get('data'), a$getData(), b$get('data'), b$getData()))
})

tester$addTest('Test private field cannot be overriden by adding a public field with the same name in a subclass', function() {
  A <- function() {
    a <- Object()
    a$definePrivate('data', 26)
    a$addMethod('getData', function(this) {
      this$get('data')
    })
    a$finalize()
  }
  B <- function() {
    b<- A()$extend()
    b$define('data', 27)
    b$finalize()
  }
  a <- A()
  b <- B()
  tester$assertEqual(c(26, 27, 26), c(a$getData(), b$get('data'), b$getData()))
})

tester$addTest('Test override a public method', function() {
  A <- function() {
    a <- Object()
    a$addMethod('foo', function() {
      return(1)
    })
    a$addMethod('callFoo', function(this) {
      this$foo()
    })
    a$finalize()
  }
  B <- function() {
    b<- A()$extend()
    b$overrideMethod('foo', function() {
      return(2)
    })
    b$finalize()
  }
  tester$assertEqual(c(1, 2, 1, 2), c(A()$foo(), B()$foo(), A()$callFoo(), B()$callFoo()))
})

tester$addTest('Test private method cannot be overriden by adding a method with the same name in a subclass', function() {
  A <- function() {
    a <- Object()
    a$addPrivateMethod('foo', function() {
      return(1)
    })
    a$addMethod('callFoo', function(this) {
      this$foo()
    })
    a$finalize()
  }
  B <- function() {
    b<- A()$extend()
    b$addMethod('foo', function() {
      return(2)
    })
    b$finalize()
  }
  tester$assertEqual(c(1, 2, 1), c(A()$callFoo(), B()$foo(), B()$callFoo()))
})

tester$addTest('Test use addMethod instead of overrideMethod', function() {
  tester$assertThrow(function() {
    A <- function() {
      a <- Object()
      a$addMethod('foo', function() {
        return(1)
      })
      a$finalize()
    }
    B <- function() {
      b<- A()$extend()
      b$addMethod('foo', function() {
        return(2)
      })
      b$finalize()
    }
    B()
  })
})

tester$addTest('Test override a non-existing method', function() {
  tester$assertThrow(function() {
    A <- function() {
      a <- Object()
      a$finalize()
    }
    B <- function() {
      b<- A()$extend()
      b$overrideMethod('nonExistingMethodName', function() {
        return(2)
      })
      b$finalize()
    }
    B()
  })
})

tester$addTest('Test a private method does not prevent subclass to use the same method name', function() {
  A <- function() {
    a <- Object()
    a$addPrivateMethod('foo', function() {
      return(1)
    })
    a$finalize()
  }
  B <- function() {
    b<- A()$extend()
    b$addMethod('foo', function() {
      return(2)
    })
    b$finalize()
  }
  tester$assertEqual(2, B()$foo())
})

tester$addTest('Test private methods of the same class are accessible when overriding a method', function() {
  a <- Object()
  a$addMethod('foo', function() { 26 })
  a <- a$finalize()

  b <- a$extend()
  b$addPrivateMethod('get27', function() {
    27
  })
  b$overrideMethod('foo', function(this) {
    this$get27()
  })
  b <- b$finalize()

  tester$assertEqual(27, b$foo())
})

tester$addTest('Test recursive method', function(this) {
  A <- function() {
    a <- Object()
    a$addMethod('sumToN', function(this, n) {
      if (n <= 0) {
        return(0)
      } else {
        return(n + this$sumToN(n - 1))
      }
    })
    a$finalize()
  }
  a <- A()
  tester$assertEqual(55, a$sumToN(10))
})

tester$runAllTests()
