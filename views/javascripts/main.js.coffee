# ==============================================================================
# views - javascripts - main
# ==============================================================================
class PageController
  constructor: (el) ->
    @_init(el)
    @_event()

  _init: (el) ->
    @current = 1;
    @current_max = 1;
    @filename = window.location.pathname.split('/')[2]
    # @load_first_page(@filename)
    console.log(@filename)
    @get_current_max()

  _event: ->
    $('body').on 'keydown', (e) =>
      @keyOperation(e)

  load_first_page: (filename) =>
    first = $('#pages').find("[page='1']")
    first.attr('dat', "/pages/#{filename}/1#toolbar=0&navpanes=0&scrollbar=0")

  get_current_max: (url, page) =>
    $.ajax(
      type: 'GET'
      url: "/current_max_page/#{@filename}"
    ).done((data) =>
      console.log 'success!!'
      @current_max = data['page']
      console.log 'current_max:', @current_max
      return data['page']
    ).fail (data) =>
      return

  keyOperation: (e) =>
    ENTER_CODE = 13
    KEYLEFT_CODE = 37
    KEYUP_CODE = 38
    KEYRIGHT_CODE = 39
    KEYDOWN_CODE = 40
    if e.keyCode == KEYLEFT_CODE || e.keyCode == KEYUP_CODE
      @get_current_max()
      if @current > 1
        @current -= 1;
        @showPage(@current)
    else if e.keyCode == KEYRIGHT_CODE || e.keyCode == KEYDOWN_CODE
      @get_current_max()
      if @current < @current_max
        @current += 1;
        if $('#pages').find("[page='#{@current}']").length == 0
          $('#pages').append("<object data='/pages/#{@filename}/#{@current}#toolbar=0&navpanes=0&scrollbar=0' type='application/pdf' page='#{@current}'></object>")
        @showPage(@current)

  showPage: (page) ->
    $('#pages').find('object').addClass('hidden')
    $('#pages').find("[page='#{page}']").removeClass('hidden')

$ ->
  new PageController()
