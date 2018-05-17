import { takeLatest, take, call, put, select } from 'redux-saga/effects';
import { eventChannel } from 'redux-saga';
import { Socket } from 'phoenix';
import {
  INIT,
  MOUNT,
  UNMOUNT,
} from './constants';
import {
  setSocket,
  logSocket,
} from './actions';
import {
  makeSelectSocket,
} from './selectors';

function createLogChannel(socket) {
  return eventChannel((emmiter) => {
    socket.logger = (kind, msg, data) => {
      emmiter({ kind, msg, data });
    };
    return () => socket.disconnect();
  });
}

function* init() {
  const params = {};
  const socket = new Socket('/socket', { params });
  yield put(setSocket(socket));
  const chan = yield call(createLogChannel, socket);
  while (true) {
    const payload = yield take(chan);
    yield put(logSocket(payload));
  }
}

function* mount() {
  const socket = yield select(makeSelectSocket());
  socket.connect();
}

function* unmount() {
  const socket = yield select(makeSelectSocket());
  socket.disconnect();
}

// Individual exports for testing
export default function* defaultSaga() {
  // See example in containers/HomePage/saga.js
  yield takeLatest(INIT, init);
  yield takeLatest(MOUNT, mount);
  yield takeLatest(UNMOUNT, unmount);
}
