class PageController

  constructor: (el) ->
    @_init(el)
    @_event()

  _init: (el) ->
    @current = 1;
    @current_max = 1;
    @get_current_max()

  _event: ->
    $('body').on 'keydown', (e) =>
      @keyOperation(e)

  get_current_max: (url, page) =>
    $.ajax(
      type: 'GET'
      url: '/current_max_page'
    ).done((data) =>
      console.log 'success!!'
      @current_max = data['page']
      console.log 'current_max:', @current_max
      return data['page']
    ).fail (data) =>
      console.log 'error!!!'
      return

  keyOperation: (e) =>
    ENTER_CODE = 13
    KEYLEFT_CODE = 37
    KEYUP_CODE = 38
    KEYRIGHT_CODE = 39
    KEYDOWN_CODE = 40
    # console.log(e.keyCode)
    if e.keyCode == KEYLEFT_CODE || e.keyCode == KEYUP_CODE
      console.log('prev')
      @get_current_max()
      if @current > 1
        @current -= 1;
        $('#pages').find('object').addClass('hidden')
        $('#pages').find("[page='#{@current}']").removeClass('hidden')
        # $('#page').append("<object data='/pages/#{@current}#toolbar=0&navpanes=0&scrollbar=0' type='application/pdf' width='100%' height='70%'</object>")
    else if e.keyCode == KEYRIGHT_CODE || e.keyCode == KEYDOWN_CODE
      console.log('next')
      @get_current_max()
      console.log 'latest_current_max:', @current_max
      if @current < @current_max
        console.log('next paged')
        @current += 1;
        if $('#pages').find("[page='#{@current}']").length == 0
          $('#pages').append("<object data='/pages/#{@current}#toolbar=0&navpanes=0&scrollbar=0' type='application/pdf' page='#{@current}'></object>")
        $('#pages').find('object').addClass('hidden')
        $('#pages').find("[page='#{@current}']").removeClass('hidden')

  # request = (url, page) =>
  #   $.ajax(
  #     type: 'GET'
  #     url: "#{url}/#{page}"
  #     # dataType: 'arraybuffer'
  #   ).done((data) ->
  #     console.log 'success!!'
  #     return
  #   ).fail (data) ->
  #     console.log 'error!!!'
  #     return


    # complete: (xhr, status) =>
    #   if xhr.status == 200
    #     # @decide()
    #     console.log('succeeded')
    #   else
    #     console.log('error')

$ ->
  new PageController()
