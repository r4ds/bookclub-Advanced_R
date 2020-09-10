#include <algorithm>
#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//


// [[Rcpp::export]]
IntegerVector findInterval2(NumericVector x, NumericVector breaks) {
  IntegerVector out(x.size());
  NumericVector::iterator it, pos;
  IntegerVector::iterator out_it;
  for(it = x.begin(), out_it = out.begin(); it != x.end(); 
  it++, out_it++) {
    pos = std::upper_bound(breaks.begin(), breaks.end(), *it);
    *out_it = std::distance(breaks.begin(), pos);
  }
  return out;
}

// [[Rcpp::export]]
int weird_function(int input){
  
  int a = ++input;
  return a;
  
}

// [[Rcpp::export]]
int other_weird_function(int input){
  
  int a = input++;
  
  return a;
  
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
findInterval2(c(2,45,99,21), seq(0,100,5))
*/
