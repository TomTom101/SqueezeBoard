// Generated by CoffeeScript 1.10.0
angular.module('clock').factory('ForecastFactory', [
  '$interval', '$http', function($interval, $http) {
    var apiKey, cachedForecast, currentForecast, interval, lat, lon, pollForecastIO;
    apiKey = '9fe2490f9dbac2962a251e23ca99e81a';
    lat = '52.5158';
    lon = '13.4725';
    interval = 1000 * 60 * 15;
    cachedForecast = null;
    pollForecastIO = function(callback) {
      var url;
      steroids.logger.log("polling ForecastFactory");
      url = ['https://api.forecast.io/forecast/', apiKey, '/', lat, ',', lon].join('');
      url += ['?callback=JSON_CALLBACK', 'exclude=minutely,hourly', 'lang=de', 'units=ca'].join('&');
      return $http.jsonp(url).success(function(data) {
        return callback(null, data);
      }).error(function(error) {
        steroids.logger.error(error);
        return callback(error);
      });
    };
    currentForecast = function(callback) {
      if (!cachedForecast) {
        return pollForecastIO(function(err, data) {
          cachedForecast = data;
          return callback(null, cachedForecast);
        });
      } else {
        return callback(null, cachedForecast);
      }
    };
    $interval(function() {
      return pollForecastIO(function(err, data) {
        return cachedForecast = data;
      });
    }, interval);
    return {
      currentForecast: currentForecast
    };
  }
]);
