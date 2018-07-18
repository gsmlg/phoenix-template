
import { fromJS } from 'immutable';
import phoenixReducer from '../reducer';

describe('phoenixReducer', () => {
  it('returns the initial state', () => {
    expect(phoenixReducer(undefined, {})).toEqual(fromJS({}));
  });
});
