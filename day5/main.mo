import Interface "ICInterface";
import Interface2 "ICInterface2";


import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";

actor Verifier {

  //Part 1: Storing the students information.

  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  stable var studentEntries : [(Principal, StudentProfile)] = [];

  var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(
    0,
    Principal.equal,
    Principal.hash,
  );

  public shared({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {

    switch (studentProfileStore.get(caller)) {
      case (null) { studentProfileStore.put(caller, profile); return #ok() };
      case (?profile) { #err("You already have a profile") };

    };
  };

  public query func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {

    switch (studentProfileStore.get(p)) {
      case (null) { #err("Profile does not exist") };
      case (?profile) { #ok(profile) };

    };
  };

  public shared({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {

    switch (studentProfileStore.get(caller)) {
      case (null) { #err("Create a profile first") };
      case (?oldProfile) {
        ignore studentProfileStore.replace(caller, profile);
        #ok();
      };

    };
  };

  public shared({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {

    switch (studentProfileStore.get(caller)) {
      case (null) { #err("No profile") };
      case (?profile) {
        studentProfileStore.delete(caller);
        #ok();
      };

    };
  };

  system func preupgrade() {
    studentEntries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    for ((id, profile) in studentEntries.vals()) {
      studentProfileStore.put(id, profile);
    };
  };

  // Part 2: Testing of the simple calculator.
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };
  public type TestResult = Result.Result<(), TestError>;

  public func test(canisterId : Principal) : async TestResult {
    let calculator = actor (Principal.toText(canisterId)) : actor {
      add : shared(n : Int) -> async Int;
      sub : shared(n : Nat) -> async Int;
      reset : shared() -> async Int;
    };

    try {
        var result = await calculator.reset();
        result := await calculator.add(2);

        if (result != 2) {
            return #err(#UnexpectedValue("Add function failed"));
        };

        result := await calculator.sub(1);
        if (result != 1) {
            return #err(#UnexpectedValue("Sub function failed"));
        };

        result := await calculator.reset();
        if (result != 0) {
            return #err(#UnexpectedValue("Reset function failed"));
        };

        #ok();
    } catch (e) {
        return #err(#UnexpectedError("Something unexpected happened"));
    };
  };

  // Part 3: Verifying the controller of the calculator.
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {

  //public func verifyOwnership(canisterId : Text/*, p : Principal*/) : async Result.Result<Bool, Text> {
    
    let IC = "aaaaa-aa";
    let ic = actor (IC) : Interface.Self;

    var controllers : [Principal] = [];

    let canister_id = canisterId;
    //let canister_id = Principal.fromText(canisterId);

    try {
        let canisterStatus = await ic.canister_status({ canister_id });
        controllers := canisterStatus.settings.controllers;
        #err("1) What?");
        } catch (e) {
            controllers := await parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
            for (x in controllers.vals()) {
                switch(Principal.compare(x, p)){
                    case(#equal){ return #ok(true)};
                    case(_){};
                };
            };
            return #err("You are not the owner of the canister");
        };
  };


  public func getOwners(canisterId : Text) : async [Principal] {    
    let IC = "aaaaa-aa";
    let ic = actor (IC) : Interface.Self;

    var controllers : [Principal] = [];

    //let canister_id = canisterId;
    let canister_id = Principal.fromText(canisterId);

    try {
        let canisterStatus = await ic.canister_status({ canister_id });
            controllers := canisterStatus.settings.controllers;
            return controllers;
    } catch (e) {
            controllers := await parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
            return controllers;
    };
  };


  // Part4: Verify work:    
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {

    let testResult = await test(canisterId);
    let ownershipResult = await verifyOwnership(canisterId, p);
    
    switch(testResult){
        case(#err(failure)){
            switch(failure){
                case(#UnexpectedValue(text)){
                    return #err(text);
                };
                case(#UnexpectedError(text)){
                    return #err(text);

                };
            };
        };
        case(#ok()){
            switch(ownershipResult){
                case(#err(msg)){ #err(msg)};
                case(#ok(val)){
                    switch (studentProfileStore.get(caller)) {
                        case (null) {return #err("Create a profile first")};
                        case (?profile ) {
                            var temp : StudentProfile = {
                                name = profile.name;
                                team = profile.team;
                                graduate = true;
                            };
                            studentProfileStore.put(caller, temp);
                            return #ok(true);
                        };
                    };
                };
            };
        };
    };
  };



  /// Parses the controllers from the error returned by canister status when the caller is not the controller
  /// Of the canister it is calling
  ///
  /// TODO: This is a temporary solution until the IC exposes this information.
  /// TODO: Note that this is a pretty fragile text parsing solution (check back in periodically for better solution)
  ///
  /// Example error message:
  ///
  /// "Only the controllers of the canister r7inp-6aaaa-aaaaa-aaabq-cai can control it.
  /// Canister's controllers: rwlgt-iiaaa-aaaaa-aaaaa-cai 7ynmh-argba-5k6vi-75frw-kfqpa-3xtca-nmzk3-hrmvb-fydxk-w4a4k-2ae
  /// Sender's ID: rkp4c-7iaaa-aaaaa-aaaca-cai"
  public func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : async [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  //

};
