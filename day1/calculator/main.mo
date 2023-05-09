import Float "mo:base/Float";
import Int "mo:base/Int";

actor Calculator {
    
    var counter : Float = 0;

    public func add(x : Float) : async Float {
        counter := counter + x;
        counter;
    };

    public func sub(x : Float) : async Float {
        counter := counter - x;
        counter;
    };

    public func mul(x : Float) : async Float {
        counter := counter * x;
        counter;
    };

    public func div(x : Float) : async ?Float {
      if (x == 0) {
      // 'null' encodes the division by zero error.
      return null;
    } else {
      counter /= x;
      return ?counter;
    };
    };

    public func reset() : async () {
        counter := 0;
   };

    public query func see() : async Float {
        counter;
    };

    public func power(x: Float) : async Float {
        counter := counter ** x;
        counter;
    };

    public func floor() : async Int {
        counter := Float.floor(counter);
        return Float.toInt(counter); 
    };

    public func sqrt() : async Float {
        counter := Float.sqrt(counter);
        counter;
    };
};