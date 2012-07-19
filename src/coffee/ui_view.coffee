# module setup stuff
if this.Continuum
  Continuum = this.Continuum
else
  Continuum = {}
  this.Continuum = Continuum
if not Continuum.ui
  Continuum.ui = {}

class DataTableView extends ContinuumView
  initialize : (options) ->
    super(options)
    safebind(this, @model, 'destroy', @remove)
    safebind(this, @model, 'change', @render)
    safebind(this, @mget_ref('data_source'), 'change', @render)
    @render()

  className: 'div'

  render : () ->
    table_template = """
		<table class='table table-striped table-bordered table-condensed' id='tableid_na'></table>
    """
    header_template = """
      <thead id ='header_id_na'></thead>
    """
    header_column = """
      <th><a href='#' onClick='cdxSortByColumn()' class='link'>{{column_name}}</a></th>
    """
    row_template = """
      <tr></tr>
    """
    datacell_template = """
      <td>{{data}}</td>
    """

    table = $(table_template)
    header = $(header_template)
    html = _.template(header_column, {'column_name' : '#'})
    header.append($(html))
    for colname in @mget('columns')
      html = _.template(header_column, {'column_name' : colname})
      header.append($(html))
    table.append(header)
    rowCount = @mget('offset')
    for rowdata in @mget_ref('data_source').get('data')
      row = $(row_template)
      datacell = $(_.template(datacell_template, {'data' : ++rowCount}))
      row.append(datacell)
      for colname in @mget('columns')
        datacell = $(_.template(datacell_template, {'data' : rowdata[colname]}))
        row.append(datacell)
      table.append(row)

    @$el.empty()
    @render_pagination()
    @$el.append(table)
    if @mget('usedialog') and not @$el.is(":visible")
      @add_dialog()

  render_pagination : ->
    table_hdr_template = """
      <div>
        <div class="pull-left">
          <span>Total Rows: {{total_rows}}</span>
        </div>
        <div class="pull-right"></div>
      </div>
    """
    btn_group = $('<div class="btn-group"></div>')
    if @mget('offset') > 0
      node = $('<a class="btn" title="First Page" href="#"><i class="icon-fast-backward"></i></a>')
      btn_group.append(node)
      node.click(=>
        @model.load(0)
        return false
      )
      node = $('<a class="btn" title="Previous Page" href="#"><i class="icon-step-backward"></i></a>')
      btn_group.append(node)
      node.click(=>
        @model.load(_.max([@mget('offset') - @mget('chunksize'), 0]))
        return false
      )

    maxoffset = @mget('total_rows') - @mget('chunksize')

    if @mget('offset') < maxoffset
      node = $('<a class="btn" title="Next Page" href="#"><i class="icon-step-forward"></i></a>')
      btn_group.append(node)
      node.click(=>
        @model.load(_.min([
          @mget('offset') + @mget('chunksize'),
          maxoffset]))
        return false
      )
      node = $('<a class="btn" title="Last Page" href="#"><i class="icon-fast-forward"></i></a>')
      btn_group.append(node)
      node.click(=>
        @model.load(maxoffset)
        return false
      )

    table_hdr = $(_.template(table_hdr_template, {'total_rows' : @mget('total_rows')}))
    btn_group = $('<div class="pull-right"></div>').append(btn_group)
    @$el.append(btn_group)
    @$el.append(table_hdr)


class TableView extends ContinuumView
  delegateEvents: ->
    safebind(this, @model, 'destroy', @remove)
    safebind(this, @model, 'change', @render)

  render : ->
    super()
    @$el.empty()
    @$el.append("<table></table>")
    @$el.find('table').append("<tr></tr>")
    headerrow = $(@$el.find('table').find('tr')[0])
    for column, idx in ['row'].concat(@mget('columns'))
      elem = $("<th class='tableelem tableheader'>#{column}/th>")
      headerrow.append(elem)
    for row, idx in @mget('data')
      row_elem = $("<tr class='tablerow'></tr>")
      rownum = idx + @mget('data_slice')[0]
      for data in [rownum].concat(row)
        elem = $("<td class='tableelem'>#{data}</td>")
        row_elem.append(elem)
      @$el.find('table').append(row_elem)
    @render_pagination()
    if @mget('usedialog') and not @$el.is(":visible")
      @add_dialog()

  render_pagination : ->
    if @mget('offset') > 0
      node = $("<button>first</button>").css({'cursor' : 'pointer'})
      @$el.append(node)
      node.click(=>
        @model.load(0)
        return false
      )
      node = $("<button>previous</button>").css({'cursor' : 'pointer'})
      @$el.append(node)
      node.click(=>
        @model.load(_.max([@mget('offset') - @mget('chunksize'), 0]))
        return false
      )

    maxoffset = @mget('total_rows') - @mget('chunksize')
    if @mget('offset') < maxoffset
      node = $("<button>next</button>").css({'cursor' : 'pointer'})
      @$el.append(node)
      node.click(=>
        @model.load(_.min([
          @mget('offset') + @mget('chunksize'),
          maxoffset]))
        return false
      )
      node = $("<button>last</button>").css({'cursor' : 'pointer'})
      @$el.append(node)
      node.click(=>
        @model.load(maxoffset)
        return false
      )
Continuum.ui.DataTableView = DataTableView