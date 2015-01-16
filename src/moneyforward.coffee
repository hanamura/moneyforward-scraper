Nightmare = require 'nightmare'
cheerio = require 'cheerio'

Payment = require './payment'

# Moneyforward
# ============

class Moneyforward

  # constructor
  # -----------

  constructor: ({email: @_email, password: @_password}) ->
    throw new Error 'email required'    unless @_email
    throw new Error 'password required' unless @_password

  # getRecentPayments
  # -----------------

  getRecentPayments: (cb) ->

    group = '0'

    # loadingComplete

    loadingComplete = ->
      el = document.querySelector '.fc-header-title'
      return false unless el
      matches = el.innerText.match /\d{4}\/\d{1,2}\/\d{1,2}/
      return false unless matches
      return true

    # htmlString

    extractHTML = ->
      document.getElementsByTagName('html')[0].innerHTML

    # start scraping

    payments = []

    new Nightmare()

      # login
      .goto 'https://moneyforward.com/cf'
        .type '#user_email', @_email
        .type '#user_password', @_password
        .click '#login-btn-sumit'
        .wait()

      # select group
        .evaluate (group) ->
          el = document.querySelector "#group_id_hash option[value=\"#{group}\"]"
          return 'option doesn’t exist' unless el
          el.selected = true
          el.form.submit()
          return false
        , (err) ->
          if err then throw new Error err
        , group
        .wait()

      # get this month’s payments
        .click '.fc-button-today'
        .wait loadingComplete, true
        .evaluate extractHTML, (html) ->
          $ = cheerio.load html
          $('#cf-detail-table tbody tr').each ->
            payments.push new Payment $.html @

      # get last month’s payments
        .click '.fc-button-prev'
        .wait loadingComplete, true
        .evaluate extractHTML, (html) ->
          $ = cheerio.load html
          $('#cf-detail-table tbody tr').each ->
            payments.push new Payment $.html @

      # run
      .run (err, nightmare) ->
        cb err, JSON.parse JSON.stringify payments

# properties
# ==========

Object.defineProperty Moneyforward::, 'email',    get: -> @_email
Object.defineProperty Moneyforward::, 'password', get: -> @_password

# exports
# =======

module.exports = Moneyforward
