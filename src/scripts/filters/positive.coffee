angular.module "positiveFilter", []
  .filter "positive", ->
    (input) ->
      Math.abs input
