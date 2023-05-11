import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Order "mo:base/Order";

actor Wall {
  type Result<T, E> = Result.Result<T, E>;

  type Content = {
    #Text : Text;
    #Image : Blob;
    #Video : Blob;
  };

  type Message = {
    vote : Int;
    content : Content;
    creator : Principal;
  };

  var messageId : Nat = 0;

  var wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, Hash.hash);

  public shared({ caller }) func writeMessage(c : Content) : async Nat {
    let message : Message = { vote = 0; content = c; creator = caller };
    wall.put(messageId, message);
    messageId += 1;
    return messageId - 1;
  };

  public query func getMessage(messageId : Nat) : async Result<Message, Text> {

    switch (wall.get(messageId)) {
      case (null) { #err("Message doesn't exist.") };
      case (?message) { #ok(message) };
    };

  };

  public shared({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) { #err("Message doesn't exist.") };
      case (?message) {
        if (message.creator == caller) {
          wall.put(
            messageId,
            { vote = message.vote; content = c; creator = message.creator },
          );
          #ok();
        } else {
          #err("Only the message creator can update the message");
        };
      };
    };
  };

  public func deleteMessage(messageId : Nat) : async Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) { #err("Message doesn't exist.") };
      case (_) {
        wall.delete(messageId);
        #ok();
      };
    };
  };

  public func upVote(messageId : Nat) : async Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) { #err("Message doesn't exist.") };
      case (?message) {
        wall.put(
          messageId,
          {
            vote = message.vote + 1;
            content = message.content;
            creator = message.creator;
          },
        );
        #ok();
      };
    };
  };

  public func downVote(messageId : Nat) : async Result<(), Text> {
    switch (wall.get(messageId)) {
      case (null) { #err("Message doesn't exist.") };
      case (?message) {
        wall.put(
          messageId,
          {
            vote = message.vote - 1;
            content = message.content;
            creator = message.creator;
          },
        );
        #ok();
      };
    };
  };

  public query func getAllMessages() : async [Message] {
    var allMessages = Buffer.Buffer<Message>(0);
    for (messageId in wall.keys()) {
      switch (wall.get(messageId)) {
        case (null) {};
        case (?message) {
          allMessages.add(message);

        };
      };

    };
    return allMessages.toArray();
  };

  /*
  public func compare(x : Nat, y : Nat) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };
  */

  private func compareVotes(msg1 : Message, msg2 : Message) : {
    #less;
    #equal;
    #greater;
  } {
    if (msg2.vote < msg1.vote) {
      return #less;
    } else if (msg2.vote > msg1.vote) {
      return #greater;
    } else {
      return #equal;
    };
  };

  public query func getAllMessagesRanked() : async [Message] {
    //let rankedMessages : [Message] = getAllMessages();
    var allMessages = Buffer.Buffer<Message>(0);
    for (messageId in wall.keys()) {
      switch (wall.get(messageId)) {
        case (null) {};
        case (?message) {
          allMessages.add(message);

        };
      };
    };
    var rankedMessages = allMessages.toArray();
    return Array.sort<Message>(rankedMessages, compareVotes);
  };
  // Say the given phase.
  //public query func say(phrase : Text) : async Text {
  //  return phrase;
  //};
};
