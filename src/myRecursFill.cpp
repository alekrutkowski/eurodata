
#include <Rcpp.h>
using namespace Rcpp;

//' @export
// [[Rcpp::export]]
CharacterMatrix myRecursFill(CharacterMatrix d) {
	  int maxi = d.ncol() - 2;
	  int nrows = d.nrow() - 1;
	  for(int i = maxi; i >= 0; i--) {
	  	for (int n = 1; n <= nrows; n++) {
	    	if (d(n,i)=="" && d(n,i+1)!="") d(n,i) = d(n-1,i);
	  	}
	  }
	  for(int i = 1; i <= (maxi+1); i++) {
	  	for (int n = 0; n <= nrows; n++) {
	    	if (d(n,i)=="" && d(n,i-1)!="") {
				d(n,maxi+1) = d(n,i-1);
				d(n,i-1) = "";
	    	}
	  	}
	  }
	  return d;
}
