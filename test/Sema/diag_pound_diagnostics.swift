// RUN: %target-parse-verify-swift

#warning "After the war I went back to New York" // expected-warning{{After the war I went back to New York}}

#if false
#warning "A-after the war I went back to New York" // no warning
#endif

struct Foo {
  #warning "I finished up my studies and I practiced law" // expected-warning{{I finished up my studies and I practiced law}}
  func foo() {
    #warning "I practiced law; Burr worked next door" // expected-warning{{I practiced law; Burr worked next door}}
    #error "Even though we started at the very same time" // expected-error{{Even though we started at the very same time}}
  }
}

func foo() {
  func bar() {
    #warning "Alexander Hamilton began to climb" // expected-warning{{Alexander Hamilton began to climb}}
    #error "How to account for his rise to the top?" // expected-error{{How to account for his rise to the top?}}
  }
  #warning "Man, the man is non-stop!" // expected-warning{{Man, the man is non-stop!}}
}
