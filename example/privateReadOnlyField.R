# This is an example to illustrate how one could add a private read-only field to a class.

library(oo)

# Constructor of the class Counter
#
# @return an instance of Counter
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

  counter$finalize()
}

counter <- Counter()
print(counter$getCount()) # 0

counter$addCount()
print(counter$getCount()) # 0
