const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    resolve: {
      alias: {
        react: path.resolve(__dirname, './node_modules/react'),
        'react-dom': path.resolve(__dirname, './node_modules/react-dom'),
        moment: path.resolve(__dirname, './node_modules/moment'),
        redux: path.resolve(__dirname, './node_modules/redux'),
        'react-redux': path.resolve(__dirname, './node_modules/react-redux'),
      },
      extensions: ['.js', '.jsx'],
    },
    optimization: {
      minimizer: [
        new TerserPlugin({ parallel: true }),
        new CssMinimizerPlugin(),
      ],
    },
    entry: {
      app: './js/app.js',
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/js'),
      publicPath: '/js/',
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                ['@babel/preset-env', { targets: { browsers: ['last 1 version', '> 1%'] } }],
                ['@babel/preset-react', { runtime: 'automatic' }],
              ],
            },
          },
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            { loader: 'css-loader', options: { url: false } },
            'sass-loader',
          ],
        },
        {
          test: /\.(png|jpg|gif|svg)$/i,
          type: 'asset',
          parser: {
            dataUrlCondition: { maxSize: 8192 },
          },
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/app.css' }),
      new CopyWebpackPlugin({ patterns: [{ from: 'static/', to: '../' }] }),
    ],
  };
};
