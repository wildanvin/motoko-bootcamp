import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Float "mo:base/Float";

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
      sub : shared(n : Int) -> async Int;
      reset : shared() -> async Int;
    };

    var result = await calculator.add(2);

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
  };

  // Part 3: Verifying the controller of the calculator.
  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    //let managementCanister = ic.management.canister_status();
    return #err("not implemented");
  };

  var controllers : [Principal] = [];
  /*
  func canister_status() : async () {
    let canister_id = Principal.fromText(canister_principal);

    let canisterStatus = await ic.canister_status({ canister_id });

    controllers := canisterStatus.settings.controllers;
  };
  */

  /*
  public shared(verifyOwnership) func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
    let managementCanister = ic.management.canister_status();
    let canisterStatus = await managementCanister.status(canisterId);
    return canisterStatus.controllers.has(principalId);
  };
  */

  //

};
