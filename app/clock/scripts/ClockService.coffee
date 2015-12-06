angular
    .module 'clock'
    .service 'ClockService',
    [ '$interval',
    ($interval) ->
        moment.locale 'de'

        @getTime = ->
            moment().format("HH:mm")
        @getDate = ->
            moment().format("dddd, D. MMMM")
        return
    ]
