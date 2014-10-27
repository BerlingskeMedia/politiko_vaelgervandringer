angular.module "positiveFilter", []
  .filter "positive", ->
    (input) ->
      input.replace("-", "")
