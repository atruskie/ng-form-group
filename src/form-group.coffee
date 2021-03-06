class FormGroupController
  constructor: (@$scope) ->
    @status = null
    @disabled = false
    @inputs = []

    unref = @$scope.$watch(@update)
    @$scope.$on "$destroy", unref

  setParentForm: (ctrl) ->
    @ngFormCtrl = ctrl

  canValidate: ->
    inputsReady = @inputs.every (i) -> (i.$dirty and not i.$pending)

    if @ngFormCtrl
      @ngFormCtrl.$submitted or inputsReady
    else
      inputsReady

  update: =>
    if @canValidate()
      @status = if (@inputs.every (i) -> i.$valid) then "success" else "error"
    else
      @status = null

  addInput: (ctrl) ->
    @inputs.push(ctrl)


angular.module("ng-form-group")

.controller 'FormGroupController', ['$scope', FormGroupController]

.directive "formGroup", ->
  restrict: "C"
  require: ["formGroup", "?^form"]
  controller: 'FormGroupController'
  link: (scope, el, attrs, ctrls) ->
    [ctrl, ngFormCtrl] = ctrls

    if el.hasClass('form-group-without-feedback') or ctrl.inputs.length is 0
      ctrl.disabled = true
      return

    if ngFormCtrl
      ctrl.setParentForm(ngFormCtrl)

    dereg = scope.$watch (-> ctrl.status), (status) ->
      el.removeClass("has-error has-success")
      el.addClass("has-#{status}") if status

    scope.$on '$destroy', dereg

.directive "formControl", ->
  restrict: "C"
  require: ["?ngModel", "?^formGroup"]
  link: (scope, input, attrs, ctrls) ->
    [ngModelCtrl, formGroupCtrl] = ctrls
    return if not formGroupCtrl or formGroupCtrl.disabled
    formGroupCtrl.addInput(ngModelCtrl) if ngModelCtrl and formGroupCtrl

