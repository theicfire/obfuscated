def a(x):
  return x**4 - 5 * x ** 2 + 4

def b(x1, x2):
  return a(x1) * (x2 - x1)

def c(steps, x1, x2):
  incr = (x2 - x1) / steps
  if steps == 1:
    return b(x1, x2)
  return b(x1, x1 + incr) + c(steps - 1, x1 + incr, x2)

print a(3)
# (+ (bitfunc-rect 3 4) (bitfunc-rect 4 5) (bitfunc-rect 5 6)) 
print 'b', b(3, 4) + b(4, 5) + b(5, 6)
print c(1, 3, 6)
print c(2, 3, 6)
print c(3, 3, 6)
print c(50, 3.0, 6)
