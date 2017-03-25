import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
        result = succ (result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}

//Un chemin va être sous la forme de liste, on  construit la classe liste, comme aux exercices.

enum MyListRooms: Term, CustomStringConvertible {
    case empty
      //En fait, les éléments seront des room, la classe a été copiée du corrigé des exercices sur git
    case cons (element: Term, list: Term)
    var description: String {
      get {
        switch (self) {
        case .empty: return "[]"
        case let .cons(element: e, list: l): return String (describing: e) + ":" + String (describing: l)
        }
      }
    }
    func equals(_ other: Term) -> Bool {
        return (other is MyListRooms) && (other as! MyListRooms == self)
    }
    static func ==(lhs: MyListRooms, rhs: MyListRooms) -> Bool {
        switch (lhs, rhs) {
        case (let .cons(element: el, list: ll), let .cons(element: er, list: lr)):
            return el.equals(er) && ll.equals(lr)
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

//J'ai aussi pris cette fonciton, pour comparer avec la batterie, adaptée pour coller avec nos naturels
func list_size (list: Term, size: Term) -> Goal {
    return (list === MyListRooms.empty && size === zero) ||
      delayed (fresh { x in fresh { y in fresh { z in
        (list === MyListRooms.cons (element: x, list: y)) &&
        (size === succ (z)) &&
        (list_size (list: y, size: z))
      }}})
}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
  return Value (Position (x: x, y: y))
}

//Pour les quatre premières fonctions, on remplit juste avec les valeures des différents emplacement
//(en fait, on vérifie si l'élément est une entrée/si il y a une porte entre les éléments.)

func doors (from: Term, to: Term) -> Goal {
  return (from === room(1, 2) && to === room(1, 1)) ||
         (from === room(1, 3) && to === room(1, 2)) ||
         (from === room(1, 4) && to === room(1, 3)) ||

         (from === room(2, 4) && to === room(1, 4)) ||
         (from === room(2, 1) && to === room(1, 1)) ||

         (from === room(2, 1) && to === room(2, 2)) ||
         (from === room(2, 2) && to === room(2, 3)) ||
         (from === room(2, 3) && to === room(2, 4)) ||

         (from === room(2, 3) && to === room(3, 3)) ||
         (from === room(2, 4) && to === room(3, 4)) ||
         (from === room(3, 1) && to === room(2, 1)) ||
         (from === room(3, 2) && to === room(2, 2)) ||

         (from === room(3, 2) && to === room(3, 1)) ||

         (from === room(4, 1) && to === room(3, 1)) ||
         (from === room(4, 2) && to === room(3, 2)) ||
         (from === room(4, 3) && to === room(3, 3)) ||

         (from === room(4, 3) && to === room(4, 2)) ||
         (from === room(4, 4) && to === room(4, 3))


}

func entrance (location: Term) -> Goal {
    return location === room(1, 4) || location === room(4, 4)
}

func exit (location: Term) -> Goal {
    return location === room(1, 1) || location === room(4, 3)
}

func minotaur (location: Term) -> Goal {
    return location === room(3, 2)
}


func path (from: Term, to: Term, through: Term) -> Goal {
  //Le cas ou le chemin reste sur place
  return ((through === MyListRooms.cons(element: from, list: MyListRooms.empty)) && from === to) ||
  //head est le début de chemin, tail la fin, head2 et tail2 sont le début et la fin de tail
  (delayed(fresh{head in fresh{tail in fresh{head2 in fresh{tail2 in
  through === MyListRooms.cons(element: head, list: tail) && from === head &&
  //Ici, on vérifie qu'il y a bien une porte entre le premier et le deuxième élément du chemin.
  tail ===  MyListRooms.cons(element: head2, list: tail2) && doors(from:head, to:head2) &&
  //On vérifie que la fin du chemin est correcte aussi.
  path(from: head2, to: to, through: tail)
}}}}))


}

//On agit récurcivement, pour voir si la batterie tient jusqu'à la fin, ou plus loin.
func battery (through: Term, level: Term) -> Goal {
    return list_size(list: through, size: level) ||
    delayed(fresh{x in
    level === succ(x) && battery(through: through, level: x)
    })

}

//Cette fonction indique si un chemin passe par une certaine room
//On cherche récurcivement si le premier élément de la liste restante est l'élément recherché.
func is_in(room: Term, through: Term) -> Goal{
  return delayed(fresh{head in fresh{tail in
    through === MyListRooms.cons(element: head, list:tail) &&
    (head === room || is_in(room: room, through: tail))
  }})
}


//On vérifie toutes les conditions
func winning (through: Term, level: Term) -> Goal {
  return delayed (fresh{entry in fresh{sorty in fresh{minotaur_loc in
  entrance(location: entry) && exit(location: sorty) && minotaur(location: minotaur_loc) &&
  path (from: entry, to: sorty, through: through) && is_in(room: minotaur_loc, through: through) &&
  battery(through: through, level: level)
  }}})

}




























//TODO
