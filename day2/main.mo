import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text"

actor HomeworkDiary {
  type Result<T, E> = Result.Result<T, E>;
  var homeworkCounter : Nat = 0;

  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;
  };

  var homeworkDiary = Buffer.Buffer<Homework>(0);

  public func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    homeworkCounter += 1;
    return (homeworkCounter - 1);
  };
  /*
  public func getHomework(homeworkId : Nat) : async Homework {
    return (homeworkDiary.get(homeworkId));
  };
  */
  public func getHomework(homeworkId : Nat) : async Result<Homework, Text> {
    if (homeworkId >= homeworkCounter) {
      #err("Index out of bound.");
    } else {
      #ok(homeworkDiary.get(homeworkId));
    };
  };

  public func updateHomework(homeworkId : Nat, homework : Homework) : async Result<(), Text> {
    if (homeworkId >= homeworkCounter) {
      #err("Index out of bound.");
    } else {
      homeworkDiary.put(homeworkId, homework);
      #ok();
    };
  };

  public func markAsCompleted(homeworkId : Nat) : async Result<(), Text> {
    if (homeworkId >= homeworkCounter) {
      #err("Index out of bound.");
    } else {
      var tempTitle = homeworkDiary.get(homeworkId).title;
      var tempDescription = homeworkDiary.get(homeworkId).description;
      var tempDueDate = homeworkDiary.get(homeworkId).dueDate;

      var tempObject = {
        title = tempTitle;
        description = tempDescription;
        dueDate = tempDueDate;
        completed = true;
      };

      homeworkDiary.put(homeworkId, tempObject);
      #ok();
    };
  };

  public func deleteHomework(homeworkId : Nat) : async Result<(), Text> {
    if (homeworkId >= homeworkCounter) {
      #err("Index out of bound.");
    } else {
      let x = homeworkDiary.remove(homeworkId);
      #ok();
    };
  };

  public query func getPendingHomework() : async [Homework] {
    let pendingHomework = Buffer.mapFilter<Homework, Homework>(
      homeworkDiary,
      func(x) {
        if (x.completed == false) {
          ?(x);
        } else {
          null;
        };
      },
    );
    return pendingHomework.toArray();
  };

  public query func searchHomework(searchTerm : Text) : async [Homework] {
    let searchedHomework = Buffer.mapFilter<Homework, Homework>(
      homeworkDiary,
      func(x) {
        if (Text.contains(x.title, #text searchTerm) or Text.contains(x.description, #text searchTerm)) {
          ?(x);
        } else {
          null;
        };
      },
    );
    return searchedHomework.toArray();
  };

  public query func getAllHomework() : async [Homework] {
    return homeworkDiary.toArray();
  };

};
