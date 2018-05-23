/**
 *
 * Phoenix
 *
 */

import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { createStructuredSelector } from 'reselect';
import { bindActionCreators, compose } from 'redux';

import injectSaga from 'utils/injectSaga';
import injectReducer from 'utils/injectReducer';
import { makeSelectPhoenix } from './selectors';
import reducer from './reducer';
import {
  init,
  mount,
  unmount,
} from './actions';
import saga from './saga';

export class Phoenix extends React.PureComponent { // eslint-disable-line react/prefer-stateless-function
  componentWillMount() {
    this.props.init();
  }

  componentDidMount() {
    this.props.mount();
  }

  componentWillUnmount() {
    this.props.unmount();
  }

  render() {
    return null;
  }
}

Phoenix.propTypes = {
};

const mapStateToProps = createStructuredSelector({
  phoenix: makeSelectPhoenix(),
});

const mapDispatchToProps = (dispatch) => bindActionCreators({
  init,
  mount,
  unmount,
}, dispatch);

const withConnect = connect(mapStateToProps, mapDispatchToProps);
const withReducer = injectReducer({ key: 'phoenix', reducer });
const withSaga = injectSaga({ key: 'phoenix', saga });

export default compose(
  withReducer,
  withSaga,
  withConnect,
)(Phoenix);
