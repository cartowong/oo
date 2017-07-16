tester <- UnitTester()

tester$addTest('Test object properties', function() {
  ClassA <- function() {
    classA <- Object()
    classA$define('publicField')
    classA$definePrivate('privateField')
    classA$addMethod('publicMethod', function() {})
    classA$addPrivateMethod('privateMethod', function() {})
    classA$finalize()
  }
  obj <- ClassA()
  tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'extend', 'publicMethod'), names(obj))
  tester$assertEqual(c('publicField'), obj$fieldNames())
  tester$assertEqual(c('publicMethod'), obj$methodNames())
})

tester$addTest('Test extended object properties', function() {
  ClassA <- function() {
    classA <- Object()
    classA$define('publicField')
    classA$definePrivate('privateField')
    classA$addMethod('publicMethod', function() {})
    classA$addPrivateMethod('privateMethod', function() {})
    classA$finalize()
  }
  a <- ClassA()
  b <- ClassA()$extend()
  tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'extend', 'publicMethod'), names(a))
  tester$assertEqual(c('define', 'definePrivate', 'get', 'set', 'fieldNames', 'methodNames', 'addMethod', 'addPrivateMethod', 'extend', 'finalize', 'overrideMethod'), names(b))
})

tester$addTest('Test extended this properties', function() {
  ClassA <- function() {
    classA <- Object()
    classA$define('publicField')
    classA$definePrivate('privateField')
    classA$addMethod('publicMethod', function() {})
    classA$addPrivateMethod('privateMethod', function() {})
    classA$finalize()
  }
  ClassB <- function() {
    classB <- ClassA()$extend()
    classB$addMethod('foo', function(this) {
      tester$assertEqual(c('get', 'set', 'fieldNames', 'methodNames', 'foo', 'publicMethod'), names(this))
    })
    classB$finalize()
  }
  ClassB()$foo()
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
  ClassA <- function() {
    classA <- Object()
    classA$define('data', 26)
    classA$addMethod('getData', function(this) {
      this$get('data')
    })
    classA$finalize()
  }
  ClassB <- function() {
    classB<- ClassA()$extend()
    classB$set('data', 27)
    classB$finalize()
  }
  a <- ClassA()
  b <- ClassB()
  tester$assertEqual(c(26, 26, 27, 27), c(a$get('data'), a$getData(), b$get('data'), b$getData()))
})

tester$addTest('Test private field cannot be overriden by adding a public field with the same name in a subclass', function() {
  ClassA <- function() {
    classA <- Object()
    classA$definePrivate('data', 26)
    classA$addMethod('getData', function(this) {
      this$get('data')
    })
    classA$finalize()
  }
  ClassB <- function() {
    classB<- ClassA()$extend()
    classB$define('data', 27)
    classB$finalize()
  }
  a <- ClassA()
  b <- ClassB()
  tester$assertEqual(c(26, 27, 26), c(a$getData(), b$get('data'), b$getData()))
})

tester$addTest('Test override a public method', function() {
  ClassA <- function() {
    classA <- Object()
    classA$addMethod('foo', function() {
      return(1)
    })
    classA$addMethod('callFoo', function(this) {
      this$foo()
    })
    classA$finalize()
  }
  ClassB <- function() {
    classB<- ClassA()$extend()
    classB$overrideMethod('foo', function() {
      return(2)
    })
    classB$finalize()
  }
  tester$assertEqual(c(1, 2, 1, 2), c(ClassA()$foo(), ClassB()$foo(), ClassA()$callFoo(), ClassB()$callFoo()))
})

tester$addTest('Test private method cannot be overriden by adding a method with the same name in a subclass', function() {
  ClassA <- function() {
    classA <- Object()
    classA$addPrivateMethod('foo', function() {
      return(1)
    })
    classA$addMethod('callFoo', function(this) {
      this$foo()
    })
    classA$finalize()
  }
  ClassB <- function() {
    classB<- ClassA()$extend()
    classB$addMethod('foo', function() {
      return(2)
    })
    classB$finalize()
  }
  tester$assertEqual(c(1, 2, 1), c(ClassA()$callFoo(), ClassB()$foo(), ClassB()$callFoo()))
})

tester$addTest('Test use addMethod instead of overrideMethod', function() {
  tester$assertThrow(function() {
    ClassA <- function() {
      classA <- Object()
      classA$addMethod('foo', function() {
        return(1)
      })
      classA$finalize()
    }
    ClassB <- function() {
      classB<- ClassA()$extend()
      classB$addMethod('foo', function() {
        return(2)
      })
      classB$finalize()
    }
    ClassB()
  })
})

tester$addTest('Test override a non-existing method', function() {
  tester$assertThrow(function() {
    ClassA <- function() {
      classA <- Object()
      classA$finalize()
    }
    ClassB <- function() {
      classB<- ClassA()$extend()
      classB$overrideMethod('nonExistingMethodName', function() {
        return(2)
      })
      classB$finalize()
    }
    ClassB()
  })
})

tester$addTest('Test a private method does not prevent subclass to use the same method name', function() {
  ClassA <- function() {
    classA <- Object()
    classA$addPrivateMethod('foo', function() {
      return(1)
    })
    classA$finalize()
  }
  ClassB <- function() {
    classB<- ClassA()$extend()
    classB$addMethod('foo', function() {
      return(2)
    })
    classB$finalize()
  }
  tester$assertEqual(2, ClassB()$foo())
})

tester$runAllTests()
