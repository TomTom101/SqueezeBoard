angular
    .module('clock')

    .filter 'celcius', () ->
        (fahrenheit) ->
            (fahrenheit - 32) * 5.0 / 9.0
