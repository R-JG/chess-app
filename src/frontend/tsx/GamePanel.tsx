import React, { useState } from 'react'
import { Chess, ChessInstance } from 'chess.js'
import Popup from 'reactjs-popup'
import useChessStore from '../ts/state/chessStore'
import { pokeAction, offerDraw, acceptDraw, declineDraw, claimSpecialDraw, resign, requestUndo, declineUndo, acceptUndo } from '../ts/helpers/urbitChess'
import { CHESS } from '../ts/constants/chess'
import { Side, GameID, SAN, GameInfo, ActiveGameInfo } from '../ts/types/urbitChess'

export function GamePanel () {
  const { urbit, displayGame, setDisplayGame, offeredDraw, declinedDraw, requestedUndo, declinedUndo, practiceBoard, setPracticeBoard, displayIndex, setDisplayIndex } = useChessStore()
  const hasGame: boolean = (displayGame !== null)
  const practiceHasMoved = (localStorage.getItem('practiceBoard') !== CHESS.defaultFEN)
  const opponent = !hasGame ? '~sampel-palnet' : (urbit.ship === displayGame.info.white.substring(1))
    ? displayGame.info.black
    : displayGame.info.white

  //
  // HTML element helper functions
  //

  const resignOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, resign(gameID))
  }

  const offerDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, offerDraw(gameID), null, () => { offeredDraw(gameID) })
  }

  const acceptDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, acceptDraw(gameID))
  }

  const declineDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, declineDraw(gameID), null, () => { declinedDraw(gameID) })
  }

  const claimSpecialDrawOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, claimSpecialDraw(gameID))
  }

  const requestUndoOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, requestUndo(gameID), null, () => { requestedUndo(gameID) })
  }

  const acceptUndoOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, acceptUndo(gameID))
  }

  const declineUndoOnClick = async () => {
    const gameID = displayGame.info.gameID
    await pokeAction(urbit, declineUndo(gameID), null, () => { declinedUndo(gameID) })
  }

  const moveOpacity = (index: number) => {
    if (displayIndex == null || index <= displayIndex) {
      return 1.0
    } else {
      return 0.3
    }
  }

  //
  // HTML element generation functions
  //

  const moveList = () => {
    let displayMoves = (displayGame.info.moves !== null) ? displayGame.info.moves : []
    let components = []
    for (let wIndex: number = 0; wIndex < displayMoves.length; wIndex += 2) {
      const move: number = (wIndex / 2) + 1
      const bIndex: number = wIndex + 1
      const wMove: SAN = displayMoves[wIndex].san

      if (bIndex >= displayMoves.length) {
        components.push(
          <li key={ move } className='move-item' style={{ opacity: moveOpacity(wIndex) }}>
            <span onClick={ () => setDisplayIndex(wIndex) }>
              { wMove }
            </span>
          </li>
        )
      } else {
        components.push(
          <li key={ move } className='move-item' style={{ opacity: moveOpacity(wIndex) }}>
            <span onClick={ () => setDisplayIndex(wIndex) }>
              { wMove }
            </span>
            { '\xa0'.repeat(6 - wMove.length) }
            {/* setting opacity to 1.0 offsets a cumulative reduction in opacity on each bIndex ply when displayIndex < this move's wIndex */}
            <span onClick={ () => setDisplayIndex(bIndex) } style={{ opacity: (moveOpacity(wIndex) === 1.0) ? moveOpacity(bIndex) : 1.0 }}>
              { displayMoves[wIndex + 1].san }
            </span>
          </li>
        )
      }
    }

    return components
  }

  //
  // Render HTML
  //

  const renderDrawPopup = (game: ActiveGameInfo) => {
    return (
      <Popup open={game.gotDrawOffer}>
        <div>
          <p>{`${opponent} has offered a draw`}</p>
          <br/>
          <div className='draw-resolution row'>
            <button className="accept" role="button" onClick={acceptDrawOnClick}>Accept</button>
            <button className="reject" role="button" onClick={declineDrawOnClick}>Decline</button>
          </div>
        </div>
      </Popup>
    )
  }

  const renderUndoPopup = (game: ActiveGameInfo) => {
    return (
      <Popup open={game.gotUndoRequest}>
        <div>
          <p>{`${opponent} has requested to undo a move`}</p>
          <br/>
          <div className='draw-resolution row'>
            <button className="accept" role="button" onClick={acceptUndoOnClick}>Accept</button>
            <button className="reject" role="button" onClick={declineUndoOnClick}>Decline</button>
          </div>
        </div>
      </Popup>
    )
  }

  return (
    <div className='game-panel-container col' style={{ display: ((displayGame !== null) ? 'flex' : ' none') }}>
      <div className="game-panel col">
        <div id="opp-timer" className={'timer row' + (hasGame ? '' : ' hidden')}>
          <p>00:00</p>
        </div>
        <div id="opp-player" className={'player row' + (hasGame ? '' : ' hidden')}>
          <p>{opponent}</p>
        </div>
        <div className={'moves col' + (hasGame ? '' : ' hidden')}>
          <ol>
            { moveList() }
          </ol>
        </div>
        <div id="our-player" className={'player row' + (hasGame ? '' : ' hidden')}>
          <p>~{window.ship}</p>
        </div>
        <div id="our-timer" className={'timer row' + (hasGame ? '' : ' hidden')}>
          <p>00:00</p>
        </div>
        {/* buttons */}
        {/* resign button */}
        <button
          className='option'
          disabled={!hasGame}
          onClick={resignOnClick}>
          Resign</button>
        {/* offer/accept draw button */}
        {displayGame.gotDrawOffer
          ? <button
            className='option'
            disabled={!hasGame}
            onClick={acceptDrawOnClick}>
            Accept Draw Offer</button>
          : <button
            className='option'
            disabled={!hasGame || displayGame.sentDrawOffer}
            onClick={offerDrawOnClick}>
            Send Draw Offer</button>
        }
        {/* claim special draw */}
        <button
          className='option'
          disabled={!hasGame || !displayGame.drawClaimAvailable}
          onClick={claimSpecialDrawOnClick}>
          Claim Special Draw</button>
        {/* request/accept undo button */}
        {displayGame.gotUndoRequest
          ? <button
            className='option'
            disabled={!hasGame}
            onClick={acceptUndoOnClick}>
            Accept Undo Request</button>
          : <button
            className='option'
            disabled={!hasGame || displayGame.sentUndoRequest}
            onClick={requestUndoOnClick}>
            Request to Undo Move</button>
        }
        {/* (reset) practice board */}
        {hasGame
          ? <button
            className='option'
            disabled={!hasGame}
            onClick={() => setDisplayGame(null)}>
            Practice Board</button>
          : <button
            className='option'
            disabled={hasGame || !practiceHasMoved}
            onClick={() => setPracticeBoard(null)}>
            Reset Practice Board</button>
        }
      </div>
      { (displayGame !== null) ? renderDrawPopup(displayGame) : <div/> }
      { (displayGame !== null) ? renderUndoPopup(displayGame) : <div/> }
    </div>
  )
}
