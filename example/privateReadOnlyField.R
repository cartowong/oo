library(oo)

# Constructor
Counter <- function() {

  # object to return
  counter <- Object()

  # private read-only field
  count <- 0

  # getter
  counter$addMethod('getCount', function() {
    count
  })

  # This method tries to add 1 to the private read-only field. It won't work.
  counter$addMethod('addCount', function() {
    count <- count + 1
  })

  finalizeObject(counter, c('getCount', 'addCount'))
}

counter <- Counter()
print(counter$getCount()) # 0

counter$addCount()
print(counter$getCount()) # 0
