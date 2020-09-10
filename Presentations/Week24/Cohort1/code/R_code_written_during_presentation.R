library(Rcpp)

cppFunction("int add_special(int x, int y, int z){
            
              return x+y+z;
            }")

add_special(1729, 99, 14)


fibonacci_r <- function(n){
  if(n < 2) return(n)
  return (fibonacci_r(n-1) + fibonacci_r(n-2))
}


cppFunction("int fibonacci_cpp(int n){
  if (n < 2) return n;
  return fibonacci_cpp(n-1) + fibonacci_cpp(n-2);
}")

bench::mark(fibonacci_cpp(30), fibonacci_r(30))


cppFunction("double meanC(NumericVector x) {
  int n = x.size();
  double total = 0;
  for(int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total / n;
}")
/*** R
x <- runif(1e5)
bench::mark(
  mean(NA),
  meanC(NA)
)

meanC(NA)


cppFunction("NumericVector attribs() {
  NumericVector out = NumericVector::create(1, 2, 3);
  out.names() = CharacterVector::create("a", "b", "c");
  out.attr("my-attr") = "my-value";
  out.attr("class") = "my-class";
  return out;
}")




