_ = require "underscore"

exports.type =
  String: (string) ->
    return _.isString string

  Number: (number) ->
    return _.isNumber number

  Boolean: (boolean) ->
    return _.isBoolean boolean

  Date: (date) ->
    return _.isDate date

  Array: (array) ->
    return _.isArray array

  Object: (object) ->
    return _.isObject(object) and not _.isArray(object) and not _.isFunction(object)

  Email: (email) ->
    return /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test email

  Domain: (domain) ->
    return /(\*\.)?[A-Za-z0-9]+(\-[A-Za-z0-9]+)*(\.[A-Za-z0-9]+(\-[A-Za-z0-9]+)*)*/.test domain

  Url: (url) ->
    return /^https?:\/\/[^\s;]*$/.test url

exports.rules =
  required: (param, value) ->
    unless _.isBoolean param
      return false
    if param and typeof(value) is "undefined"
      return false
    return true

  in: (param, value) ->
    if _.isString param
      return new RegExp(param, "ig").exec value
    else if _.isArray param
      return value in param

  notIn: (param, value) ->
    return not exports.rules.in param, value

  equal: (param, value) ->
    return param is value

  notEqual: (param, value) ->
    return not exports.rules.equal param, value

exports.process = (validationModel, params, req, errors = [], prefix = "") ->
  _.each validationModel, (validationRules, key) ->
    if _.isFunction validationRules
      if not _.has(params, key) or not validationRules.call(req, params[key])
        errors.push
          field: prefix + key
          code: "TypeError"
    else
      if "type" in _.keys validationRules
        unless _.has validationRules, "required"
          validationRules.required = true

        unless validationRules.required is false and typeof(params[key]) is "undefined"

          unless validationRules.type.call(req, params[key])
            errors.push
              field: prefix + key
              code: "TypeError"

          unless exports.rules.required validationRules.required, params[key]
            errors.push
              field: prefix + key
              code: "Missing"

          if _.has validationRules, "in"
            unless exports.rules.in validationRules.in, params[key]
              errors.push
                field: prefix + key
                code: "In"

          if _.has validationRules, "notIn"
            unless exports.rules.notIn validationRules.notIn, params[key]
              errors.push
                field: prefix + key
                code: "NotIn"

          if _.has validationRules, "equal"
            unless exports.rules.equal validationRules.equal, params[key]
              errors.push
                field: prefix + key
                code: "Equal"

          if _.has validationRules, "notEqual"
            unless exports.rules.notequal validationRules.notEqual, params[key]
              errors.push
                field: prefix + key
                code: "NotEqual"
      else

        if typeof(params[key]) is "undefined"
          errors.push
            field: prefix + key
            code: "Missing"
        else
          return exports.process validationRules, params[key], req, errors, key + "."

  return errors

exports.validationPlugin = ->
  return (req, res, next) ->
    if req.route
      errors = exports.process req.route.validation, req.params, req
      if errors.length > 0
        return res.send 400,
          status: "Validation Failed"
          errors: errors
    next()