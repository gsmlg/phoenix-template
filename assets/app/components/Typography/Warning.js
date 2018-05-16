import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core';

import typographyStyle from 'jss/dashboard/typographyStyle';

function Warning({ ...props }) {
  const { classes, children } = props;
  return (
    <div className={`${classes.defaultFontStyle} ${classes.warningText}`}>
      {children}
    </div>
  );
}

Warning.propTypes = {
  classes: PropTypes.object.isRequired,
};

export default withStyles(typographyStyle)(Warning);
