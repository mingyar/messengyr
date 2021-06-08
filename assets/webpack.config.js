const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    resolve: {
      alias: {
        react: path.resolve(__dirname, './node_modules/react'),
        'react-dom': path.resolve(__dirname, './node_modules/react-dom')
      }
    },
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },
    entry: {
      'app': glob.sync('./vendor/**/*.js').concat(['./js/app.js'])
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/js'),
      publicPath: '/js/'
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [
        { 
          test: /\.jsx$/, 
          exclude: /node_modules/,
          use: { 
            loader: 'babel-loader',
            query: {
              presets: ['@babel/preset-env', '@babel/react']
            } 
          }
        },
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.scss$/,
          use: [
            'style-loader',
            'css-loader?url=false',
            'sass-loader',
          ] 
        },
        {
          test: /\.(png|jpg|gif|svg)$/i,
          use: [
            {
              loader: 'url-loader',
              options: {
                limit: 8192,
              },
            },
          ],
        },
      ]
    },
    resolve: {
      extensions: ['.js', '.jsx'],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/app.css' }),
      new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
    ]  
  }
};
