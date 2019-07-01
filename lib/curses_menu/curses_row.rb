class CursesMenu

  # Definition of a row that stores for each cell the string and color information to be displayed
  class CursesRow

    # Constructor
    #
    # Parameters::
    # * *cells* (Hash< Symbol, Hash<Symbol,Object> >): For each cell id (ordered), the cell info:
    #   * *text* (String): Text associated to this cell
    #   * *color_pair* (Integer): Associated color pair [optional]
    #   * *begin_with* (String): String to prepend to the text [default: '']
    #   * *end_with* (String): String to append to the text [default: '']
    #   * *fixed_size* (Integer): Number of characters this cell will take, or nil if no limit. [default: nil]
    #   * *justify* (Symbol): Text justification (only used when fixed_size is not nil). Values can be: [default: :left]
    #     * *left*: Left justified
    #     * *right*: Right justified
    #   * *pad* (String): Text to be used to pad the cell content (only used when fixed_size is not nil) [default: ' ']
    # * *separator* (String): Separator used between cells [default: ' ']
    def initialize(cells, separator: ' ')
      @cells = cells
      @separator = separator
    end

    # Change the cells order
    #
    # Parameters::
    # * *cells* (Array<Symbol>): The ordered list of cells to filter
    # * *unknown_cells* (String or Hash<Symbol,Object>): Content to put in unknown cells (as a String or properties like in #initialize), or nil to not add them. [default: nil]
    def cells_order(cells, unknown_cells: nil)
      new_cells = {}
      cells.each do |cell_id|
        if @cells.key?(cell_id)
          new_cells[cell_id] = @cells[cell_id]
        elsif !unknown_cells.nil?
          new_cells[cell_id] = unknown_cells.is_a?(String) ? { text: unknown_cells } : unknown_cells
        end
      end
      @cells = new_cells
    end

    # Change properties of a set of cells
    #
    # Parameters::
    # * *cells* (Hash<Symbol, Hash<Symbol,Object> >): The cells properties to change, per cell id. Possible properties are the ones given in the #initialize method.
    def change_cells(cells)
      cells.each do |cell_id, cell_info|
        raise "Unknown cell #{cell_id}" unless @cells.key?(cell_id)
        @cells[cell_id].merge!(cell_info)
        @cells[cell_id].delete(:cache_rendered_text)
      end
    end

    # Get the size of the total string of such row.
    #
    # Parameters::
    # * *cells* (Array<Symbol>): The list of cells to consider for the size [default: @cells.keys]
    # Result::
    # * Integer: Row size
    def size(cells: @cells.keys)
      result = @separator.size * (cells.size - 1)
      cells.each do |cell_id|
        result += cell_text(cell_id).size
      end
      result
    end

    # Print this row into a window
    #
    # Parameters::
    # * *window* (Window): Curses window to print on
    # * *from* (Integer): From index to be displayed [default: 0]
    # * *to* (Integer): To index to be displayed [default: total size]
    # * *default_color_pair* (Integer): Default color pair to use if no color information is provided [default: COLORS_LINE]
    # * *force_color_pair* (Integer): Force color pair to use, or nil to not force [default: nil]
    # * *pad* (String or nil): Pad the line to the row extent with the given string, or nil for no padding. [default: nil]
    # * *add_nl* (Boolean): If true, then add a new line at the end [default: true]
    # * *single_line* (Boolean): If true, then make sure the print does not exceed the line [default: false]
    def print_on(window, from: 0, to: nil, default_color_pair: COLORS_LINE, force_color_pair: nil, pad: nil, add_nl: true, single_line: false)
      text_size = size
      from = text_size if from > text_size
      to = text_size - 1 if to.nil?
      to = window.maxx - window.curx + from - 2 if single_line && window.curx + to - from >= window.maxx - 1
      current_idx = 0
      @cells.each.with_index do |(cell_id, cell_info), cell_idx|
        text = cell_text(cell_id)
        full_substring_size = text.size + @separator.size
        if from < current_idx + full_substring_size
          # We have something to display from this substring
          window.color_set(
            if force_color_pair.nil?
              cell_info[:color_pair] ? cell_info[:color_pair] : default_color_pair
            else
              force_color_pair
            end
          )
          window << "#{text}#{cell_idx == @cells.size - 1 ? '' : @separator}"[(from < current_idx ? 0 : from - current_idx)..to - current_idx]
        end
        current_idx += full_substring_size
        break if current_idx > to
      end
      window.color_set(force_color_pair.nil? ? default_color_pair : force_color_pair)
      if pad && window.curx < window.maxx
        nbr_chars = window.maxx - window.curx - 1
        window << (pad * nbr_chars)[0..nbr_chars - 1]
      end
      window << "\n" if add_nl
    end

    private

    # Get a cell's text.
    # Cache it to not compute it several times.
    #
    # Parameters::
    # * *cell_id* (Symbol): Cell id to get text for
    # Result::
    # * String: The cell's text
    def cell_text(cell_id, cell_decorator: nil)
      unless @cells[cell_id].key?(:cache_rendered_text)
        begin_str = "#{@cells[cell_id][:begin_with] || ''}#{@cells[cell_id][:text]}"
        end_str = @cells[cell_id][:end_with] || ''
        @cells[cell_id][:cache_rendered_text] =
          if @cells[cell_id][:fixed_size]
            text = "#{begin_str[0..@cells[cell_id][:fixed_size] - end_str.size - 1]}#{end_str}"
            remaining_size = @cells[cell_id][:fixed_size] - text.size
            if remaining_size > 0
              padding = ((@cells[cell_id][:pad] || ' ') * remaining_size)[0..remaining_size - 1]
              justify = @cells[cell_id][:justify] || :left
              case justify
              when :left
                "#{text}#{padding}"
              when :right
                "#{padding}#{text}"
              else
                raise "Unknown justify decorator: #{justify}"
              end
            else
              text[0..@cells[cell_id][:fixed_size] - 1]
            end
          else
            "#{begin_str}#{end_str}"
          end
      end
      @cells[cell_id][:cache_rendered_text]
    end

  end

end
