/*
 *
 * Phoenix reducer
 *
 */

import { fromJS } from 'immutable';
import {
  INIT,
  MOUNT,
  UNMOUNT,
  SET_SOCKET,
  LOG_SOCKET,
} from './constants';

const initialState = fromJS({
  socket: null,
  logs: [],
});

function phoenixReducer(state = initialState, action) {
  const { type, payload } = action;
  switch (type) {
    case INIT:
      return state;
    case MOUNT:
      return state;
    case UNMOUNT:
      return state;
    case SET_SOCKET:
      return state.set('socket', payload.socket);
    case LOG_SOCKET:
      return state.update('logs', (logs) => {
        const { kind, msg, data } = payload;
        return logs.push(fromJS({
          kind,
          msg,
          data,
          time: new Date(),
        })).takeLast(1985);
      });
    default:
      return state;
  }
}

export default phoenixReducer;
