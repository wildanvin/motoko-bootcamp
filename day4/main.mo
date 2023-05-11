import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

actor Ledger {
  type Result<T, E> = Result.Result<T, E>;

  type Subaccount = Blob;

  type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };

  var ledger = TrieMap.TrieMap<Account, Nat>(
    func(a : Account, b : Account) : Bool {
      return a == b;
    },
    func(x : Account) : Hash.Hash {
      return Principal.hash(x.owner);
    },
  );

  public query func name() : async Text {
    return "MotoCoin";
  };

  public query func symbol() : async Text {
    return "MOC";
  };

  public query func totalSupply() : async Nat {
    var total : Nat = 0;
    for (balance in ledger.vals()) {
      total += balance;
    };
    return total;
  };

  public query func balanceOf(account : Account) : async Nat {
    //return ledger.get(account);
    switch (ledger.get(account)) {
      case (null) { return 0 };
      case (?value) { return value };
    };
  };

  public func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
    switch (ledger.get(from)) {
      case (null) { #err("Account doesn't exist.") };
      case (?value) {
        //#ok()

        if (value < amount) {
          #err("Not enough balance");

        } else {
          ignore var x = ledger.replace(from, value - amount);
          ignore var y = ledger.replace(to, value + amount);
          #ok();
        };
      };
    };
  };

  public func airdrop() : async Result<(), Text> {
    let bootcampCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared() -> async [Principal];
    };
    let students = await bootcampCanister.getAllStudentsPrincipal();
    for (student in students.vals()) {
      let account = { owner = student; subaccount = null };
      ledger.put(account, 1000);
    };
    #ok();
  };

};
