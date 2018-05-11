import { injectGlobal } from 'styled-components';

/* eslint no-unused-expressions: 0 */
injectGlobal`
.ct-grid {
    stroke: rgba(255, 255, 255, 0.2);
    stroke-width: 1px;
    stroke-dasharray: 2px;
}

.ct-series-a .ct-point, .ct-series-a .ct-line, .ct-series-a .ct-bar, .ct-series-a .ct-slice-donut {
    stroke: rgba(255, 255, 255, 0.8);
}

.ct-label.ct-horizontal.ct-end {
    -webkit-box-align: flex-start;
    -webkit-align-items: flex-start;
    -ms-flex-align: flex-start;
    align-items: flex-start;
    -webkit-box-pack: flex-start;
    -webkit-justify-content: flex-start;
    -ms-flex-pack: flex-start;
    justify-content: flex-start;
    text-align: left;
    text-anchor: start;
}

.ct-label {
    color: rgba(255, 255, 255, 0.7);
}

.ct-chart-line .ct-label, .ct-chart-bar .ct-label {
    display: block;
    display: -webkit-box;
    display: -moz-box;
    display: -ms-flexbox;
    display: -webkit-flex;
    display: flex;
}

.ct-label {
    fill: rgba(0, 0, 0, 0.4);
    line-height: 1;
}
html * {
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
}
body {
    background-color: #EEEEEE;
    color: #3C4858;
    margin: 0;
    font-family: Roboto, Helvetica, Arial, sans-serif;
    font-weight: 300;
    line-height: 1.5em;
}

blockquote footer:before, blockquote small:before {
    content: '\\2014 \\00A0';
}

h1 {
    font-size: 3em;
    line-height: 1.15em;
}

h2 {
    font-size: 2.4em;
}

h3 {
    font-size: 1.825em;
    line-height: 1.4em;
    margin: 20px 0 10px;
}

h4 {
    font-size: 1.3em;
    line-height: 1.4em;
}

h5 {
    font-size: 1.25em;
    line-height: 1.4em;
    margin-bottom: 15px;
}

h6 {
    font-size: 1em;
    text-transform: uppercase;
    font-weight: 500;
}

body {
    background-color: #EEEEEE;
    color: #3C4858;
}

blockquote p {
    font-style: italic;
}

body, h1, h2, h3, h4, h5, h6 {
    font-family: "Roboto", "Helvetica", "Arial", sans-serif;
    font-weight: 300;
    line-height: 1.5em;
}

a {
    color: #9c27b0;
    text-decoration: none;
}

a:hover, a:focus {
    color: #89229b;
    text-decoration: none;
}

legend {
    border-bottom: 0;
}

* {
    -webkit-tap-highlight-color: rgba(255, 255, 255, 0);
    -webkit-tap-highlight-color: transparent;
}

*:focus {
    outline: 0;
}

a:focus, a:active,
button:active, button:focus, button:hover,
button::-moz-focus-inner,
input[type="reset"]::-moz-focus-inner,
input[type="button"]::-moz-focus-inner,
input[type="submit"]::-moz-focus-inner,
select::-moz-focus-inner,
input[type="file"] > input[type="button"]::-moz-focus-inner {
    outline: 0 !important;
}

legend {
    margin-bottom: 20px;
    font-size: 21px;
}

output {
    padding-top: 8px;
    font-size: 14px;
    line-height: 1.42857;
}

label {
    font-size: 14px;
    line-height: 1.42857;
    color: #AAAAAA;
    font-weight: 400;
}

footer {
    padding: 15px 0;
}

footer ul {
    margin-bottom: 0;
    padding: 0;
    list-style: none;
}

footer ul li {
    display: inline-block;
}

footer ul li a {
    color: inherit;
    padding: 15px;
    font-weight: 500;
    font-size: 12px;
    text-transform: uppercase;
    border-radius: 3px;
    text-decoration: none;
    position: relative;
    display: block;
}

footer ul li a:hover {
    text-decoration: none;
}

@media (max-width: 991px) {
    body,
    html {
        position: relative;
        overflow-x: hidden;
    }

    #bodyClick {
        height: 100%;
        width: 100%;
        position: fixed;
        opacity: 0;
        top: 0;
        left: auto;
        right: 260px;
        content: "";
        z-index: 9999;
        overflow-x: hidden;
    }
}
`;
