/-  homunculus, *chess
/+  chess, default-agent
|%
::  copied from the %chess agent
+$  active-game-state
  $:  game=chess-game
      position=chess-position
      fen-repetition=(map @t @ud)
      special-draw-available=?
      auto-claim-special-draws=?
      sent-draw-offer=?
      got-draw-offer=?
      sent-undo-request=?
      got-undo-request=?
      opponent=ship
      practice-game=?
  ==
+$  games                (map game-id active-game-state)
+$  archived-games       (map game-id chess-game)
+$  challenges-sent      (map ship chess-challenge)
+$  challenges-received  (map ship chess-challenge)
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
+$  source                 @p
+$  ui-board               (list [key=tape =chess-square =chess-piece])
+$  menu-mode              ?(%games %challenges)
+$  notification           tape
+$  expand-game-options    $~(| bean)
+$  expand-challenge-form  $~(| bean)
+$  selected-game-id       (unit game-id)
+$  selected-game-pieces   ui-board
+$  selected-piece         ?([=chess-square =chess-piece] ~)
+$  available-moves        (set chess-square)
::
+$  state
  $:  =source
      =games
      =challenges-sent
      =challenges-received
      =menu-mode
      =notification
      =expand-game-options
      =expand-challenge-form
      =selected-game-id
      =selected-game-pieces
      =selected-piece
      =available-moves
  ==
::
+$  card  card:agent:gall
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
=|  state
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this |) bowl)
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-init
  ^-  (quip card _this)
  =^  cards  state  (initialize bowl)
  [cards this]
++  on-save
  !>(~)
++  on-load
  |=  *
  ^-  (quip card _this)
  =^  cards  state  (initialize bowl)
  [cards this]
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  !!
    ::
      %homunculus-event
    ?>  =(our.bowl src.bowl)
    =+  !<(eve=event:homunculus vase)
    ?+  -.eve  !!
      ::
        %open
      :_  this
      :~  ~(full tui-update bowl)
      ==
      ::
        %act
      ?+  p.eve  !!
        ::
          [%set-menu-mode @ta ~]
        =:  menu-mode              (^menu-mode i.t.p.eve)
            expand-challenge-form  |
          ==
        :_  this
        :~  ~(full tui-update bowl)
        ==
        ::
          [%toggle-challenge-form ~]
        =.  expand-challenge-form  !expand-challenge-form
        :_  this
        :~  ~(full tui-update bowl)
        ==
        ::
          [%toggle-game-options ~]
        =.  expand-game-options  !expand-game-options
        :_  this
        :~  ~(full tui-update bowl)
        ==
        ::
          [%select-game @ta ~]
        =/  id-val  (game-id (slav %ud i.t.p.eve))
        ?:  ?&  ?=(^ selected-game-id)
                =(id-val u.selected-game-id)
            ==
          [~ this]
        =:  selected-game-pieces
              ^-  ui-board
              %-  %~  rep  by  board.position:(~(got by games) id-val)
              |=  [[k=chess-square v=chess-piece] acc=ui-board]
              [[(weld <(@ -.k)> <(@ +.k)>) k v] acc]
            selected-game-id     [~ id-val]
            notification         ~
            selected-piece       ~
            available-moves      ~
            expand-game-options  |
          ==
        :_  this
        :~  ~(full tui-update bowl)
        ==
        ::
          [%select-piece @ta @ta @ta @ta ~]
        ?>  ?=(^ selected-game-id)
        =/  selection
          :-  (chess-square [i.t.p.eve (slav %ud i.t.t.p.eve)])
          (chess-piece [i.t.t.t.p.eve i.t.t.t.t.p.eve])
        =:  notification     ~
            selected-piece   ?:(=(selected-piece selection) ~ selection)
            available-moves
              %-  silt
              %~  moves-and-threatens
                %~  with-piece-on-square  with-board.chess
                  board.position:(~(got by games) u.selected-game-id)
              selection
          ==
        :_  this
        :~  ~(full tui-update bowl)
        ==
        ::
          [%move-piece @ta @ta ~]
        ?>  ?=(^ selected-game-id)
        ?>  ?=(^ selected-piece)
        =/  to  (chess-square [i.t.p.eve (slav %ud i.t.t.p.eve)])
        =.  available-moves  ~
        :_  this
        :~  ~(full tui-update bowl)
            :*  %pass   /move-piece
                %agent  [source %chess]
                %poke   %chess-user-action
                !>([%make-move u.selected-game-id %move chess-square.selected-piece to ~])
        ==  ==
        ::
          [%accept-challenge @ta ~]
        :_  this
        :_  ~
        :*  %pass   /accept-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%accept-challenge (slav %p i.t.p.eve)])
        ==
        ::
          [%decline-challenge @ta ~]
        :_  this
        :_  ~
        :*  %pass   /decline-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%decline-challenge (slav %p i.t.p.eve)])
        ==
        ::
          [%resign ~]
        :_  %_  this
              selected-game-id     ~
              selected-piece       ~
              available-moves      ~
              expand-game-options  |
            ==
        ?>  ?=(^ selected-game-id)
        :_  ~
        :*  %pass   /resign
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%resign u.selected-game-id])
        ==
        ::
      ==
      ::
        %form
      ?+  p.eve  !!
        ::
          [%send-challenge ~]
        =/  ship-input=@p
          =/  n=tape  (trip (~(got by q.eve) /challenge-ship-input))
          ?>  ?=(^ n)
          =?  n  !=('~' i.n)  ['~' n]
          (slav %p (crip n))
        =/  note-input=@t          (~(got by q.eve) /challenge-note-input)
        =/  side-option-white=@t   (~(got by q.eve) /side-option-white)
        =/  side-option-black=@t   (~(got by q.eve) /side-option-black)
        =/  side-option-random=@t  (~(got by q.eve) /side-option-random)
        =/  practice-input=?       =('%.y' (~(got by q.eve) /challenge-practice-checkbox))
        =/  challenge-side
          ?:  =('%.y' side-option-white)  %white
          ?:  =('%.y' side-option-black)  %black
          %random
        :_  this
        :_  ~
        :*  %pass   /send-challenge
            %agent  [source %chess]
            %poke   %chess-user-action
            !>([%send-challenge ship-input challenge-side note-input practice-input])
        ==
        ::
      ==
    ==
        ::
        ::  [%click %offer-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from offer-draw' !!)
        ::    :_  this
        ::    :_  ~
        ::    :*  %pass   /offer-draw
        ::        %agent  [source %chess]
        ::        %poke   %chess-user-action
        ::        !>([%offer-draw selected-game-id])
        ::    ==
        ::  ::
        ::  [%click %accept-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from accept-draw' !!)
        ::    :_  this
        ::    :_  ~
        ::    :*  %pass   /accept-draw
        ::        %agent  [source %chess]
        ::        %poke   %chess-user-action
        ::        !>([%accept-draw selected-game-id])
        ::    ==
        ::  ::
        ::  [%click %decline-draw]
        ::    ?~  selected-game-id
        ::      ~&('selected-game-id missing from decline-draw' !!)
        ::    =/  current-game  (~(got by games) selected-game-id)
        ::    =.  got-draw-offer.current-game  |
        ::    =.  games  (~(put by games) selected-game-id current-game)
        ::    =/  new-view=manx  (rig:mast routes url sail-sample)
        ::    :_  this(view new-view)
        ::    :~  (gust:mast /display-updates view new-view)
        ::        :*  %pass   /decline-draw
        ::            %agent  [source %chess]
        ::            %poke   %chess-user-action
        ::            !>([%decline-draw selected-game-id])
        ::    ==  ==
        ::
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  !!
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-leave  on-leave:def
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?>  =(our.bowl src.bowl)
  !!
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  [~ this]
    ::
      [%move-piece ~]
    ?+  -.sign  [~ this]
      ::
        %poke-ack
      ?>  ?&  ?=(^ p.sign)  ?=(^ u.p.sign)  =(%leaf -.i.u.p.sign)
              ?=(^ (find "invalid" +.i.u.p.sign))
          ==
      =:  notification    "Invalid move"
          selected-piece  ~
        ==
      :_  this
      :~  ~(full tui-update bowl)
      ==
      ::
    ==
    ::
      [%challenges ~]
    ?+  -.sign  [~ this]
      ::
        %kick
      :_  this
      :_  ~
      [%pass /challenges %agent [source %chess] %watch /challenges]
      ::
        %fact
      ?+  p.cage.sign  !!
        ::
          %chess-update
        =/  update  !<(chess-update q.cage.sign)
        ?+  -.update  !!
          ::
            %challenge-sent
          =:  expand-challenge-form  |
              challenges-sent
                (~(put by challenges-sent) who.update challenge.update)
            ==
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
            %challenge-received
          =.  challenges-received
            (~(put by challenges-received) who.update challenge.update)
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
            %challenge-resolved
          =.  challenges-sent
            (~(del by challenges-sent) who.update)
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
            %challenge-replied
          =.  challenges-received
            (~(del by challenges-received) who.update)
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
        ==
      ==
    ==
    ::
      [%active-games ~]
    ?+  -.sign  [~ this]
      ::
        %kick
      :_  this
      :_  ~
      [%pass /active-games %agent [source %chess] %watch /active-games]
      ::
        %fact
      ?+  p.cage.sign  !!
          %chess-game-active
        =/  chess-game-data  !<(chess-game q.cage.sign)
        =/  opponent
          ?:(=(source white.chess-game-data) black.chess-game-data white.chess-game-data)
        =/  new-game=active-game-state  
          :*  chess-game-data
              *chess-position
              *fen-repetition=(map @t @ud)
              special-draw-available=%.n
              auto-claim-special-draws=%.n
              sent-draw-offer=%.n
              got-draw-offer=%.n
              sent-undo-request=%.n
              got-undo-request=%.n
              opponent
              :: XX: need challenger's practice-game selection
              practice-game=%.n
          ==
        =.  games  (~(put by games) game-id.chess-game-data new-game)
        :_  this
        :~  ~(full tui-update bowl)
            :*  %pass   /game-updates/(scot %da game-id.chess-game-data) 
                %agent  [source %chess] 
                %watch  /game/(scot %da game-id.chess-game-data)/updates
        ==  ==
      ==
    ==
    ::
      [%game-updates ~]
    ?+  -.sign  [~ this]
        %fact
      ?+  p.cage.sign  !!
          %chess-update
        =/  update  !<(chess-update q.cage.sign)
        ::  ~&  >  'GAME UPDATE'
        ::  ~&  >>  update
        ?+  -.update  !!
          ::
            %position
          =/  from-data=tape  (trip p.move.update)
          =/  to-data=tape  (trip q.move.update)
          =/  from=chess-square
            ?.  &(?=(^ from-data) ?=(^ t.from-data))
              ~&('game-updates: data missing' !!)
            (chess-square [i.from-data (slav %ud i.t.from-data)])
          =/  to=chess-square
            ?.  &(?=(^ to-data) ?=(^ t.to-data))
              ~&('game-updates: data missing' !!)
            (chess-square [i.to-data (slav %ud i.t.to-data)])
          =/  game=(unit active-game-state)  (~(get by games) game-id.update)
          ?~  game  ~&('game-updates: data missing' !!)
          =/  piece=(unit chess-piece)  (~(get by board.position.u.game) from)
          ?~  piece  
            ::  because %position is hit twice if we are facing ourselves:
            ::  ignore the second (where the piece has already been moved).
            ?:  =(source opponent.u.game)
              `this
            ~&('game-updates: ui data missing' !!)
          =/  en-passant-capture=?(chess-square ~)
            ?:  ?&  =(%pawn +.u.piece)  !=(-.from -.to)
                    !(~(has by board.position.u.game) to)
                ==
              [-.to +.from]
            ~
          =.  board.position.u.game
            (~(put by (~(del by board.position.u.game) from)) to u.piece)
          =?  board.position.u.game  ?=(^ en-passant-capture)
            (~(del by board.position.u.game) en-passant-capture)
          =.  moves.game.u.game
            %+  snoc  moves.game.u.game
            ::  XX: add proper into=(unit chess-promotion) instead of ~
            [[%move from to ~] position.update san.update]
          =.  games  (~(put by games) game-id.update u.game)
          =?  selected-game-pieces
              ?&  ?=(^ selected-game-id)
                  =(game-id.update u.selected-game-id)
              ==
            |-
            ?~  selected-game-pieces  ~
            ?:  ?|  =(to chess-square.i.selected-game-pieces)
                    =(en-passant-capture chess-square.i.selected-game-pieces)
                ==
              $(selected-game-pieces t.selected-game-pieces)                      
            :-  ?.  =(from chess-square.i.selected-game-pieces)
                  i.selected-game-pieces
                [key.i.selected-game-pieces to chess-piece.i.selected-game-pieces]
            $(selected-game-pieces t.selected-game-pieces)
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
          ::  %draw-offered
          ::    =/  game-to-update  (~(get by games) game-id.update)
          ::    ?~  game-to-update  ~&('game not found for chess-update draw-offered' !!)
          ::    =.  games
          ::      (~(put by games) game-id.update u.game-to-update(got-draw-offer &))
          ::    =/  new-view=manx  (rig:mast routes url sail-sample)
          ::    :_  this(view new-view)
          ::    [(gust:mast /display-updates view new-view) ~]
          ::
            %result
          =:  games                 (~(del by games) game-id.update)
              selected-game-id      ~
              selected-game-pieces  ~
              selected-piece        ~
              available-moves       ~
            ==
          :_  this
          :~  ~(full tui-update bowl)
          ==
          ::
        ==
      ==
    ==
    ::
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  `this
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  on-fail   on-fail:def
--
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
|%
::
++  initialize
  |=  bol=bowl:gall
  ^-  (quip card ^state)
  =.  source
    ?.  ?=(%earl (clan:title our.bol))  our.bol
    (sein:title our.bol now.bol our.bol)
  =+  [gam sen rec]=(get-backend-state bol)
  =:  games                gam
      challenges-sent      sen
      challenges-received  rec
    ==
  :_  state
  :~  [%pass /challenges %agent [source %chess] %leave ~]
      [%pass /active-games %agent [source %chess] %leave ~]
      [%pass /challenges %agent [source %chess] %watch /challenges]
      [%pass /active-games %agent [source %chess] %watch /active-games]
      [%pass /homunculus %agent [our.bol %homunculus] %poke %homunculus-register !>(~)]
  ==
::
++  get-backend-state
  |=  bol=bowl:gall
  ^-  $:  ^games
          ^challenges-sent
          ^challenges-received
      ==
  =+  [our=(scot %p our.bol) now=(scot %da now.bol)]
  =+  game-ids=.^(arch %gy [our %chess now %games ~])
  =+  ^-  [active-games=^games =archived-games]
      %-  %~  rep  by  dir.game-ids
      |=  [[k=@ta *] a=(pair ^games archived-games)]
      ^+  a
      =+  id=(game-id (slav %da k))
      =+  ^=  game
          .^  $%  [%active active-game-state]
                  [%archived chess-game]
              ==
              %gx
              [our %chess now %game k %chess-game ~]
          ==
      ?-  -.game
        %active    a(p (~(put by p.a) id +.game))
        %archived  a(q (~(put by q.a) id +.game))
      ==
  :+  active-games                                                       :: TODO: add archived games
    (malt .^((list [ship chess-challenge]) %gx [our %chess now %challenges %outgoing %chess-challenges ~]))
  (malt .^((list [ship chess-challenge]) %gx [our %chess now %challenges %incoming %chess-challenges ~]))
::
++  tui-update
  |_  =bowl:gall
  ::
  ++  full
    ^-  card
    %-  make-card
    :~  [%element root]
    ==
  ::
  ++  make-card
    |=  =update:homunculus
    ^-  card
    :*  %pass  /homunculus  %agent  [our.bowl %homunculus]
        %poke  %homunculus-update  !>(update)
    ==
  ::
  --
::
++  root
  ^-  manx
  ;row(w "100%", h "100%", bg "cyan")
    ;layer(fx "end", fy "center")
      ;+  game-options
    ==
    ;layer(fx "center", fy "center", fl "row")
      ;+  chessboard
      ;col(w "30", h "24", ml "6", mt "1", bg "white", fg "black")
        ;+  game-panel
        ;+  menu
      ==
    ==
  ==
::
++  menu
  ^-  manx
  ;scroll(w "100%", h ?~(selected-game-id "100%" "70%"))
    ;row(w "100%", px "1", pt "1")
      ;select/"set-menu-mode/challenges"(w "48%", p "1", fg "white", bg "magenta", fx "center")
        =d  ?:(?=(%challenges menu-mode) "bold" "")
        ;+  ;/  "Challenges"
      ==
      ;select/"set-menu-mode/games"(w "48%", p "1", fg "white", bg "blue", fx "center")
        =d  ?:(?=(%games menu-mode) "bold" "")
        ;+  ;/  "Games"
      ==
    ==
    ;+  ?-  menu-mode
          %challenges  challenges-menu
          %games       games-menu
        ==
  ==
::
++  challenges-menu
  ^-  manx
  ;col(w "100%", px "1", pt "1")
    ;+  ?:  expand-challenge-form
          ;row(d "underline"):"Send a Challenge:"
        ;select/"toggle-challenge-form"(bg "magenta", fg "white", select-d "blink")
          ;+  ;/  ">Send a Challenge<"
        ==
    ;+  ?.  expand-challenge-form  ;null;
        challenge-form
    ;+  ?:  =(~ challenges-sent)  ;null;
        ;col(mt "1")
          ;row(d "underline"):"Sent Challenges:"
          ;col
            ;*  %+  turn  ~(tap by challenges-sent)
                |=  [=ship =chess-challenge]
                ;col
                  ;row:"To: {<ship>}"
                  ;row:"Your side: {(trip challenger-side.chess-challenge)}"
                ==
          ==
        ==
    ;row(mt "1", d "underline"):"Received Challenges:"
    ;+  ?:  =(~ challenges-received)
          ;row:"You have no challenges."
        ;col
          ;*  %+  turn  ~(tap by challenges-received)
              |=  [=ship =chess-challenge]
              ;col
                ;row:"Challenger: {<ship>}"
                ;row:"Their side: {(trip challenger-side.chess-challenge)}"
                ;row
                  ;select/"accept-challenge/{<ship>}"(mx "1", bg "magenta", fg "white", select-d "blink")
                    ;+  ;/  ">Accept<"
                  ==
                  ;select/"decline-challenge/{<ship>}"(mx "1", bg "magenta", fg "white", select-d "blink")
                    ;+  ;/  ">Decline<"
                  ==
                ==
              ==
        ==
  ==
::
++  challenge-form
  ^-  manx
  ;form/"send-challenge"(p "1", bg "#c7e4ff")
    ;row(mb "1")
      ;row(mr "2"):"Ship:"
      ;input/"challenge-ship-input";
    ==
    ;row(mb "1")
      ;row(mr "2"):"Note:"
      ;input/"challenge-note-input";
    ==
    ;col(mb "1")
      ;row:"Side:"
      ;radio(fl "row")
        ;row:"White"
        ;checkbox/"side-option-white";
        ;row(ml "1"):"Black"
        ;checkbox/"side-option-black";
        ;row(ml "1"):"Random"
        ;checkbox/"side-option-random";
      ==
    ==
    ;row(mb "1")
      ;row(mr "2"):"Practice?"
      ;checkbox/"challenge-practice-checkbox";
    ==
    ;submit(h "1", bg "magenta", fg "white", select-d "blink"):">Send Challenge<"
  ==
::
++  games-menu
  ^-  manx
  ?:  =(~ games)
    ;col(w "100%", p "1"):"You currently have no games."
  ;col(w "100%", h "5", p "1")
    ;*  %+  turn  `(list [game-id active-game-state])`~(tap by games)
        |=  [=game-id =active-game-state]
        ;select/"select-game/{<(@ game-id)>}"(ml "2", select-d "underline")
          ;+  ;/  "Opponent: {<opponent.active-game-state>}"
        ==
  ==
::
++  game-panel
  ^-  manx
  ?~  selected-game-id
    ;null;
  =/  current-game  (~(got by games) u.selected-game-id)
  =/  num-moves=@ud  (lent moves.game.current-game)
  =/  side-turn=tape  ?:((bean (mod num-moves 2)) "White" "Black")
  ;col(w "100%", h "30%", b "light", fx "center")
    ;row:"Opponent: {<opponent.current-game>}"
    ;row:"Turn: {<+(num-moves)>}"
    ;row:"{side-turn}"
    ;select/"toggle-game-options"(mt "1", bg "black", fg "white", select-d "blink")
      ;+  ;/  ">Options<"
    ==
  ==
::
++  game-options
  ^-  manx
  ?.  expand-game-options
    ;null;
  ;row(w "21", h "5", mr "6", bg "black", fg "white", fx "center", fy "center")
    ;select/"resign"(mr "6", bg "magenta", select-d "blink"):">Resign<"
    ;select/"toggle-game-options"(bg "magenta", select-d "blink"):"X"
  ==
::
:: ++  pieces-on-board
::   ^-  manx
::   =/  game-to-render=(unit active-game-state) 
::     ?~  selected-game-id  ~
::     (~(get by games) selected-game-id)
::   ?~  game-to-render
::     ;div(class "pieces-container");
::   ;div(class "pieces-container")
::     ;*  %+  turn  selected-game-pieces
::       |=  [key=tape =chess-square =chess-piece]
::       =/  trans-x=tape  ?:  =(%a -.chess-square)  "0"
::         "{<(sub (@ -.chess-square) 97)>}00%"
::       =/  trans-y=tape  ?:  =(%1 +.chess-square)  "0"
::         "-{<(sub (@ +.chess-square) 1)>}00%"
::       =/  ownership=bean
::         ?-  -.chess-piece
::           %white  =(source white.game.u.game-to-render)
::           %black  =(source black.game.u.game-to-render)
::         ==
::       =/  is-its-turn=bean
::         ?:  (bean (mod (lent moves.game.u.game-to-render) 2))
::           =(%white -.chess-piece)
::         =(%black -.chess-piece)
::       ;div
::         =key    key
::         =class  "piece {(trip -.chess-piece)} on-{(get-color chess-square)} {?:(&(ownership is-its-turn) "act" "")} {?:(&(?=(^ selected-piece) =(chess-square -.selected-piece)) "sel" "")}"
::         =style  "transform: translate({trans-x}, {trans-y});"
::         =event  ?.(ownership "" "/click/select-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}/{(trip -.chess-piece)}/{(trip +.chess-piece)}")
::         ;img(src "/~/scry/chess-ui/img/{(trip +.chess-piece)}.svg");
::       ==
::   ==
::
++  chessboard
  ^-  manx
  =/  game-to-render=(unit active-game-state) 
    ?~  selected-game-id  ~
    (~(get by games) u.selected-game-id)
  =/  side-turn=tape
    ?~  game-to-render  ~
    ?:  (bean (mod (lent moves.game.u.game-to-render) 2)) 
      "white"
    "black"
  ;row(w "52", h "26", px "1", b "heavy", fl "row-wrap", fg ?~(side-turn "cyan" side-turn))
    ;*  %+  turn  square-cells
        |=  =chess-square
        =/  pie=(unit chess-piece)
          ?~  game-to-render  ~
          (~(get by board.position.u.game-to-render) chess-square)
        =/  is-its-turn=bean
          ?:  |(?=(~ pie) ?=(~ game-to-render))  |
          ?:  (bean (mod (lent moves.game.u.game-to-render) 2))
            =(%white -.u.pie)
          =(%black -.u.pie)
        ?.  (~(has in available-moves) chess-square)
          ;row(h "3", w "6", bg (get-color chess-square), fg "cyan")
            ;*  ?~  pie  ~
                ~[(make-piece chess-square u.pie is-its-turn |)]
          ==
        ?^  pie
          ;select/"move-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}"(h "3", w "6", bg (get-color chess-square), fg "magenta")
            ;+  (make-piece chess-square u.pie is-its-turn &)
          ==
        ;select/"move-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}"(h "3", w "6", bg (get-color chess-square), fg "magenta", b "double");
  ==
::
++  make-piece
  |=  [=chess-square =chess-piece is-its-turn=bean threaten=bean]
  ^-  manx
  ?:  threaten
    ;row(w "100%", h "1", mx "1", mt "1", d "bold", fg "magenta")
      ;+  ;/  (trip +.chess-piece)
    ==
  =/  pat=tape
    ?.  is-its-turn  ""
    "/select-piece/{(trip -.chess-square)}/{<(@ +.chess-square)>}/{(trip -.chess-piece)}/{(trip +.chess-piece)}"
  ;select/"{pat}"(w "100%", h "1", mx "1", mt "1", d "bold", select-d "blink")
    =bg  ?:(?=(%white -.chess-piece) "#FFFFFF" "#000000")
    =fg  ?:(?=(%white -.chess-piece) "black" "white")
    ;+  ;/  (trip +.chess-piece)
  ==
::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::  ::
++  get-color
  |=  =chess-square
  ^-  tape
  ?:  (bean (mod (@ -.chess-square) 2))
    ?:  (bean (mod (@ +.chess-square) 2))
      "black"
    "white"
  ?:  (bean (mod (@ +.chess-square) 2))
    "white"
  "black"
::
++  square-cells
  ^-  (list chess-square)
  :~
    [%a %8]  [%b %8]  [%c %8]  [%d %8]  [%e %8]  [%f %8]  [%g %8]  [%h %8]
    [%a %7]  [%b %7]  [%c %7]  [%d %7]  [%e %7]  [%f %7]  [%g %7]  [%h %7]
    [%a %6]  [%b %6]  [%c %6]  [%d %6]  [%e %6]  [%f %6]  [%g %6]  [%h %6]
    [%a %5]  [%b %5]  [%c %5]  [%d %5]  [%e %5]  [%f %5]  [%g %5]  [%h %5]
    [%a %4]  [%b %4]  [%c %4]  [%d %4]  [%e %4]  [%f %4]  [%g %4]  [%h %4]
    [%a %3]  [%b %3]  [%c %3]  [%d %3]  [%e %3]  [%f %3]  [%g %3]  [%h %3]
    [%a %2]  [%b %2]  [%c %2]  [%d %2]  [%e %2]  [%f %2]  [%g %2]  [%h %2]
    [%a %1]  [%b %1]  [%c %1]  [%d %1]  [%e %1]  [%f %1]  [%g %1]  [%h %1]
  ==
--

