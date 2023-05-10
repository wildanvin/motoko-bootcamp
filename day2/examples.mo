import Iter "mo:base/Iter";
actor {
  //Iterators
  let myRange : Iter.Iter<Nat> = Iter.range(1, 3);

  var sum = 0;

  func update(a : Nat, b : Nat) {
    sum += a;
  };

  Iter.iterate(myRange, update);

  //Variants
  type Car = { make : Text; model : Text; year : Nat; color : Text };
  type Moto = { make : Text; model : Text; year : Nat; tipo : Text };
  type Plane = { make : Text; model : Text; year : Nat; seats : Nat };

  public func start(v : Vehicle) : async Text {
    switch (v) {
      case (#Car(car)) {
        // We can access the car object. For instance we can access the make field by using car.make
        let make = car.year;
        return ("Vroom 🏎️");
      };
      case (#Moto(m)) {
        // We can give the object any name that is convenient. In this case we can access the type by using m.type.
        let tipo = m.tipo;
        return ("Roar 🏍️");
      };
      case (#Plane(x)) {
        // Here we go again.. we can access the number of seats by using x.seats
        let seats = x.seats;
        return ("Whoosh 🛫");
      };
    };
  };

  type Vehicle = {
    #Car : Car;
    #Moto : Moto;
    #Plane : Plane;
  };

  //Objects
  var student = {
    name = "John";
    var age = 35;
    favoriteLanguage = "Motoko";
    graduate = true;
  };

  student.age += 1;

  public func add2Age() : async () {
    student.age += 1;
  };

  public query func seeAge() : async Nat {
    student.age;
  };

};
