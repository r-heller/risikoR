# turn errors read well

    Code
      rk_attack(game, "A", "B")
    Condition
      Error in `rk_attack()`:
      ! This action needs the "attack" phase.
      x The game is in the "reinforce" phase.

---

    Code
      rk_reinforce(game, "Blue", c(A = 3L))
    Condition
      Error in `rk_reinforce()`:
      ! It is not "Blue"'s turn.
      i "Red" is to move.

