import Urbit from '@urbit/http-api'
import { Ship, GameID, GameInfo, ActiveGameInfo, Challenge, ChessUpdate, ChallengeUpdate } from '../types/urbitChess'

interface ChessState {
  urbit: Urbit | null
  displayGame: ActiveGameInfo | null
  practiceBoard: String | null
  activeGames: Map<GameID, ActiveGameInfo>
  incomingChallenges: Map<Ship, Challenge>
  outgoingChallenges: Map<Ship, Challenge>
  setUrbit: (urbit: Urbit) => void
  setDisplayGame: (displayGame: ActiveGameInfo | null) => void
  setPracticeBoard: (practiceBoard: String | null) => void
  receiveChallengeUpdate: (data: ChallengeUpdate) => void
  receiveGame: (data: GameInfo) => void
  receiveUpdate: (data: ChessUpdate) => void
  declinedDraw: (gameID: GameID) => void
  offeredDraw: (gameID: GameID) => void
}

export default ChessState
