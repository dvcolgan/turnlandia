# http://www.ewal.net/2012/10/17/bootstrap-knockout-toggle-button-bindings/
ko.bindingHandlers.radio =
    init: (element, valueAccessor, allBindings, data, context) ->
        observable = valueAccessor()

        if not ko.isWriteableObservable(observable)
            throw "You must pass an observable or writeable computed"

        $element = $(element)
        if $element.hasClass("btn")
            $buttons = $element
        else
            $buttons = $(".btn", $element)

        elementBindings = allBindings()
        $buttons.each ->
            btn = @
            $btn = $(btn)

            radioValue =
                elementBindings.radioValue || #this is really only useful when the binding is on the button, itself
                $btn.attr("data-value")  ||
                $btn.attr("value")  ||
                $btn.text()

            $btn.on "click", ->
                observable ko.utils.unwrapObservable(radioValue)
                return

            ko.computed disposeWhenNodeIsRemoved: btn, read: ->
                debugger
                $btn.toggleClass "active", observable() == ko.utils.unwrapObservable(radioValue)
                return

        return
