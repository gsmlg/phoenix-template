import { createSelector } from 'reselect';

/**
 * Direct selector to the phoenix state domain
 */
export const selectPhoenixDomain = (state) => state.get('phoenix');

/**
 * Other specific selectors
 */
export const makeSelectSocket = () => createSelector(
  selectPhoenixDomain,
  (substate) => substate.get('socket')
);

export const makeSelectLogs = () => createSelector(
  selectPhoenixDomain,
  (substate) => substate.get('logs')
);

/**
 * Default selector used by Phoenix
 */

export const makeSelectPhoenix = () => createSelector(
  selectPhoenixDomain,
  (substate) => substate
);

export default makeSelectPhoenix;
