cheerio = require 'cheerio'
moment = require 'moment'

# Payment
# =======

class Payment

  # constructor
  # -----------

  constructor: (html) ->

    $ = cheerio.load html

    # id

    @_id = $('tr').attr 'id'
    if m = @_id.match /js-transaction-(\d+)/
      @_id = m[1]
    else
      throw new Error 'id doesn’t exist'

    # date

    @_date = $('td.date').attr 'data-table-sortable-value'
    @_date = moment @_date, 'YYYY/MM/DD'

    # content

    @_content = $('td.content').text().trim()

    # amount

    @_amount = $('td.amount').text().trim()
    if m = @_amount.match /-?[0-9,]+/
      @_amount = m[0]
      @_amount = @_amount.replace /,/g, ''
      @_amount = parseInt @_amount
    else
      throw new Error 'amount doesn’t exist'

    # source

    @_source = $('td.note').text().trim()

    # memo

    @_memo = $('td.memo').text().trim()

  # toJSON
  # ------

  toJSON: ->
    id: @_id
    date: @_date.format()
    content: @_content
    amount: @_amount
    source: @_source
    memo: @_memo

# exports
# =======

module.exports = Payment
