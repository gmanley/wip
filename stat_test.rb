require 'bundler/setup'
Bundler.require(:default, :stat_test)

def ci_lower_bound(pos, n, confidence)
  return 0 if n == 0
  z = Statistics2.pnormaldist(1-(1-confidence)/2)
  phat = 1.0*pos/n
    (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
end

puts ci_lower_bound(99, 180, 0.9999999)