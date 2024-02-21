const { defineConfig } = require('cypress')

// const webpackPreprocessor = require('@cypress/webpack-preprocessor')

module.exports = defineConfig({
  projectId: '3teyqm',
  defaultCommandTimeout: 10000,
  watchForFileChanges: false,
  reporterOptions: {
    mochaFile: '/home/semaphore/reports/cypress-output-[hash].xml'
  },
  reporter: 'junit',
  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      // on('file:preprocessor', webpackPreprocessor())
      return require('./cypress/plugins/index.js')(on, config)
    },
    baseUrl: 'http://localhost:5002',
    specPattern: '../card-mod-*/cypress/**/*spec.coffee',
    // testIsolation: false
  },
})
