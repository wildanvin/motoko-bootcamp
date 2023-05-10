# Day 2

In this day we start seeing motoko data structures. Since motoko is a typed language we are going to see a lot of generics (<T>). This is a grat example that illustrates the use of generics:

```csharp
function reverseArray<T>(arr: T[]): T[] {
  return arr.reverse();
}

const numbers = [1, 2, 3];
const reversedNumbers = reverseArray<number>(numbers);

const strings = ["hello", "world"];
const reversedStrings = reverseArray<string>(strings);
```

## Array

```javascript
actor {
    let array : [Nat] = [1, 2, 3, 4, 5];
    var sum : Nat = 0;

    public func somme_array() : async Nat {
        for (value in array.vals()){
          sum := sum + value;
        };
       return sum;
    };
};
```

## Buffer

Buffers are like dynamic arrays.

```javascript
import Buffer "mo:base/Buffer";
actor {
  let b = Buffer.Buffer<Nat>(2);
  b.add(0);
  b.add(10);
  b.add(100);

  public query func see(_index : Nat) : async Nat {
    b.get(_index);
  };
};

```

## Hashmaps

This are going to be important later as I assume this in going to be key to make tokens and NFTs

```javascript
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
actor {
    type Student = {
        name : Text;
        age : Nat;
        favoriteLanguage : Text;
        graduate : Bool;
    };

    let map = HashMap.HashMap<Principal, Student>(1, Principal.equal, Principal.hash);

    public query func getStudent(p : Principal) : async ?Student {
        map.get(p);
    };

    map.delete(principal);   // Delete but doesn't return the value

    let oldValue = map.remove(principal);   // Delete but returns the value
}
```
